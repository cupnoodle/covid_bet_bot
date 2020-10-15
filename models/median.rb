class Array
  def median
    sorted = self.sort
    size = sorted.size
    center = size / 2

    if size == 0
      nil
    elsif size.even?
      (sorted[center - 1] + sorted[center]) / 2.0
    else
      sorted[center]
    end
  end
end