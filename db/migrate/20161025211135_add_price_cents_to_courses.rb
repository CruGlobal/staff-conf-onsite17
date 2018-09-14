class AddPriceCentsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :price_cents, :integer, null: false, default: 0
  end
end
