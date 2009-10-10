require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rack'
require 'rack/test'
require 'rack-sparklines'
require 'rack-sparklines/handlers/stubbed_data'
require 'rack-sparklines/handlers/csv_data'

class SparklinesTest < Test::Unit::TestCase
  include Rack::Test::Methods

  $data_dir = File.join(File.dirname(__FILE__), 'data')
  FileUtils.rm_rf   $data_dir
  FileUtils.mkdir_p $data_dir
  File.open File.join($data_dir, 'missing.csv'), 'wb' do |csv|
    csv << "47,43,24,47,16,28,38,57,50,76,42,20,98,34,53,1,55,74,63,38,31,98,89"
  end
  sleep 1
  Rack::Sparklines::Handlers::StubbedData.data['missing.csv'] = \
    {:updated => Time.utc(2009, 1, 1), :contents => [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 20, 98, 34, 53, 1, 55, 74, 63, 38, 31, 98, 89]}

  def app
    Rack::Sparklines.new \
      Proc.new {|env| [200, {"Content-Type" => "text/html"}, "booya"] },
      :handler   => Rack::Sparklines::Handlers::StubbedData,
      :prefix    => '/sparks',
      :directory => $data_dir
  end

  def setup
    @missing_png = File.join($data_dir, 'missing.csv.png')
    FileUtils.rm_rf @missing_png
  end

  def test_creates_png_from_csv_request
    assert !File.exist?(@missing_png)
    get "/sparks/missing.csv.png"
    assert  File.exist?(@missing_png)
    assert  File.size(@missing_png) > 0
    assert_equal IO.read(@missing_png), last_response.body
  end

  def test_leaves_recent_cached_png
    FileUtils.touch(@missing_png)
    get "/sparks/missing.csv.png"
    assert_equal '', last_response.body
    assert_equal 0, File.size(@missing_png)
  end

  def test_lets_other_requests_fallthrough
    assert !File.exist?(@missing_png)
    get "/spark/missing.csv.png"
    assert_equal 'booya', last_response.body
    assert !File.exist?(@missing_png)
  end
end

class SparklinesCSVTest < SparklinesTest
  Rack::Sparklines::Handlers::CsvData.directory = $data_dir

  def app
    Rack::Sparklines.new \
      Proc.new {|env| [200, {"Content-Type" => "text/html"}, "booya"] },
      :handler   => Rack::Sparklines::Handlers::CsvData,
      :prefix    => '/sparks',
      :directory => $data_dir
  end
end