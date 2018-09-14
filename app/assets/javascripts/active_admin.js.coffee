#= require active_admin/base
#
#  Widgets
#  ====================================
#
#= require util/index_records_count
#= require util/ordinals
#= require util/page_actions
#= require util/query_string
#
#= require ckeditor-jquery
#= require widgets/ckeditor
#= require jquery.dirtyforms
#
#  Date Inputs ------------------------
#= require widgets/dates
#
#  Select Boxes -----------------------
#= require chosen-jquery
#= require jquery.dropdown.1.6
#= require widgets/chosen-jquery
#= require widgets/index-per-page-selector
#
#  Telephone Numbers ------------------
#= require intlTelInput
#= require libphonenumber/utils
#= require widgets/intl-tel-input-rails
#
#  Money ------------------------------
#= require jquery.price_format.2.0
#= require widgets/price_format-jquery
#
#= require jquery-ui/autocomplete
#
#
#  Specific Models
#  ====================================
#
#  Attendee/Child ---------------------
#= require child/index_childcare_select
#= require child/childcare_deposit
#= require person/course_attendance_form
#= require person/meal_form
#= require person/edit
#
#  Ministry ---------------------------
#= require 'ministry/select'
#
#  Family -----------------------------
#= require family/edit
#= require family/summary
#
#  Housing ------------------------
#= require housing/housing.coffee
#= require housing/validations.coffee
#
#  UploadJob --------------------------
#= require upload_job/status_polling
#
#  UserVariable -----------------------
#= require user_variable/create_auto_short_name
#= require user_variable/new_value_inputs
#
#  ActsAsList -------------------------
#= require acts_as_list/reorder

#  Fetch data for housing lists (this is needed on multiple pages)
window.$menu_loaded = $.get '/housing_units_list', (data) ->
  window.$housing_unit_hierarchy = data.housing
  window.$housing_families = data.families

window.$ministries_loaded = $.get '/ministries/list', (data) ->
  window.$ministries = data.ministries
