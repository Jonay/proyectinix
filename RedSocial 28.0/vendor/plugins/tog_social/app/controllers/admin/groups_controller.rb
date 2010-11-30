class Admin::GroupsController < Admin::BaseController

  def index
    @order = params[:order] || 'name'
    @page = params[:page] || '1'
    @groups = Group.paginate :per_page => 20,
                             :page => @page,
                             :order => "#{@order} ASC"
  end

  def edit
    @group = Group.find(params[:id])
  end
  
  def update
    @group = Group.find(params[:id])    
    @group.update_attributes!(params[:group])
    @group.save
    flash[:ok] =  I18n.t("tog_social.groups.admin.updated", :name => @group.name) 
    redirect_to edit_admin_group_path(@group)
  end  


=begin
  Método para eliminar un grupo
  1º) Buscamos el grupo pasado por parámetro
  2º) buscamos los blog asociados a ese grupo y los eliminamos uno a uno
  3º) buscamos los eventos asociados a ese grupo y los eliminamos uno a uno
  4º) buscamos los álbumes de fotos asociados a ese grupo y los eliminamos uno a uno así como las fotos de esos álbumes
  5º) buscamos los foros asociados a ese grupo y los eliminamos uno a uno
  6º) buscamos los miembros asociados a ese grupo y los eliminamos uno a uno
  7º) eliminamos el grupo
=end
  def destroy
    @group = Group.find(params[:id])
    
    @blogs = Blog.find(:all, :conditions => {:id_referencia => @group.id, :tipo => 'Grupo'})
    @blogs.each do |blog| 
      blog.destroy
    end 

    @events = Event.find(:all, :conditions => {:id_referencia => @group.id, :tipo => 'Grupo'})
    @events.each do |event| 
      event.destroy
    end
    
    @photosets = Photoset.find(:all, :conditions => {:id_referencia => @group.id, :tipo => 'Grupo'})
    @photosets.each do |photoset|
      @photos = Photo.find(:all, :conditions => {:photoset_id => photoset.id})
      @photos.each do |photo|
        photo.destroy
      end
      photoset.destroy
    end
    
    @forums = TogForum::Forum.find(:all, :conditions => {:id_referencia => @group.id, :tipo => 'Grupo'})
    @forums.each do |forum| 
      forum.destroy
    end
    
    @memberships = @group.memberships.find(:all, :conditions => {:group_id => @group.id})
    @memberships.each do |membership| 
      membership.destroy
    end
    
    @group.destroy
    respond_to do |wants|
      wants.html do
        flash[:ok]= I18n.t("tog_social.groups.admin.deleted")
        redirect_to admin_groups_path
      end
    end
  end

  def activate
    @group = Group.find(params[:id])
    @group.activate!
    respond_to do |wants|
      if @group.activate!
        wants.html do
          render :text => "<span>#{I18n.t("tog_social.groups.admin.activated")}</span>"
        end
      end
    end
  end

end