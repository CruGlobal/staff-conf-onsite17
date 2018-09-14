class ImportPeopleFromSpreadsheetJob < ApplicationJob
  queue_as :default

  def perform(upload_job_id)
    job = UploadJob.find(upload_job_id)
    return if job.started?

    Import::ImportPeopleFromSpreadsheet.call(job: job)
  rescue Exception => e
    job&.fail!(e.message)
    raise
  ensure
    job&.remove_file!
  end
end
