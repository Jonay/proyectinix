class Member::Conversatio::BlogsController < Member::BaseController

  helper 'conversatio/blogs'
  

  def index
    @order = params[:order] || 'title'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'asc'
    @blogs = current_user.blogs.paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'],
                                         :page => @page,
                                         :order => @order + " " + @asc
  end

  def edit
    @blog = current_user.blogs.find(params[:id])
  end

  def new
    @blog = current_user.blogs.new
  end

  def create
    bs = current_user.bloggerships.new
    @blog = bs.build_blog params[:blog]
    @blog.id_referencia = params[:blog][:id_referencia]
    @blog.author = current_user
    if @blog.id_referencia == 'Para mi'
      @blog.id_referencia = current_user
      @blog.tipo = 'Usuario'
    else
        @blog.tipo = 'Grupo'
    end
    

    respond_to do |wants|
      if @blog.save & bs.save
        wants.html do
          flash[:ok] = I18n.t('tog_conversatio.member.blogs.blog_created')
          redirect_to conversatio_blog_path(@blog)
        end
      else
        wants.html do
          flash.now[:error] = 'Fallo al crear un nuevo blog.'
          render :action => :new
        end
      end
    end
  end

  def update
    @blog = current_user.blogs.find(params[:id])

    respond_to do |wants|
      if @blog.update_attributes(params[:blog])
        wants.html do
          flash[:ok]=I18n.t('tog_conversatio.member.blogs.blog_updated')
          redirect_to conversatio_blog_path(@blog)
        end
      else
        wants.html do
          flash.now[:error]='Failed to update the blog.'
          render :action => :edit
        end
      end
    end
  end

  def destroy
    @blog = current_user.blogs.find(params[:id]) #almacenamos el blog
    
    #buscamos todos los editores del blog y los eliminamos uno a uno
    @bloggerships = @blog.bloggerships.find(:all, :conditions => {:blog_id => @blog.id})
    @bloggerships.each do |bloggership| 
      bloggership.destroy
    end

    #eliminamos el blog
    @blog.destroy
    respond_to do |wants|
      wants.html do
        flash[:ok]=I18n.t('tog_conversatio.member.blogs.blog_removed')
        redirect_to member_conversatio_blogs_path
      end
    end
  end
  
end
