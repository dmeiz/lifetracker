class DayFormat
  def self.parse(text)
    [activity_lines(text).map {|line| line_to_hash(line)}, nil]
  end

  def self.format(day, options = {})
    s = <<END
#{day.dt.to_s(:date)}

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
    day.activities.each_with_index do |activity, i|
      total_duration += activity.duration_in_hours
      if (i > 0) && (day.activities[i - 1].end_at != activity.start_at)
        s += "\n"
      end
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

  def self.activity_lines(text)
    lines = text.split("\n")
    lines = lines.drop_while {|line| line !~ /^[- ]+$/ }
    lines = lines.drop(1)
    lines = lines.take_while {|line| line !~ /^[- ]+$/ }
    lines.reject {|line| line.blank?}
  end

  def self.line_to_hash(line)
    tokens = line.split(/\s+/)
    {
      :start_at => Chronic.parse(tokens[0]),
      :end_at => Chronic.parse(tokens[1]),
      :category => Category.find_by_abbr(tokens[3].downcase),
      :memo => tokens[4..-1].join(' ')
    }
  end
end
