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
end
