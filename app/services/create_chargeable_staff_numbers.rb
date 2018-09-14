# This service accepts a "ruby representation" of a spreadsheet containing a
# list of {Person#staff_number staff numbers}. If a {ChargeableStaffNumber}
# already exists with the given +value+, that row is ignored.
#
# The {ReadSpreadsheet} service can convert an uploaded file into the
# representation expected by this service. See its documentation for a
# description of the spreadsheet "ruby representation."
class CreateChargeableStaffNumbers < UploadService
  TRUE_VALUES = ReadSpreadsheet::TRUE_VALUES

  # a ruby-representation of the uploaded spreadsheet file.  See
  # {ReadSpreadsheet}
  attr_accessor :sheets

  # whether existing {ChargeableStaffNumber} records should first be destroyed
  attr_accessor :delete_existing

  def call
    ChargeableStaffNumber.transaction do
      ChargeableStaffNumber.delete_all if delete_existing?

      numbers = sheets.flat_map { |rows| parse_staff_number_rows(rows) }
      numbers.each(&:save!)
    end
  rescue StandardError => e
    fail_job! message: e.message
  end

  private

  def delete_existing?
    TRUE_VALUES.include?(delete_existing)
  end

  def scope
    @scope ||= ChargeableStaffNumber.all
  end

  def parse_staff_number_rows(rows)
    count = rows.count.to_f

    rows.each_with_index.map do |row, index|
      update_percentage(index / count) if index.modulo(100).zero?

      staff_number = row[0].to_s.strip

      if staff_number.present?
        scope.find_or_create_by(staff_number: staff_number)
      end
    end.compact
  end
end
