require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rack'
require 'rack-test'
require 'rack-sparklines'

class SparklinesTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Rack::Sparklines.new(Proc.new {|env| [200, {"Content-Type" => "text/html"}, "booya"] })
  end
end
