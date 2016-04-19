class ApplicationController < ActionController::Base
  include AuthorizationFilters

  protect_from_forgery

  helper_method :current_user

  before_action :allow_iframe_requests
  before_action :set_gettext_locale
  before_action :check_facebook

  def allow_iframe_requests
    response.headers.delete('X-Frame-Options')
  end

  def current_user
    if Rails.env.development? && params[:force_user_slug]
      @current_user ||= User.find_by_slug(params[:force_user_slug])
      session[:user_id] = @current_user.id
      @current_user
    else
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    end
  end

  def check_facebook
    if current_user && current_user.f_expires_at < Time.now && Rails.env.production?                   # user is connected but session is expired
      redirect_to '/auth/facebook'
    # elsif not current_user and (params[:fb_source] or params[:signed_request])  # On each click on facebook to the application
    #   if params[:pack_id] and params[:id]                                       # if click on notification or feed with specific level, keep it on redirected params
    #     pack   = Pack.find(params[:pack_id])
    #     @level = pack.levels.find(params[:id])
    #   elsif params[:level_id]
    #     @level = Level.find(params[:level_id])                                  # if redirected by notification
    #   elsif params[:user_id]
    #     @user = User.find(params[:user_id])                                     # if redirected by notification
    #   end
    #   render 'layouts/canvas_redirect', :layout => false                        # canvas redirect to facebook oauth (register or log user)
    # elsif params[:controller].in?(['levels', 'packs']) and params[:level_id]
    #   @level = Level.find_by_id(params[:level_id])
    #   redirect_to pack_level_path(@level.pack, @level)
    end
  end

  private

  # delete this method when reverting to the default behaviour
  def set_gettext_locale
    session[:locale] = FastGettext.set_locale('en')
  end
end
