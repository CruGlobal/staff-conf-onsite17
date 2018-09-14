class FixNametagNames < ActiveRecord::Migration
  def change
    change_table :people do |t|
      t.rename :name_tag_first_name, :name_tag_first_temp
      t.rename :name_tag_last_name, :name_tag_first_name
      t.rename :name_tag_first_temp, :name_tag_last_name
    end
  end
end
