require 'csv'
class Report < ApplicationRecord
  def result
    @result ||= Report.connection.select_all(query)
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << result.columns

      result.each do |row|
        csv << row
      end
    end
  end
end
