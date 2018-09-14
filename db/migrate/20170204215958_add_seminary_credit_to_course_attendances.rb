class AddSeminaryCreditToCourseAttendances < ActiveRecord::Migration
  def change
    add_column :course_attendances, :seminary_credit, :boolean, default: false

    reversible do |dir|
      dir.up do
        remove_column :course_attendances, :grade
        add_column :course_attendances, :grade, :string
      end
      dir.down do
        remove_column :course_attendances, :grade
        add_column :course_attendances, :grade, :integer
      end
    end
  end
end
