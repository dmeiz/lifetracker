{
  # work tasks
  :per => 'Personal',
  :sto => 'Story',
  :un => 'Uncategorized',
  :oh => 'Overhead',
  :bug => 'Bugfix',

  # personal tasks
  :sle => 'Sleep',
  :eat => 'Eating',
  :par => 'Parenting',
  :prj => 'Personal project',
  :rel => 'Relaxing',
  :soc => 'Socializing',
  :cho => 'Chore'
}.each do |abbr, name|
  Category.create(:abbr => abbr, :name => name)
end

# a little development data in here too :(
unless Rails.env.production?
  day = Day.create(:dt => Date.today)

  day.activities.create!(
    :start_at => Time.now,
    :end_at => Time.now + 1.hour,
    :category => Category.find_by_abbr('per'),
    :memo => 'Sleeping'
  )
end
