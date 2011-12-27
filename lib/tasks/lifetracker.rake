namespace :lifetracker do
  desc 'Populate database with categories'
  task :populate => :environment do
    Category.delete_all
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
  end
end
