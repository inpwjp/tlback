require 'test/unit/active_support'
require 'active_support'
require './tlback.rb'

# require '../tlback.rb'

class TestTlbk < ActiveSupport::TestCase
  def test_get_client
    client = get_client
    assert_true(client.present?)
  end
end
