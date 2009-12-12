require 'rubygems'
require 'test/unit'
require 'rack'
require 'rack/test'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'sparkplug_redis'

$redis_list.redis.flushall
$redis_list.prefix = 'test'
$redis_list.limit  = 5
$redis_list.add_datapoint 'sake',  1
$redis_list.add_datapoint 'sake',  2
$redis_list.add_datapoint 'sake',  3
$redis_list.add_datapoint 'unagi', 1

class RedisDemoTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root_url
    get '/'
    assert last_response.ok?
  end

  def test_adding_a_datapoint_for_new_plug
    get '/koi.json'
    assert_equal '[]', last_response.body

    post '/koi/5'
    assert last_response.ok?

    get '/koi.json'
    assert_equal '[5]', last_response.body
  end

  def test_datapoint_limit
    10.times do |i|
      post "/shiira/#{i + 5}"
    end
    get "/shiira.json"
    assert_equal "[10,11,12,13,14]", last_response.body
  end

  def test_fetching_csv_data_for_existing_slug
    get '/sake.json'
    assert_equal '[1,2,3]', last_response.body
  end

  def test_deletes_plug
    get '/unagi.json'
    assert_equal '[1]', last_response.body

    delete '/unagi'

    get '/unagi.json'
    assert_equal '[]', last_response.body
  end
end