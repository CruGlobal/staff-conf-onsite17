class CreateCourseAttendances < ActiveRecord::Migration
  def change
    create_table :course_attendances do |t|
      t.references :course, foreign_key: true, index: true
      t.references :attendee, references: :people, index: true
      t.string :grade

      t.timestamps

      t.index [:course_id, :attendee_id], unique: true
      t.foreign_key :people, column: :attendee_id
    end
  end
end
