class Activity < ActiveRecord::Base
  belongs_to :category
  belongs_to :day

  validates_presence_of :memo, :category

  def duration_in_hours
    return nil unless self.start_at && self.end_at
    (self.end_at - self.start_at).to_f/1.hour
  end
end
