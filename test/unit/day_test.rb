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
      assert data = @day.parse(@text)
      assert_equal 2, data.length
      assert_equal({:start_at => Chronic.parse('8:15am'), :end_at => Chronic.parse('8:45am'), :category => @category, :memo => 'Morning routine'}, data.first)
      assert_equal({:start_at => Chronic.parse('8:45am'), :end_at => Chronic.parse('9:00am'), :category => @category, :memo => 'Morning routine'}, data.last)
    end

    # TODO: replace existing entries
    # TODO: report parse error
  end

  context 'to_s' do
    setup do
      @start_at = Time.now
      @end_at = @start_at + 1.hour
      @category = Category.create!(:name => 'Cat1', :abbr => 'ca1')
      @activity = Activity.create!(
        :start_at => @start_at,
        :end_at => @end_at,
        :category => @category,
        :memo => 'Memo'
      )
      @day = Day.create!
      @day.activities << @activity
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
  end
end
