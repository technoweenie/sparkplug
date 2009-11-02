require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rack'
require 'rack/test'
require 'sparkplug'
require 'sparkplug/handlers/stubbed_data'
require 'sparkplug/handlers/csv_data'
require 'sparkplug/cachers/filesystem'
require 'sparkplug/cachers/memory'

class SparkplugTest < Test::Unit::TestCase
  include Rack::Test::Methods

  $data_dir     = File.join(File.dirname(__FILE__), 'data')
  $stubbed_data = [47, 43, 24, 47, 16, 28, 38, 57, 50, 76, 42, 20, 98, 34, 53, 1, 55, 74, 63, 38, 31, 98, 89]
  FileUtils.rm_rf   $data_dir
  FileUtils.mkdir_p $data_dir
  File.open File.join($data_dir, 'stats.csv'), 'wb' do |csv|
    csv << $stubbed_data.join(",")
  end
  sleep 1 # so that the timestamps don't match in the cache check test below

  def app
    Sparkplug.new \
      Proc.new {|env| [200, {"Content-Type" => "text/html"}, "booya"] },
      :handler => Sparkplug::Handlers::StubbedData.new('stats.csv' => {:updated => Time.utc(2009, 1, 1), :contents => $stubbed_data.dup}),
      :cacher  => Sparkplug::Cachers::Filesystem.new($data_dir),
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

class SparkplugCSVTest < SparkplugTest
  def app
    Sparkplug.new \
      Proc.new {|env| [200, {"Content-Type" => "text/html"}, "booya"] },
      :handler => Sparkplug::Handlers::CsvData.new($data_dir),
      :cacher  => Sparkplug::Cachers::Filesystem.new($data_dir),
      :prefix  => '/sparks'
  end
end

class SparkplugMemoryTest < SparkplugTest
  def app
    Sparkplug.new \
      Proc.new {|env| [200, {"Content-Type" => "text/html"}, "booya"] },
      :handler => Sparkplug::Handlers::StubbedData.new('stats.csv' => {:updated => Time.utc(2009, 1, 1), :contents => $stubbed_data.dup}),
      :cacher  => Sparkplug::Cachers::Memory.new,
      :prefix  => '/sparks'
  end

  def test_creates_png_from_csv_request
    get "/sparks/stats.csv.png"
    assert_equal 1503, last_response.body.size
  end

  def test_leaves_recent_cached_png
    # useless test for memory cacher
  end
end