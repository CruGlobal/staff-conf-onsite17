ActiveAdmin.register User do
  permit_params :role, :email

  index do
    actions
    selectable_column

    column :role
    column :email
    column :first_name
    column :last_name
    column :created_at
  end

  filter :role, as: :select, collection: -> { User::ROLES }
  filter :email
  filter :first_name
  filter :last_name
  filter :created_at

  form do |f|
    show_errors_if_any(f)

    f.inputs 'User Details' do
      f.input :role, as: :select, collection: User::ROLES, include_blank: false
      f.input :email
    end

    f.actions
  end
end
