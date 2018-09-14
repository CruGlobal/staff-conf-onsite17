class RenameCentsColumnOnConferences < ActiveRecord::Migration
  def change
    rename_column :conferences, :cents, :price_cents
  end
end
