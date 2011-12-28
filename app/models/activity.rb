class Activity < ActiveRecord::Base
  belongs_to :category

  validates_presence_of :memo, :category
end
