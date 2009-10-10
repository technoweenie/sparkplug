$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'sinatra'

require 'rack-sparklines'
require 'rack-sparklines/handlers/csv_data'
require 'rack-sparklines/cachers/memory'

pub_dir = File.expand_path(File.join(File.dirname(__FILE__), 'public'))
use Rack::Sparklines, :prefix => 'sparks',
  :handler => Rack::Sparklines::Handlers::CsvData.new(File.join(pub_dir, 'temps')),
  :cacher  => Rack::Sparklines::Cachers::Memory.new

get '/' do
  @body = $readme
  erb :readme
end

def simple_format(text)
  start_tag = "<p>"
  text = text.to_s.dup
  text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
  text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")  # 2+ newline  -> paragraph
  text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
  text.insert 0, start_tag
  text << "</p>"
end

$readme = simple_format IO.read(File.join(File.dirname(__FILE__), '..', 'README.rdoc'))