class AddFieldsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :instructor, :string
    add_column :courses, :week_descriptor, :string
    add_column :courses, :ibs_code, :integer
    add_column :courses, :location, :string

    remove_column :courses, :start_at, :date
    remove_column :courses, :end_at, :date
  end
end
