class CreateConferenceAttendances < ActiveRecord::Migration
  def change
    create_table :conference_attendances do |t|
      t.references :conference, index: true, foreign_key: true
      t.references :attendee, references: :people, index: true

      t.timestamps null: false
      t.foreign_key :people, column: :attendee_id
    end
  end
end
