class SetChildcareWeeksDefaultOnPeople < ActiveRecord::Migration
  def change
    change_column_default :people, :childcare_weeks, ""
  end
end
