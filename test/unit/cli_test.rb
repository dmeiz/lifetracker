@@orig_stdout = $stdout
require 'test_helper'
load File.expand_path('../../../bin/lifetracker', __FILE__)

class CliTest < ActiveSupport::TestCase
  context 'add' do
    setup do
      @category = Category.create(:name => 'Cat1', :abbr => 'cat1')
      $stdout = StringIO.new
    end

    should 'add an activity' do
      GLI.run ['add', '12:00', '01:00', @category.abbr, 'Lifetracker - shoved off']
      assert_equal 1, Activity.count
      assert_equal "Added activity\n", $stdout.string
      activity = Activity.last
      assert_equal 'Lifetracker - shoved off', activity.memo
    end
  end
end
