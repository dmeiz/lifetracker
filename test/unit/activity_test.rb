require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  should validate_presence_of :category
  should validate_presence_of :start_at
  should validate_presence_of :end_at


  context 'validations' do
    should 'assert truth' do
      assert true
    end
  end

  context 'callbacks' do
    should 'adjust end_at to correctly handle 12am' do
      @category = Category.create!(:name => 'Foo', :abbr => 'foo')
      @start_at = Time.local(2012, 1, 4, 11, 0, 0)
      @end_at = Time.local(2012, 1, 4, 0, 0, 0)
      @activity = Activity.create!(:start_at => @start_at, :end_at => @end_at, :category => @category, :memo => 'Memo')
      assert_equal (@end_at + 24.hours).to_i, @activity.end_at.to_i
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
