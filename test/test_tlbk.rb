require 'test/unit/active_support'
require 'active_support'
require './tlback.rb'

# require '../tlback.rb'

class TestTlbk < ActiveSupport::TestCase

  def test_get_client
    client = get_client
    assert_true(client.present?)
  end

  def test_backup_tl
    begin
      pg_exec_block do 
        old_count = @test_connection.exec("SELECT count(*) FROM TIMELINE")
      end
      assert_nothing_raised{ backup_tl }
      pg_exec_block do 
        new_count = @test_connection.exec("SELECT count(*) FROM TIMELINE")
      end
      assert_block{ old_count[0]["count"] < new_count[0]["count"] }
    ensure
      @test_connection.finish if ! @test_conection.nil?
    end
  end
end
