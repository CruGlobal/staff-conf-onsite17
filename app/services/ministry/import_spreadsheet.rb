# This service accepts a spreadsheet file uploaded by a {User} and, for each
# row in that spreadsheet, either creates a new {Ministry} record, or updates
# an existing record. A new record is created is the +code+ in the spreadsheet
# doesn't belong to an existing +Ministry+. If it does belong to an existing
# +Ministry+, its +name+ will be updated with the name given in the
# spreadsheet.
class Ministry::ImportSpreadsheet < UploadService
  attr_accessor :skip_first

  def call
    spreadsheet = ReadSpreadsheet.call(job: job, skip_first: skip_first)
    Ministry::CreateOrUpdate.call(job: job, sheets: spreadsheet.sheets)

    succeed_job
  end
end
