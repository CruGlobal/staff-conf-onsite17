class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :emergency_contact
      t.string :phone
      t.date :birthdate
      t.string :student_number, unique: true, index: true
      t.string :staff_number
      t.string :gender
      t.string :department
      t.references :family, foreign_key: true
      t.references :ministry, foreign_key: true
      t.string :type
      t.string :childcare_grade

      t.timestamps
    end
    add_index :people, :type
  end
end
