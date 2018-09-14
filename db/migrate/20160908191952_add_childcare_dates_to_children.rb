class AddChildcareDatesToChildren < ActiveRecord::Migration
  def change
    add_column :people, :needs_bed, :boolean, default: true
    add_column :people, :parent_pickup, :boolean
    add_column :people, :childcare_weeks, :string
    add_reference :people, :childcare, index: true
  end
end
