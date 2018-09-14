class ImportChargeableStaffNumbersSpreadsheetJob < ApplicationJob
  queue_as :default

  def perform(upload_job_id, delete_existing, skip_first)
    job = UploadJob.find(upload_job_id)
    return if job.started?

    ImportChargeableStaffNumbersSpreadsheet.call(
      job: job, delete_existing: delete_existing, skip_first: skip_first
    )
  rescue Exception => e
    job&.fail!(e.message)
    raise
  ensure
    job&.remove_file!
  end
end
