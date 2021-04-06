class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.filter(filters)
    results = self.where(nil)

    filters.each do |key, value|
      results = results.send(key, value)
    end

    results
  end

  def self.final_date_filter(date)
    Time.parse(date) + 1.day
  end
end
