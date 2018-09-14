# The {ReadSpreadsheet} service can convert an uploaded file into the
# representation expected by this service. See its documentation for a
# description of the spreadsheet "ruby representation."
class CreateHousingUnits < UploadService
  RowRecord = Struct.new(:record, :import)
  Error = Class.new(StandardError)

  # a ruby-representation of the uploaded spreadsheet file.  See
  # {ReadSpreadsheet}
  attr_accessor :sheets

  attr_accessor :skip_first

  i18n_scope :housing_unit

  # Create each {HousingUnit} referenced in the given sheets.
  def call
    import_models = parse_sheets
    row_records = build_models(import_models)
    save_all!(row_records)
  rescue StandardError => e
    fail_job! message: e.message
  end

  private

  def parse_sheets
    sheets.flat_map do |rows|
      count = rows.count.to_f

      rows.each_with_index.map do |row, index|
        update_percentage(index / count) if index.modulo(100).zero?
        create_from_row(row, index)
      end
    end
  end

  def create_from_row(row, index)
    row_number = index + (skip_first ? 2 : 1)
    Import::HousingUnit.from_array(row_number, row)
  end

  def build_models(import_models)
    import_models.map do |import|
      begin
        facility = find_facility(import.facility_name)
        unless import.exists_in?(facility)
          RowRecord.new(
            import.build_record(facility),
            import
          )
        end
      rescue StandardError => e
        raise Error, format('Row #%d: %p', import.row, e.message)
      end
    end.compact
  end

  def find_facility(name)
    housing_facilities.find { |f| f.name == name }.tap do |facility|
      raise Error, t('errors.no_facility', name: name) if facility.nil?
    end
  end

  def housing_facilities
    @housing_facilities ||= HousingFacility.all.includes(:housing_units)
  end

  def save_all!(row_records)
    HousingFacility.transaction do
      row_records.each do |row_record|
        record = row_record.record
        begin
          record.save!
        rescue StandardError => e
          raise Error, format('Row #%d: Could not persist %s, %p. %s',
                              row_record.import.row, record.class.name,
                              record.audit_name, e.message)
        end
      end
    end
  end
end
