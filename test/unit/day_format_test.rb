require 'test_helper'

class DayFormatTest < ActiveSupport::TestCase

  context '.parse' do
    setup do
      @category = Category.create(:abbr => 'per')
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
      data, error = DayFormat.parse(@text)
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
      data, error = DayFormat.parse(@text)
      assert_equal 2, data.length
    end
  end

  context '.format' do
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
      assert_equal expected_text, DayFormat.format(@day)
    end

    should 'show gaps in activities' do
      @activity2 = Activity.create!(
        :start_at => @end_at + 1.hour,
        :end_at => @end_at + 2.hours,
        :category => @category,
        :memo => 'Memo'
      )
      @day.activities << @activity2

      expected_text =<<END
#{@day.dt.to_s(:date)}

Start   End     Dur     Cat Memo
------- ------- ------- --- ------------------
#{@activity.start_at.to_s(:time).rjust(7)} #{@activity.end_at.to_s(:time).rjust(7)} #{('%.2f' % @activity.duration_in_hours).rjust(5)}hr #{@activity.category.abbr.upcase} #{@activity.memo}

#{@activity2.start_at.to_s(:time).rjust(7)} #{@activity2.end_at.to_s(:time).rjust(7)} #{('%.2f' % @activity2.duration_in_hours).rjust(5)}hr #{@activity2.category.abbr.upcase} #{@activity2.memo}
------- ------- ------- --- ------------------
                #{('%.2f' % (@activity.duration_in_hours + @activity2.duration_in_hours)).rjust(5)}hr
END

      assert_equal expected_text, DayFormat.format(@day)
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
      assert_equal expected_text, DayFormat.format(@day, :show_categories => true)
    end
  end

end
