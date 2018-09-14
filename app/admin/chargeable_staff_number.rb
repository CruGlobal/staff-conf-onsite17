ActiveAdmin.register ChargeableStaffNumber do
  partial_view :index, :show, :form
  permit_params :staff_number

  filter :staff_number
  filter :created_at

  action_item :import_staff_numbers, only: :index do
    if authorized?(:import, ChargeableStaffNumber)
      link_to 'Import Spreadsheet', action: :new_spreadsheet
    end
  end

  collection_action :new_spreadsheet, title: 'Import Spreadsheet'
  collection_action :import_spreadsheet, method: :post do
    return head :forbidden unless authorized?(:import, ChargeableStaffNumber)

    import_params =
      ActionController::Parameters.new(params).require('import_spreadsheet').
        permit(:file, :delete_existing, :skip_first)

    job = UploadJob.create!(user_id: current_user.id,
                            filename: import_params[:file].path)
    ImportChargeableStaffNumbersSpreadsheetJob.perform_later(
      job.id, import_params[:delete_existing], import_params[:skip_first]
    )

    redirect_to job
  end
end
