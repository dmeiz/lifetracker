class Day < ActiveRecord::Base
  has_many :activities

  def parse(text)
    activity_lines(text).map {|line| line_to_hash(line)}
  end

  def to_s
    s = <<END
Start   End     Dur     Cat Memo
------- ------- ------- --- ------------------
END
    total_duration = 0
    Activity.all.each do |activity|
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

  # Strip text of anything above and below the separator lines.
  # 
  def activity_lines(text)
    lines = text.split("\n")
    lines = lines.drop_while {|line| line !~ /^[- ]+$/ }
    lines = lines.drop(1)
    lines = lines.take_while {|line| line !~ /^[- ]+$/ }
    lines
  end

  def line_to_hash(line)
    tokens = line.split(/\s+/)
    {
      :start_at => Chronic.parse(tokens[0]),
      :end_at => Chronic.parse(tokens[1]),
      :category => Category.find_by_abbr(tokens[3].downcase),
      :memo => tokens[4..-1].join(' ')
    }
  end
end
