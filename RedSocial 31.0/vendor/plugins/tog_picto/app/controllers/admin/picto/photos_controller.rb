class Admin::Picto::PhotosController < Admin::BaseController

  helper "picto/base"

  def index
    @order = params[:order] || 'updated_at'
    @page = params[:page] || '1'
    @photos = Picto::Photo.paginate :per_page => 20,
                             :page => @page,
                             :order => "#{@order} ASC"
  end

  def edit
    @photo = Picto::Photo.find(params[:id])
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    respond_to do |wants|
      wants.html do
        flash[:ok]=I18n.t("tog_picto.admin.photos.index.photo_deleted")
        redirect_to admin_picto_photos_path
      end
    end
  end

end