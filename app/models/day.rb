class Day < ActiveRecord::Base
  has_many :activities

  def initialize_with_activity_text(text)
    self.update_activities(DayFormat.parse(text).first)
  end

  # Replaces this days activities with those specified by attributes in arr.
  #
  def update_activities(arr)
    self.activities.destroy_all
    arr.each do |atts|
      self.activities.create!(atts.merge({
        :start_at => sync_time(atts[:start_at]),
        :end_at => sync_time(atts[:end_at])
      }))
    end
  end

  private

  # Ensure time is on the same date as self.
  #
  def sync_time(time)
    Time.local(self.dt.year, self.dt.mon, self.dt.mday, time.hour, time.min, time.sec)
  end
end
