class Day < ActiveRecord::Base
  has_many :activities

  def parse(text)
    activity_lines(text).map {|line| line_to_hash(line)}
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
