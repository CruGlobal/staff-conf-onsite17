class UploadService < ApplicationService
  UploadJobError = Class.new(StandardError)

  # +UploadJob+
  #   a job record containing a file uploaded to the server by a {User}
  attr_accessor :job

  after_initialize :update_job_stage

  class << self
    # Set/Get a descriptive name for an Interactor, so we can better describe
    # the current stage the job is processing
    def job_stage(stage = nil)
      @job_stage = stage if stage.present?
      @job_stage || name.titleize
    end
  end

  def succeed_job
    job.update(finished: true, success: true, percentage: 1)
  end

  def fail_job!(message: nil)
    return if job.failed?
    raise UploadJobError if message.blank?

    job.fail!(message)
    raise UploadJobError, message
  end

  def update_job_stage
    job.update!(stage: self.class.job_stage, percentage: 0)
  end

  def update_percentage(percentage)
    local_job = job
    Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        local_job.update!(percentage: percentage)
      end
    end
  end
end
