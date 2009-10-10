require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rack'
require 'rack/test'
require 'rack-sparklines'
require 'rack-sparklines/handlers/stubbed_data'
require 'rack-sparklines/handlers/csv_data'
require 'rack-sparklines/cachers/filesystem'

class SparklinesTest < Test::Unit::TestCase
  include Rack::Test::Methods

  $data_dir     = File.join(File.dirname(__FILE__), 'data')
  $stubbed_data = {:updated => Time.utc(2009, 1, 1), :contents => [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 20, 98, 34, 53, 1, 55, 74, 63, 38, 31, 98, 89]}
  FileUtils.rm_rf   $data_dir
  FileUtils.mkdir_p $data_dir
  File.open File.join($data_dir, 'stats.csv'), 'wb' do |csv|
    csv << $stubbed_data[:contents].join(",")
  end
  sleep 1 # so that the timestamps don't match in the cache check test below

  def app
    Rack::Sparklines.new \
      Proc.new {|env| [200, {"Content-Type" => "text/html"}, "booya"] },
      :handler => Rack::Sparklines::Handlers::StubbedData.new('stats.csv' => $stubbed_data),
      :cacher  => Rack::Sparklines::Cachers::Filesystem.new($data_dir),
      :prefix  => '/sparks'
  end

  def setup
    @stats_png = File.join($data_dir, 'stats.csv.png')
    FileUtils.rm_rf @stats_png
  end

  def test_creates_png_from_csv_request
    assert !File.exist?(@stats_png)
    get "/sparks/stats.csv.png"
    assert  File.exist?(@stats_png)
    assert  File.size(@stats_png) > 0
    assert_equal IO.read(@stats_png), last_response.body
  end

  def test_leaves_recent_cached_png
    FileUtils.touch(@stats_png)
    get "/sparks/stats.csv.png"
    assert_equal '', last_response.body
    assert_equal 0, File.size(@stats_png)
  end

  def test_lets_other_requests_fallthrough
    assert !File.exist?(@stats_png)
    get "/spark/stats.csv.png"
    assert_equal 'booya', last_response.body
    assert !File.exist?(@stats_png)
  end

  def test_passes_missing_data_requests_through
    get "/sparks/404.csv.png"
    assert_equal 'booya', last_response.body
  end
end

class SparklinesCSVTest < SparklinesTest
  def app
    Rack::Sparklines.new \
      Proc.new {|env| [200, {"Content-Type" => "text/html"}, "booya"] },
      :handler => Rack::Sparklines::Handlers::CsvData.new($data_dir),
      :cacher  => Rack::Sparklines::Cachers::Filesystem.new($data_dir),
      :prefix  => '/sparks'
  end
end