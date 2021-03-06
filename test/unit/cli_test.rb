@@orig_stdout = $stdout
require 'test_helper'
load File.expand_path('../../../bin/lifetracker', __FILE__)

class CliTest < ActiveSupport::TestCase
  setup do
    $stdout = StringIO.new
    ENV['GLI_DEBUG'] = 'true'
    ENV['EDITOR'] = 'test/editor.sh'
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

  context 'edit' do
    setup do
      @now = Time.now
      @category = Category.create!(:name => 'Cat', :abbr => 'cat')
      @day = Day.create(:dt => Date.today)
      ENV['LIFETRACKER_EDITOR_OUTPUT'] = 'test/new_activity.txt'
      @command = ['edit']

      Lifetracker::Settings[:dot_dir] = 'tmp/dot_dir'
      #rm_rf(Lifetracker::Settings[:dot_dir])
      #mkdir_p(Lifetracker::Settings[:dot_dir])

      @temp_file = Tempfile.new 'lifetracker'
    end

    should 'update today' do
      GLI.run @command

      @day.reload
      assert_equal "Updated day\n\n#{DayFormat.format(@day)}", $stdout.string
      assert_equal 1, @day.activities.count
    end

    should 'update a specific day' do
      @command = ['edit', 'yesterday']
      GLI.run @command

      @day.reload
      assert_equal 0, @day.activities.count, 'don\'t update today'
      yesterday = Day.find_by_dt(Date.today - 1.day)
      assert_equal "Updated day\n\n#{DayFormat.format(yesterday)}", $stdout.string
      assert_equal 1, yesterday.activities.count
    end

    should 'use default_activity.txt file if available' do
      ENV['EDITOR'] = 'test/null_editor.sh'
      rm_rf(Lifetracker::Settings[:dot_dir])
      mkdir(Lifetracker::Settings[:dot_dir])
      File.open(File.join(Lifetracker::Settings[:dot_dir], 'default_activity.txt'), 'w') {|f| f.write(DEFAULT_ACTIVITY_TEXT)}
      
      @command = ['edit', 'yesterday']

      GLI.run @command

      yesterday = Day.find_by_dt(Date.today - 1.day)
      assert_equal "No changes\n", $stdout.string
      assert_equal 1, yesterday.activities.count
      assert_equal 'Breakfast', yesterday.activities.first.memo
    end
  end

  DEFAULT_ACTIVITY_TEXT = <<END
Start End   Dur   Cat    Memo
------ ----- ----- ---    ------------------
08:15a 08:45a 0.5hr cat    Breakfast
------ ----- ----- ---    ------------------
END

end
