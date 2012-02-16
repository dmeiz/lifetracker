class DayFormat
  def self.parse(text)
    [activity_lines(text).map {|line| line_to_hash(line)}, nil]
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
