require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  should validate_presence_of :memo
  should validate_presence_of :category

  context 'validations' do
    should 'assert truth' do
      assert true
    end
  end

  context 'duration_in_hours' do
    setup do
      @now = Time.now
      @activity = Activity.new(:start_at => @now, :end_at => @now + 1.hour)
    end

    should 'return duration' do
      assert_in_delta 1.0, @activity.duration_in_hours, 0.001
    end

    should 'return nil if end_at is nil' do
      @activity.end_at = nil
      assert_nil @activity.duration_in_hours
    end
  end
end
