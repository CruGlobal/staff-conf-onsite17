class RenamePathToFileOnUploadJobs < ActiveRecord::Migration
  def change
    rename_column :upload_jobs, :path, :file
  end
end
