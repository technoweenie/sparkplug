require File.dirname(__FILE__) + "/../demos/simple/sparkplug_demo.rb"

set :run, false
set :env, ENV['APP_ENV'] || :production

run Sinatra::Application
