class AddFileUploadJobs < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        rename_column :upload_jobs, :file, :filename
        add_column :upload_jobs, :file, :binary
      end

      dir.down do
        remove_column :upload_jobs, :file
        rename_column :upload_jobs, :filename, :file
      end
    end

  end
end
