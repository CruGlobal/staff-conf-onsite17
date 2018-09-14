# Provides the status of an upload job running in the background, so that we
# can update the user-agent with its progress.
#
# It's possible that an uploaded file will have to be uploaded in multple
# steps, so an upload's job has multiple "stages", each of which will move its
# "percentage" from 0.0 to 1.0. So it is possible for {#percentage} to be +1.0+
# without the job being {#finished}
class UploadJob < ApplicationRecord
  scope :done,      -> { where(finished: true) }
  scope :succeeded, -> { where(success: true) }
  scope :failed,    -> { where(success: false) }

  belongs_to :user

  validates :filename, :stage, :percentage, presence: true

  before_save :read_file

  def started?
    finished? || stage != 'queued' || percentage != 0
  end

  def fail!(message)
    update!(finished: true, success: false, html_message: message)
  end

  def failed?
    finished? && !success?
  end

  def success=(success)
    super
    self.finished = true
  end

  def finished=(finish)
    super
    self.percentage = 1.0
  end

  def stage=(name)
    super
    self.percentage = 0.0
  end

  def percentage=(value)
    v = value.to_f
    super([0.0, [v, 1.0].min].max)
  end

  def as_json(*_args)
    super.tap do |json|
      json.delete('filename')
      json.delete('file')
    end
  end

  def remove_file!
    update!(file: nil)
    tempfile&.close
  end

  def tempfile
    return nil if file.blank?

    @tempfile ||=
      begin
        base = File.basename(filename)
        ext = File.extname(filename)

        Tempfile.new([base, ext]).tap do |tmp|
          tmp.binmode
          tmp.write(file)
          tmp.flush
        end
      end
  end

  private

  def read_file
    if file.nil? && !finished? && File.readable?(filename)
      self.file = IO.binread(filename)
    end
  end
end
