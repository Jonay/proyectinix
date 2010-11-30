class Admin::Conversatio::BlogsController < Admin::BaseController
  
  
  def index
    @order = params[:order] || 'title'
    @page = params[:page] || '1'
    @blogs = Blog.paginate :per_page => 20,
                             :page => @page,
                             :order => "#{@order} ASC"
  end

  def edit
    @blog = Blog.find(params[:id])
  end
  
  def update
    @blog = Blog.find(params[:id])    
    @blog.update_attributes!(params[:blog])
    @blog.save
    flash[:ok] =  I18n.t("tog_social.groups.admin.updated", :title => @blog.title) 
    redirect_to edit_admin_conversatio_blogs_path(@blog)
  end  

  def destroy
    @blog = Blog.find(params[:id])
    
    #buscamos todos los editores del blog y los eliminamos uno a uno
    @bloggerships = @blog.bloggerships.find(:all, :conditions => {:blog_id => @blog.id})
    @bloggerships.each do |bloggership| 
      bloggership.destroy
    end
    
    #buscamos todos los posts del blog y los eliminamos uno a uno
    @posts = @blog.posts.find(:all, :conditions => {:blog_id => @blog.id})
    @posts.each do |post| 
      post.destroy
    end
    
    @blog.destroy
    respond_to do |wants|
      wants.html do
        flash[:ok]=I18n.t('tog_conversatio.admin.blogs.blog_removed')
        redirect_to admin_conversatio_blogs_path
      end
    end
  end
  
end