class Float
  def decimal(precision = 2)
    ((self % 1) * 10.rpower(precision)).round
  end
end
