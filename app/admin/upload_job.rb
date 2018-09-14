ActiveAdmin.register UploadJob do
  menu false
  actions :show

  show { render 'show' }

  member_action :status do
    respond_to do |format|
      format.json { render json: UploadJob.find(params[:id]) }
    end
  end
end
