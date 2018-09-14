class AddImportAttributesToPeople < ActiveRecord::Migration
  def change
    add_column :people, :tshirt_size, :string
    add_column :people, :mobility_comment, :text
    add_column :people, :personal_comment, :text
    add_column :people, :conference_comment, :text
    add_column :people, :childcare_deposit, :boolean
    add_column :people, :childcare_comment, :text
    add_column :people, :ibs_comment, :text
    add_column :people, :ethnicity, :string
    add_column :people, :hired_at, :date
    add_column :people, :employee_status, :string
    add_column :people, :caring_department, :string
    add_column :people, :strategy, :string
    add_column :people, :assignment_length, :string
    add_column :people, :pay_chartfield, :string
    add_column :people, :conference_status, :string
    add_column :people, :name_tag_first_name, :string
    add_column :people, :name_tag_last_name, :string
  end
end
