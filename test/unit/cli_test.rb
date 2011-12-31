@@orig_stdout = $stdout
require 'test_helper'
load File.expand_path('../../../bin/lifetracker', __FILE__)

class CliTest < ActiveSupport::TestCase
  setup do
    $stdout = StringIO.new
    ENV['GLI_DEBUG'] = 'true'
  end

  context 'add' do
    setup do
      @category = Category.create(:name => 'Cat1', :abbr => 'cat1')
      @now = Time.now
      @command = ['add', @now.to_s('%h:%m'), (@now + 1.hour).to_s('%h:%m'), @category.abbr, 'Lifetracker - shoved off']
    end

    should 'add an activity' do
      GLI.run @command

      assert_equal "Added activity\n", $stdout.string

      assert_equal 1, Day.count, 'create day'
      assert day = Day.last, 'create day'
      assert_equal @now.to_date.jd, day.dt.jd, 'set dt'

      assert_equal 1, Activity.count
      activity = Activity.last
      assert_equal day, activity.day
      assert_equal @now.to_i, activity.start_at.to_i
      assert_equal (@now + 1.hour).to_i, activity.end_at.to_i
      assert_equal 'Lifetracker - shoved off', activity.memo
    end

    should 'use chronic' do
      @command[1] = 'now'
      @command[2] = 1.hour.from_now.to_s('%I%p') # "1pm"
      GLI.run @command
      activity = Activity.last
      assert_equal @now.to_i, activity.start_at.to_i
      assert_equal 1.hour.from_now.to_i, activity.end_at.to_i
    end
  end

  context 'show' do
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
      @command = ['show']
    end
    should 'show today' do
      GLI.run @command
expected_text =<<END
Start   End     Dur     Cat Memo
------- ------- ------- --- ------------------
#{@activity.start_at.to_s(:time).rjust(7)} #{@activity.end_at.to_s(:time).rjust(7)} #{('%.2f' % @activity.duration_in_hours).rjust(5)}hr #{@activity.category.abbr.upcase} #{@activity.memo}
------- ------- ------- --- ------------------
                #{('%.2f' % @activity.duration_in_hours).rjust(5)}hr
END
=begin
 8:15am  9:15am  0.50hr PER Morning routine
12:45am 12:15pm  3.00hr PER Breakfast
=end
      assert_equal expected_text, $stdout.string
    end
  end
end
