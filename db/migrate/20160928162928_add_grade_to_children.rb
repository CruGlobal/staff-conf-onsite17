class AddGradeToChildren < ActiveRecord::Migration
  def change
    add_column :people, :grade_level, :string
  end
end
