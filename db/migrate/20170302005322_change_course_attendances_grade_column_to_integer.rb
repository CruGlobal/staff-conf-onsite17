class ChangeCourseAttendancesGradeColumnToInteger < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        remove_column :course_attendances, :grade
        add_column :course_attendances, :grade, :integer
      end
      dir.down do
        remove_column :course_attendances, :grade
        add_column :course_attendances, :grade, :string
      end
    end
  end
end
