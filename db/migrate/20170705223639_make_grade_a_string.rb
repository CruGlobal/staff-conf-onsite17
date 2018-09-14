class MakeGradeAString < ActiveRecord::Migration
  def change
    change_column :course_attendances, :grade, :string
  end
end
