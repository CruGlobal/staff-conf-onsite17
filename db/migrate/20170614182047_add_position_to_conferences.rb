class AddPositionToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :position, :integer

    Conference.order(:updated_at).each.with_index(1) do |record, index|
      record.update_column :position, index
    end
  end
end
