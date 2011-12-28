require 'test_helper'
load File.expand_path('../../../bin/lifetracker', __FILE__)

class CliTest < ActiveSupport::TestCase
  context 'add' do
    should 'report errors' do
    debugger
      GLI.run ['add', '12:00', '01:00', 'prj', 'Lifetracker - shoved off']
      assert_equal 0, Activity.count
    end
  end
end
