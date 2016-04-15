require 'coffee-rails'

# compile coffee file that will be loaded by the server in javascript
# to reuse the level methods in ruby
def compile_coffee_to_js
  files = ['level_core', 'path_core', 'deadlock_core']
  files.each do |file|
    if File.exist?("lib/assets/#{file}.js")
      File.delete("lib/assets/#{file}.js")
    end
    compile_file_coffee_to_js("app/assets/javascripts/game/models/#{file}.js.coffee", "lib/assets/#{file}.js")
  end
end

def compile_file_coffee_to_js(coffee_file, js_file)
  coffee = CoffeeScript.compile File.read(coffee_file)
  File.open(js_file, 'w') do |f|
    f.puts coffee
  end
end

namespace :app  do
  task :setup do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      # the ruby version is automatically defined in the .rbenv-version file
      [ 'git submodule update --init --recursive',           # get submodules of this project
        'git submodule foreach git pull origin master',      # update submodules of this project
        'rm log/development.log',                            # rm log files
        'touch log/development.log',                         # rm log files
        'rm log/production.log',                             # rm log files
        'touch log/production.log',                          # rm log files
        'rm log/delayed_job.log',                            # rm log files
        'touch log/delayed_job.log',                         # rm log files
        'rm log/test.log',                                   # rm log files
        'touch log/test.log',                                # rm log files
        'rm chromedriver.log',                               # rm log files
        'bundle install',                                    # install gem dependencies
        "/bin/bash #{Dir.pwd}/script/rename_tab.sh Server"   #
      ].each do |command|
        puts command
        system(command)
      end

      compile_coffee_to_js()

      # Launch server
      system('foreman start -f Procfile.development')
    end
  end

  task :reset => :environment do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      compile_coffee_to_js()

      system('rake db:migrate:reset')
      system('rake db:seed')
    end
  end

  # compile core class from coffeescript to javascript to be used with ruby
  task :compile_coffee => :environment do
    if Rails.env.production?
      puts "Cannot use this task in production"
    else
      compile_coffee_to_js()
    end
  end

  task :facebook_feed_delayed_job => :environment do
    publish_jobs = Delayed::Job.where(:queue => 'publish_random_level')
    if publish_jobs.empty?
      FacebookFeedService.delayed_publish_random_level
    else
      run_at = publish_jobs.first.run_at
      publish_jobs.destroy_all
      FacebookFeedService.delay(:run_at => run_at, :queue => 'publish_random_level').publish_random_level(true)
    end
  end

  task :send_mailing_delayed_job => :environment do
    MailingService.delayed_send_mailing
  end

  task :flush_cache => :environment do
    Rails.cache.clear
  end
end

