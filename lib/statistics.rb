# frozen_string_literal: true

module Statistics
  module_function

  def mean(array)
    array = Array(array).compact
    return 0.0 if array.blank?

    array.sum.to_f / array.size
  end

  def median(array)
    array = Array(array).compact
    return 0.0 if array.blank?

    sorted = array.sort
    n = sorted.size
    mid = n / 2
    n.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]).to_f / 2
  end

  def standard_deviation(array)
    array = Array(array).compact
    return 0.0 if array.blank? || array.size < 2

    m = mean(array)
    sum = array.inject(0.0) { |acc, x| acc + (x - m)**2 }
    Math.sqrt(sum / (array.size - 1))
  end
end
