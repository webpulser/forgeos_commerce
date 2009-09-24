class Float
  def decimal(precision = 2)
    ((self % 1) * 10.rpower(precision)).round
  end
  
  def diff(number)
    return 0 if number.zero?
    (((self - number) / number)* 100).round
  end
end
