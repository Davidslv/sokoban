class User < ActiveRecord::Base

  # Constants

  DAYS_BEFORE_UPDATING_FRIENDS        = 5
  DAYS_WITHOUT_ADS_IF_FRIENDS_INVITED = 3
  DAYS_WITHOUT_FRIENDS_INVITE_POPUP   = 30

  # Attributes
  attr_protected :created_at, :updated_at

  # Associations
  has_many :user_user_links,
           :primary_key => :f_id

  has_many :friends,
           :through => :user_user_links

  has_many :scores,
           :class_name => 'LevelUserLink',
           :order      => 'pushes ASC, moves ASC, created_at DESC'

  has_many :best_scores,
           :class_name => 'LevelUserLink',
           :order      => 'pushes ASC, moves ASC, created_at DESC',
           :conditions => { :best_level_user_score => true }

  has_many :levels,
           :through => :scores

  has_many :pack_user_links

  # Nested attributes

  # Validations
  validates :f_id, :uniqueness => true

  # Callbacks
  before_save :update_friends_count

  # Scopes

  def self.registered
    where('email IS NOT NULL')
  end

  def self.not_registered
    where('email IS NULL')
  end

  # Methods

  def self.update_or_create(credentials)
    token = credentials['token']
    graph = Koala::Facebook::API.new(token)
    profile = graph.get_object('me')

    # Hash with user values
    user_hash = {
      :name           => profile['name'],
      :email          => profile['email'],
      :picture        => graph.get_picture('me'),
      :gender         => profile['gender'],
      :locale         => profile['locale'],
      :f_id           => profile['id'],
      :f_token        => token,
      :f_first_name   => profile['first_name'],
      :f_middle_name  => profile['middle_name'],
      :f_last_name    => profile['last_name'],
      :f_username     => profile['username'],
      :f_link         => profile['link'],
      :f_timezone     => profile['timezone'],
      :f_updated_time => profile['updated_time'],
      :f_verified     => profile['verified'],
      :f_expires      => credentials['expires'],
      :f_expires_at   => Time.at(credentials['expires_at']).to_datetime
    }

    # if user exists, find it and update values (but don't save now)
    # else create user
    user = User.where(:f_id => profile['id'])
    if not user.empty?
      user = user.first
      new_registered_user = (not user.email) ? true : false
      user.attributes = user_hash
    else
      new_registered_user = true
      user = User.new(user_hash)
    end

    if new_registered_user
      # Subscription to mailing list
      mimi = MadMimi.new(ENV['MADMIMI_EMAIL'], ENV['MADMIMI_KEY'])
      mimi.csv_import("email, first name, last name, full name, gender, locale\n" +
                      "#{user.email}, #{user.f_first_name}, #{user.f_last_name}, #{user.name}, #{user.gender}, #{user.locale}")
      mimi.add_to_list(user.email, 'Sokoban')

      # email to admin
      UserNotifier.delay.new_user(user.name, user.email)
    end

    user.like_fan_page = user.request_like_fan_page?

    user
  end

  def registered?
    self.email != nil
  end

  # Ask facebook if this user likes the facebook fan page of the application
  # return true or false
  def request_like_fan_page?
    oauth        = Koala::Facebook::OAuth.new(ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'])
    access_token = oauth.get_app_access_token
    graph        = Koala::Facebook::API.new(access_token)
    data         = graph.get_connections(self.f_id, "likes/#{ENV['FACEBOOK_FAN_PAGE']}")

    found = false
    data.each do |like|
      found = true if like['id'] == "#{ENV['FACEBOOK_FAN_PAGE']}"
    end
    return found
  end

  # If new user (no friends) or existing user and old update
  def has_to_build_friendships?
    if not self.friends_updated_at
      true
    elsif Time.now.to_date - self.friends_updated_at.to_date > DAYS_BEFORE_UPDATING_FRIENDS
      true
    else
      false
    end
  end

  # create new user for each friend and link it
  def build_friendships
    graph = Koala::Facebook::API.new(self.f_token)
    friends = graph.get_connections('me', 'friends')

    # update users and user_user_link relation
    friends.each do |friend|
      user = User.find_or_create_by_f_id(friend['id'])
      user.update_attributes!({ :name => friend['name'] })
      self.user_user_links.find_or_create_by_user_id_and_friend_id(self.f_id, user.f_id)
    end

    # delete user_user_link is not facebook friend anymore
    friend_ids = friends.collect{ |friend| friend['id'] }
    self.user_user_links.where('user_user_links.friend_id not in (?)', friend_ids).destroy_all

    self.update_attributes!({ :friends_updated_at => Time.now })
  end

  def profile_picture
    "https://graph.facebook.com/#{self.f_id}/picture?type=square"
  end

  # list of subscribed friends, user NOT INCLUDED, sorted by won levels (relative to one pack)
  def subscribed_friends(pack)
    friends = self.friends.registered.all
    join_users_to_pack_user_links_and_sort(friends, pack)
  end

  # list of subscribed friends, user INCLUDED, sorted by won levels (relative to one pack)
  def subscribed_friends_and_me(pack)
    friends = self.friends.registered.all + [self]
    join_users_to_pack_user_links_and_sort(friends, pack)
  end

  # n random popular friends
  # algo to maximize the selection of the people (registered or not) with a lot of registered friends
  # statisticaly we will select half the time a registered friend
  def popular_friends(n)
    registered_friends     = self.friends.registered.all
    not_registered_friends = self.friends.not_registered.order('friends_count DESC').limit(50).all
    popular_friends = []

    # array of friends of registered and not registered friends
    # [3, 55, 34, ...] means that first friend has 3 friends, second friend has 55 friends etc.
    friends_of_rf  = registered_friends.collect { |friend| friend.friends_count }
    friends_of_nrf = not_registered_friends.collect { |friend| friend.friends_count }

    # sum of the array of friends of registered and not registered friends
    # (in an array so we can later pass it by reference and get updated)
    sum_friends_of_rf  = [friends_of_rf.sum]
    sum_friends_of_nrf = [friends_of_nrf.sum]

    while popular_friends.size < n and (sum_friends_of_rf[0] != 0 or sum_friends_of_nrf[0] != 0)
      choice = rand(1..6)
      # select a registered popular friend
      if choice == 1 and sum_friends_of_rf[0] != 0
        popular_friends << select_one_user(registered_friends, friends_of_rf, sum_friends_of_rf)
      # select an not registered popular friend
      elsif choice.in? [2, 3, 4, 5, 6] and sum_friends_of_nrf[0] != 0
        popular_friends << select_one_user(not_registered_friends, friends_of_nrf, sum_friends_of_nrf)
      end
    end

    return popular_friends
  end

  def display_advertisement?
    Time.now >= self.send_invitations_at + DAYS_WITHOUT_ADS_IF_FRIENDS_INVITED.days.to_i
  end

  def display_friends_invite_popup?
    Time.now >= self.send_invitations_at + DAYS_WITHOUT_FRIENDS_INVITE_POPUP.days.to_i
  end

  private

  # update friends count (friends that are on the database : registered or not)
  def update_friends_count
    # registered user of not registered user
    if self.email
      self.friends_count = self.friends.count
    else
      self.friends_count = UserUserLink.where(:friend_id => self.f_id).count
    end
  end

  # select one random user depending on the common number of friends (the more friends, the more the chance to be selected)
  # users               : array of users [steve_object, paul_object, marc_object]
  # users_friends_count : array of friends num for each of these users [34,11,55] (steve has 34 friends)
  # total_user_friends  : sum of users_friends_count. ATTENTION : in an array ! (here : [100])
  # --> return user and update entry values
  def select_one_user(users, users_friends_count, total_user_friends)
    selected_user = nil
    rand_number = rand(total_user_friends[0])
    users_friends_count.each_with_index do |friends_count, index|
      if rand_number <= friends_count
        selected_user = users[index]
        # remove this user of the list
        total_user_friends[0] = total_user_friends[0] - friends_count
        users.delete_at(index)
        users_friends_count.delete_at(index)
        break
      else
        rand_number = rand_number - friends_count
      end
    end

    return selected_user
  end

  def join_users_to_pack_user_links_and_sort(friends, pack)
    friend_ids = friends.collect(&:id)
    User.where(:id => friend_ids)
        .select('users.*, pack_user_links.*')
        .joins(:pack_user_links).where('pack_user_links.pack_id = ?', pack.id)
        .sort {|x,y| y.won_levels_count <=> x.won_levels_count }
  end
end
