class SetAllAttributesNotNullOnCourses < ActiveRecord::Migration
  def change
    change_column_null :courses, :name, false
    change_column_null :courses, :description, false
    change_column_null :courses, :instructor, false
    change_column_null :courses, :week_descriptor, false
    change_column_null :courses, :ibs_code, false
    change_column_null :courses, :location, false
  end
end
