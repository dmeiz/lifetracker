require 'test_helper'

class DayTest < ActiveSupport::TestCase

  context 'initialize_with_activity_text' do
    setup do
      @category = Category.create(:abbr => 'per')
      @day = Day.create(:dt => Date.today)
      @text =<<END
Start End   Dur   Cat    Memo
------ ----- ----- ---    ------------------
08:15a 08:45a 0.5hr PER    Breakfast
08:45a 9     0.5hr PER    Commute
------ ----- ----- ---    ------------------
END
    end

    should 'initialize a day' do
      @day.initialize_with_activity_text(@text)

      @day.reload
      assert_equal 2, @day.activities.count

      activity = @day.activities[0]
      assert_equal 'Breakfast', activity.memo

      activity = @day.activities[1]
      assert_equal 'Commute', activity.memo
    end
  end

  context 'to_s' do
    setup do
      @start_at = Time.now
      @end_at = @start_at + 1.hour
      @category = Category.create!(:name => 'Cat1', :abbr => 'ca1')
      @day = Day.create!(:dt => Date.today)
      @activity = Activity.create!(
        :start_at => @start_at,
        :end_at => @end_at,
        :category => @category,
        :memo => 'Memo'
      )
      @day.activities << @activity

      @yesterday = Day.create(:dt => (Date.today - 1.day))
      @yesterday_activity = Activity.create!(
        :start_at => @start_at,
        :end_at => @end_at,
        :category => @category,
        :memo => 'Memo'
      )
      @yesterday.activities << @yesterday_activity
    end

    should 'print the day' do
      expected_text =<<END
#{@day.dt.to_s(:date)}

Start   End     Dur     Cat Memo
------- ------- ------- --- ------------------
#{@activity.start_at.to_s(:time).rjust(7)} #{@activity.end_at.to_s(:time).rjust(7)} #{('%.2f' % @activity.duration_in_hours).rjust(5)}hr #{@activity.category.abbr.upcase} #{@activity.memo}
------- ------- ------- --- ------------------
                #{('%.2f' % @activity.duration_in_hours).rjust(5)}hr
END
      assert_equal expected_text, @day.to_s
    end

    should 'include categories if requested' do
      expected_text =<<END
#{@day.dt.to_s(:date)}

#{@category.abbr} #{@category.name}

Start   End     Dur     Cat Memo
------- ------- ------- --- ------------------
#{@activity.start_at.to_s(:time).rjust(7)} #{@activity.end_at.to_s(:time).rjust(7)} #{('%.2f' % @activity.duration_in_hours).rjust(5)}hr #{@activity.category.abbr.upcase} #{@activity.memo}
------- ------- ------- --- ------------------
                #{('%.2f' % @activity.duration_in_hours).rjust(5)}hr
END
      assert_equal expected_text, @day.to_s(:show_categories => true)
      
    end
  end

  context 'update_activities' do
    setup do
      @start_at = Time.now
      @end_at = @start_at + 1.hour
      @category = Category.create!(:name => 'Cat1', :abbr => 'ca1')
      @category2 = Category.create!(:name => 'Cat2', :abbr => 'ca2')
      @activity = Activity.create!(
        :start_at => @start_at,
        :end_at => @end_at,
        :category => @category,
        :memo => 'Memo'
      )
      @day = Day.create!(:dt => Date.today)
      @day.activities << @activity

      @activity_data = [
        {:start_at => @end_at, :end_at => @end_at + 1.hour, :category => @category2, :memo => 'Changed'}
      ]
    end

    should 'accept a hash of activity data and update the day' do
      @day.update_activities(@activity_data)

      assert_equal 1, Activity.count
      assert_equal 1, @day.activities.count
      activity = @day.activities.first
      assert_equal @activity_data.first[:start_at].to_i, activity.start_at.to_i
      assert_equal @activity_data.first[:end_at].to_i, activity.end_at.to_i
      assert_equal @activity_data.first[:category], activity.category
      assert_equal @activity_data.first[:memo], activity.memo
    end

    should 'ensure that date part of start_at and end_at are the same as day' do
      @activity_data.first[:start_at] = @start_at - 1.day
      @activity_data.first[:end_at] = @end_at - 1.day
      @day.update_activities(@activity_data)

      @day.reload
      assert_equal @start_at.to_i, @day.activities.first[:start_at].to_i
      assert_equal @end_at.to_i, @day.activities.first[:end_at].to_i
    end
  end
end
