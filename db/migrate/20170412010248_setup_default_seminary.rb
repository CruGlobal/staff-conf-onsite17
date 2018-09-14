class SetupDefaultSeminary < ActiveRecord::Migration
  def up
    seminary = Seminary.default || Seminary.create!(name: 'IBS')
    Attendee.where(seminary_id: nil).update_all(seminary_id: seminary.id)
  end

  def down
  end
end
