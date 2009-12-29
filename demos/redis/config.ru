ENV['CONFIG'] = 'config.yml'
require File.dirname(__FILE__) + "/sparkplug_redis.rb"

set :run, false
set :environment, ENV['APP_ENV'] || :production

run Sinatra::Application
