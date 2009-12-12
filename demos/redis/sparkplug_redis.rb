$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'sinatra'
require 'redis'
require 'time'

require 'sparkplug'
require 'redis_demo/spark_list'
require 'redis_demo/handler'

$handler    = RedisDemo::Handler.new
$redis_list = $handler.list
pub_dir     = File.expand_path(File.join(File.dirname(__FILE__), 'public'))
use Sparkplug, :prefix => 'sparks',
  :handler => $handler,
  :cacher  => Sparkplug::Cachers::Filesystem.new(File.join(pub_dir, 'sparks'))

get '/' do
  @plug_list = $redis_list.plug_list
  erb :show
end

post '/modify' do
  case params[:commit]
    when /delete/i
      $redis_list.find(params[:plug]).delete
      redirect '/'
    else
      plug = $redis_list.find(params[:plug])
      plug.add(params[:value])
      redirect "/#{params[:plug]}"
  end
end

post '/:plug/:value' do
  plug = $redis_list.find(params[:plug])
  plug.add(params[:value])
  'ok'
end

get '/:plug.json' do
  plug = $redis_list.find(params[:plug])
  "[#{plug.datapoints * ","}]"
end

get '/:plug' do
  @plug_list = $redis_list.plug_list
  @plug      = $redis_list.find(params[:plug])
  erb :show
end

delete '/:plug' do
  plug = $redis_list.find(params[:plug])
  plug.delete
  'deleted'
end

def h(s)
  Rack::Utils.escape(s)
end