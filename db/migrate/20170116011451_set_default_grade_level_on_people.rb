class SetDefaultGradeLevelOnPeople < ActiveRecord::Migration
  class MigrationPerson < ActiveRecord::Base
    self.table_name = :people
  end

  def change
    reversible do |dir|
      dir.up do
        change_column_default :people, :grade_level, 'postHighSchool'

        MigrationPerson
          .where(grade_level: nil)
          .update_all(grade_level: 'postHighSchool')
      end

      dir.down do
        change_column_default :people, :grade_level, nil

        MigrationPerson
          .where(grade_level: 'postHighSchool')
          .update_all(grade_level: nil)
      end
    end
  end
end
