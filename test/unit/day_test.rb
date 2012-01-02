require 'test_helper'

class DayTest < ActiveSupport::TestCase
  context 'parse' do
    setup do
      @category = Category.create(:abbr => 'per')
      @day = Day.new
      @text = <<END
some arbitrary header text

Start End   Dur   Cat    Memo
------ ----- ----- ---    ------------------
08:15a 08:45a 0.5hr PER    Morning routine
08:45a 9     0.5hr PER    Morning routine
------ ----- ----- ---    ------------------
          1.0hr

arbitrary footer text
END
    end

    should 'parse a day' do
      data, error = @day.parse(@text)
      assert data
      assert_equal 2, data.length
      assert_equal({:start_at => Chronic.parse('8:15am'), :end_at => Chronic.parse('8:45am'), :category => @category, :memo => 'Morning routine'}, data.first)
      assert_equal({:start_at => Chronic.parse('8:45am'), :end_at => Chronic.parse('9:00am'), :category => @category, :memo => 'Morning routine'}, data.last)
    end

    should 'ignore blank lines' do
      @text = <<END
------ ----- ----- ---    ------------------

08:15a 08:45a 0.5hr PER    Morning routine
\t
08:45a 9     0.5hr PER    Morning routine

------ ----- ----- ---    ------------------
END
      data, error = @day.parse(@text)
      assert_equal 2, data.length
    end
  end

  context 'to_s' do
    setup do
      @start_at = Time.now
      @end_at = @start_at + 1.hour
      @category = Category.create!(:name => 'Cat1', :abbr => 'ca1')
      @day = Day.create!
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
Start   End     Dur     Cat Memo
------- ------- ------- --- ------------------
#{@activity.start_at.to_s(:time).rjust(7)} #{@activity.end_at.to_s(:time).rjust(7)} #{('%.2f' % @activity.duration_in_hours).rjust(5)}hr #{@activity.category.abbr.upcase} #{@activity.memo}
------- ------- ------- --- ------------------
                #{('%.2f' % @activity.duration_in_hours).rjust(5)}hr
END
      assert_equal expected_text, @day.to_s
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
        @day = Day.create!
        @day.activities << @activity

        @activity_data = [
          {:start_at => @end_at, :end_at => @end_at + 1.hour, :category => @category2, :memo => 'Changed'}
        ]
      end

      should 'accept a hash of activity data and update the day' do
        @day.update_activities(@activity_data)

        @day.reload
        assert_equal 1, @day.activities.count
        activity = @day.activities.first
        assert_equal @activity_data.first[:start_at].to_i, activity.start_at.to_i
        assert_equal @activity_data.first[:end_at].to_i, activity.end_at.to_i
        assert_equal @activity_data.first[:category], activity.category
        assert_equal @activity_data.first[:memo], activity.memo
      end
    end
  end
end
