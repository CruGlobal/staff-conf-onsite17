class CreateUploadJobs < ActiveRecord::Migration
  def change
    create_table :upload_jobs do |t|
      t.belongs_to :user, null: false
      t.string :path, null: false
      t.boolean :finished, null: false, default: false
      t.boolean :success
      t.float :percentage, null: false, default: 0
      t.string :stage, null: false, default: 'queued'
      t.text :html_message

      t.timestamps null: false
    end
  end
end
