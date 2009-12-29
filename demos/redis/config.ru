require File.dirname(__FILE__) + "/sparkplug_redis.rb"
ENV['CONFIG'] = 'config.yml'

set :run, false
set :environment, ENV['APP_ENV'] || :production

run Sinatra::Application
