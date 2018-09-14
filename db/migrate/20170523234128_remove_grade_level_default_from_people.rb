class RemoveGradeLevelDefaultFromPeople < ActiveRecord::Migration
  def change
    reversible do |d|
      d.up   { change_column_default :people, :grade_level, nil }
      d.down { change_column_default :people, :grade_level, 'postHighSchool' }
    end
  end
end
