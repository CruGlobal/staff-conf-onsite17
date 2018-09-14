class AddHotLunchWeeksToPeople < ActiveRecord::Migration
  def change
    add_column :people, :hot_lunch_weeks, :string, null: false, default: ''
  end
end
