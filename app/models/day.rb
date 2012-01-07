class Day < ActiveRecord::Base
  has_many :activities

  def parse(text)
    [activity_lines(text).map {|line| line_to_hash(line)}, nil]
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

  def to_s(options = {})
    s = <<END
#{self.dt.to_s(:date)}

END

    if options[:show_categories]
      Category.order(:abbr).all.each do |category|
        s += <<END
#{category.abbr.ljust(3)} #{category.name}
END
      end
      s += "\n"
    end
    s += <<END
Start   End     Dur     Cat Memo
------- ------- ------- --- ------------------
END
    total_duration = 0
    self.activities.each do |activity|
      total_duration += activity.duration_in_hours
      s += <<END
#{activity.start_at.to_s(:time).rjust(7)} #{activity.end_at.to_s(:time).rjust(7)} #{('%.2f' % activity.duration_in_hours).rjust(5)}hr #{activity.category.abbr.upcase} #{activity.memo}
END
    end
    s += <<END
------- ------- ------- --- ------------------
                #{('%.2f' % total_duration).rjust(5)}hr
END
    s
  end

  private

  # Returns array of lines of activity data, ignoring text before and after
  # separator lines.
  # 
  def activity_lines(text)
    lines = text.split("\n")
    lines = lines.drop_while {|line| line !~ /^[- ]+$/ }
    lines = lines.drop(1)
    lines = lines.take_while {|line| line !~ /^[- ]+$/ }
    lines.reject {|line| line.blank?}
  end

  # Parse line into a Activity-compatible hash.
  #
  def line_to_hash(line)
    tokens = line.split(/\s+/)
    {
      :start_at => Chronic.parse(tokens[0]),
      :end_at => Chronic.parse(tokens[1]),
      :category => Category.find_by_abbr(tokens[3].downcase),
      :memo => tokens[4..-1].join(' ')
    }
  end

  # Ensure time is on the same date as self.
  #
  def sync_time(time)
    Time.local(self.dt.year, self.dt.mon, self.dt.mday, time.hour, time.min, time.sec)
  end
end
