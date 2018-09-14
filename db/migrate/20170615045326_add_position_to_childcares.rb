class AddPositionToChildcares < ActiveRecord::Migration
  def change
    add_column :childcares, :position, :integer

    Childcare.order(:updated_at).each.with_index(1) do |record, index|
      record.update_column :position, index
    end
  end
end
