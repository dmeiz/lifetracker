class Activity < ActiveRecord::Base
  belongs_to :category
  belongs_to :day

  validates_presence_of :start_at, :end_at, :category

  before_save :fix_midnight_end_at

  def duration_in_hours
    return nil unless self.start_at && self.end_at
    (self.end_at - self.start_at).to_f/1.hour
  end

private

  # A 12AM end_at at the end of the day often get parsed as the beginning of
  # the day. Force it to the end of the day.
  #
  def fix_midnight_end_at
    if self.end_at == self.start_at.beginning_of_day
      self.end_at += 24.hours
    end
  end
end
