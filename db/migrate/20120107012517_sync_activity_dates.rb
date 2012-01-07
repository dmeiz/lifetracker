class SyncActivityDates < ActiveRecord::Migration
  def up
    Day.all.each do |day|
      day.update_activities(day.parse(day.to_s).first)
    end
  end

  def down
  end
end
