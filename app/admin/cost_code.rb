ActiveAdmin.register CostCode do
  partial_view :index, :show, :form

  permit_params :name, :description, :min_days, charges_attributes: %i[
    id _destroy max_days adult teen child infant child_meal single_delta
  ]

  filter :name
  filter :description
  filter :min_days
  filter :created_at
  filter :updated_at
end
