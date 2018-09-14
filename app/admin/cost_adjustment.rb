ActiveAdmin.register CostAdjustment do
  partial_view :index, :form, show: {
    title: ->(ca) { "Cost Adjustment ##{ca.id}, for #{ca.person.full_name}" }
  }

  permit_params :person_id, :cost_type, :price, :percent, :description

  filter :person
  filter :cost_type, as: :select, collection: -> { cost_type_ord_select }
  filter :description
  filter :created_at
  filter :updated_at
end
