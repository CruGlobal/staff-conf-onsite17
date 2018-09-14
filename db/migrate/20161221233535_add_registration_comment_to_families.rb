class AddRegistrationCommentToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :registration_comment, :text
  end
end
