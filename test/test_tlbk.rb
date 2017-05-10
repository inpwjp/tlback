require 'test/unit/active_support'
require 'active_support'
require './tlback.rb'

# require '../tlback.rb'

class TestTlbk < ActiveSupport::TestCase
  def setup
    settings = load_settings
    @test_connection = PG::connect(host: settings["postgresql"]["host"], user: settings["postgresql"]["user"],password: settings["postgresql"]["password"], dbname: settings["postgresql"]["dbname"], port: settings["postgresql"]["port"])
  end

  def teardown
    @test_connection.finish
  end

  def test_get_client
    client = get_client
    assert_true(client.present?)
  end

  def test_backup_tl
    old_count = @test_connection.exec("SELECT count(*) FROM TIMELINE")
    assert_nothing_raised{ backup_tl }
    new_count = @test_connection.exec("SELECT count(*) FROM TIMELINE")
    assert_block{ old_count[0]["count"] < new_count[0]["count"] }
  end

end
