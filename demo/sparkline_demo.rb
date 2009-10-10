$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'sinatra'

require 'rack-sparklines'
require 'rack-sparklines/handlers/csv_data'
require 'rack-sparklines/cachers/filesystem'

pub_dir = File.expand_path(File.join(File.dirname(__FILE__), 'public'))
use Rack::Sparklines, :prefix => 'sparks',
  :handler => Rack::Sparklines::Handlers::CsvData.new(File.join(pub_dir, 'temps')),
  :cacher  => Rack::Sparklines::Cachers::Filesystem.new(File.join(pub_dir, 'sparks'))

get '/' do
  'yo'
end