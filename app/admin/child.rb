ActiveAdmin.register Child do
  partial_view :index, :show, form: Person::FORM_OPTIONS

  menu parent: 'People', priority: 3

  includes :family

  scope :all, default: true
  scope :in_kidscare

  # We create through Families#show
  config.remove_action_item :new
  config.remove_action_item :new_show

  permit_params(
    :first_name, :last_name, :birthdate, :gender, :family_id, :parent_pickup,
    :needs_bed, :grade_level, :childcare_id, :arrived_at, :departed_at,
    :name_tag_first_name, :name_tag_last_name, :childcare_deposit,
    :childcare_comment, :rec_pass_start_at, :rec_pass_end_at,
    childcare_weeks: [], hot_lunch_weeks: [], cost_adjustments_attributes: %i[
      id _destroy description person_id price percent cost_type
    ],
    meal_exemptions_attributes: %i[
      id _destroy date meal_type
    ],
    stays_attributes: %i[
      id _destroy housing_unit_id arrived_at departed_at single_occupancy
      no_charge waive_minimum percentage comment
    ]
  )

  filter :first_name
  filter :last_name
  filter :birthdate
  filter :gender
  filter :parent_pickup
  filter :needs_bed
  filter :arrived_at
  filter :departed_at
  filter :childcare_class

  action_item :import_spreadsheet, only: :index do
    if authorized?(:import, Family)
      link_to 'Import Spreadsheet', new_spreadsheet_families_path
    end
  end
end
