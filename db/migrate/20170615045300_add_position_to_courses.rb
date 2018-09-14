class AddPositionToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :position, :integer

    Course.order(:updated_at).each.with_index(1) do |record, index|
      record.update_column :position, index
    end
  end
end
