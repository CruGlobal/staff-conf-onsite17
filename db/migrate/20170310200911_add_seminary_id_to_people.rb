class AddSeminaryIdToPeople < ActiveRecord::Migration
  def change
    add_reference :people, :seminary, index: true, foreign_key: true
  end
end
