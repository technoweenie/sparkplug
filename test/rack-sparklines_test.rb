require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rack'
require 'rack/test'
require 'rack-sparklines'
require 'rack-sparklines/stubbed_data'

class SparklinesTest < Test::Unit::TestCase
  include Rack::Test::Methods

  $data_dir = File.join(File.dirname(__FILE__), 'data')
  FileUtils.rm_rf   $data_dir
  FileUtils.mkdir_p $data_dir
  Rack::Sparklines::StubbedData.data['missing.csv'] = [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 20, 98, 34, 53, 1, 55, 74, 63, 38, 31, 98, 89]

  def app
    Rack::Sparklines.new \
      Proc.new {|env| [200, {"Content-Type" => "text/html"}, "booya"] },
      :handler   => Rack::Sparklines::StubbedData,
      :prefix    => '/sparks',
      :directory => $data_dir
  end

  def test_creates_png_from_csv_request
    assert !File.exist?(File.join($data_dir, 'missing.csv.png'))
    get "/sparks/missing.csv.png"
    assert  File.exist?(File.join($data_dir, 'missing.csv.png'))
  end
end
