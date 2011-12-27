require 'test/unit'
ENV['RAILS_ENV'] = 'test'
load File.expand_path('../../bin/lifetracker', __FILE__)

class TC_testNothing < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  def test_the_truth
    GLI.run ['add', '12:00', '01:00', 'prj', 'Lifetracker - shoved off']
    assert_equal 1, Activity.count
  end
end
