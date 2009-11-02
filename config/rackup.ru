require File.dirname(__FILE__) + "/../demo/sparkplug_demo.rb"

set :run, false
set :env, ENV['APP_ENV'] || :production

run Sinatra::Application
