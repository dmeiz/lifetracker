class Lifetracker < Thor
  desc 'hours_per_day', 'Display sprint summary'
  def hours_per_day
    system('sqlite3 -column ~/.lifetracker/production.sqlite3 < db/sql/hours_per_day.sql')
  end

  desc 'mh_summary', 'Display mh summary'
  def mh_summary
    system('sqlite3 -column ~/.lifetracker/production.sqlite3 < db/sql/mh_summary.sql')
  end

  desc 'life_summary', 'Display life summary'
  def life_summary
    system('sqlite3 -column ~/.lifetracker/production.sqlite3 < db/sql/life_summary.sql')
  end
end
