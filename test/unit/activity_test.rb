require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  should validate_presence_of :memo
  context 'validations' do
    should 'assert truth' do
      assert true
    end
  end
end
