# This service accepts a "ruby representation" of a spreadsheet containing a
# list of code/name pairs. Each row represents either a new or existing
# {Ministry Ministry's} +code+ and +name+. If a {Ministry} already exists with
# the given +code+, it's +name+ will be updated with the name given in the
# spreadsheet.
#
# The {ReadSpreadsheet} service can convert an uploaded file into the
# representation expected by this service. See its documentation for a
# description of the spreadsheet "ruby representation."
class Ministry::CreateOrUpdate < UploadService
  TooFewColumnsError = Class.new(StandardError)

  # +Enumerable+
  #   A ruby-representation of the uploaded spreadsheet file.  See
  #   {ReadSpreadsheet}
  attr_accessor :sheets

  job_stage 'Create New Ministry Records'
  i18n_scope 'ministry'

  # Create or update each {Ministry} referenced in the given sheets.
  def call
    Ministry.transaction do
      sheets.each(&method(:parse_ministry_rows))
      ministries.each(&:save!)
    end
  rescue StandardError => e
    fail_job! message: e.message
  end

  private

  def parse_ministry_rows(rows)
    count = rows.count.to_f

    rows.each_with_index do |row, i|
      update_percentage(i / count) if i.modulo(100).zero?

      row = row.map(&:strip).select(&:present?)

      if row.size < 2
        raise TooFewColumnsError,
              t('errors.too_few_columns', i + 1, row.join(', '))
      end

      create_or_update(row[0], row[1])
    end
  end

  def create_or_update(code, name)
    if (existing = find_by(code: code))
      existing.name = name
    else
      ministries.push(Ministry.new(code: code, name: name))
    end
  end

  def find_by(code:)
    ministries.find { |m| m.code == code }
  end

  def ministries
    @ministries ||= Ministry.all.to_a
  end
end
