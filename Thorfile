class Lifetracker < Thor
  desc 'sprint_summary', 'Display sprint summary'
  def sprint_summary
    system('sqlite3 -column ~/.lifetracker/production.sqlite3 < db/sql/sprint_summary.sql')
  end
end
