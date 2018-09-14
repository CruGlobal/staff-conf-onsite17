class RemoveRegistrationCommentFromFamilies < ActiveRecord::Migration
  def change
    remove_column :families, :registration_comment, :text
  end
end
