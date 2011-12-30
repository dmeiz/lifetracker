@@orig_stdout = $stdout
require 'test_helper'
load File.expand_path('../../../bin/lifetracker', __FILE__)

class CliTest < ActiveSupport::TestCase
  context 'add' do
    setup do
      @category = Category.create(:name => 'Cat1', :abbr => 'cat1')
      $stdout = StringIO.new
      @now = Time.now
    end

    should 'add an activity' do
      GLI.run ['add', @now.to_s('%h:%m'), (@now + 1.hour).to_s('%h:%m'), @category.abbr, 'Lifetracker - shoved off']
      assert_equal 1, Activity.count
      assert_equal "Added activity\n", $stdout.string
      activity = Activity.last
      assert_equal @now.utc.to_i, activity.start_at.to_i
      assert_equal (@now + 1.hour).to_i, activity.end_at.to_i
      assert_equal 'Lifetracker - shoved off', activity.memo
    end
  end
end
