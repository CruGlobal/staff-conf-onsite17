class RemovePriceCentsDefaultOnCourses < ActiveRecord::Migration
  def change
    change_column_default :courses, :price_cents, nil
  end
end
