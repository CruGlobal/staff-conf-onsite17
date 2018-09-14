# This service accepts an uploaded spreadsheet file and converts it into a
# "ruby-representation" of that spreadsheet, which can then be processed by
# other services.
#
# == Spreadsheet file
#
# This service can accept four types of spreadsheets:
#
#  1. OpenOffice (.ods)
#  2. Comma-separated text file (.csv)
#  3. Old Microsoft Excel (.xls)
#  4. New Microsoft Excel (.xlsx)
#
# == Spreadsheet "Ruby Representation"
#
# Abstractly, a "spreadsheet" is a 3D array of strings. A single sheet in a
# spreadsheet is a 2D array of columns and rows of strings, and a spreadsheet
# may have multiple sheets.
#
# This service expects this spreadsheet to be an +Enumerable+ of "sheets",
# where each sheet is an +Enumerable+ or "rows," where each row is an
# +Enumerable+ of "cells" in that row, and each cell is a +String+.
class ReadSpreadsheet < UploadService
  UnexpectedFilenameError = Class.new(StandardError)
  TRUE_VALUES = ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES

  # +Enumerable+
  #   a ruby-representation of the uploaded spreadsheet file
  attr_accessor :sheets

  # +Boolean+
  #   if the spreadsheet contains a header row that should be skipped
  attr_accessor :skip_first

  job_stage 'Parse Spreadsheet'
  i18n_scope :spreadsheet

  # Convert the uploaded file into a list of rows, each of which is a list of
  # cells (+strings+) in that row. This service will +fail!+ if the uploaded
  # file is not a a compatible spreadsheet file.
  #
  # Because the uploaded file is certainly a Tempfile, we unlink it afterwards.
  def call
    reader = open_upload
    update_percentage(0.5)
    read_sheets = reader.sheets.map { |name| reader.sheet(name) }

    update_percentage(0.75)

    self.sheets = read_sheets
    self.sheets = read_sheets.map { |sheet| sheet.drop(1) } if skip_first_row?

    update_percentage(0.95)
  rescue StandardError => e
    fail_job! message: e.message
  end

  private

  def open_upload
    ext =
      case File.extname(job.filename)
      when '.ods' then :ods
      when '.csv' then :csv
      when '.xls' then :xls
      when '.xlsx' then :xlsx
      else
        raise UnexpectedFilenameError,
              t('errors.unexpected_filename', name: job.filename)
      end

    Roo::Spreadsheet.open(job.tempfile.path, extension: ext)
  end

  def skip_first_row?
    TRUE_VALUES.include?(skip_first)
  end
end
