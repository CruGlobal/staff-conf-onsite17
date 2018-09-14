class ImportHierarchySpreadsheetJob < ApplicationJob
  queue_as :default

  def perform(upload_job_id, skip_first)
    job = UploadJob.find(upload_job_id)
    return if job.started?

    Ministry::ImportHierarchySpreadsheet.call(job: job, skip_first: skip_first)
  rescue Exception => e
    job&.fail!(e.message)
    raise
  ensure
    job&.remove_file!
  end
end
