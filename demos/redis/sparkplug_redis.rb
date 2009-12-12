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
  'yo'
end

post '/:plug/:value' do
  $redis_list.add_datapoint(params[:plug], params[:value])
  'ok'
end

get '/:plug.json' do
  values = $redis_list.datapoints_for(params[:plug])
  "[#{values * ","}]"
end

get '/:plug' do
  $redis_list.datapoints_for(params[:plug]) * ", "
end

delete '/:plug' do
  $redis_list.delete params[:plug]
  'deleted'
end