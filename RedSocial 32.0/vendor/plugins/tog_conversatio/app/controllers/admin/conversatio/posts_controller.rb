class Admin::Conversatio::PostsController < Admin::BaseController
  
  before_filter :load_blog
  
  def index
    @order = params[:order] || 'created_at'
    @page = params[:page] || '1'
    @asc = params[:asc] || 'desc'
    @posts = @blog.posts.paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'],
                                  :page => @page,
                                  :order => @order + " " + @asc
  end

  def destroy
    @post = @blog.posts.find params[:id]
    @post.destroy

    respond_to do |wants|
      wants.html do
        flash[:ok]=I18n.t('tog_conversatio.admin.posts.post_removed')
        redirect_to admin_conversatio_blog_posts_path(@post.blog)
      end
    end
  end

private
  #método para cargar el blog pasado por parámetro
  def load_blog
    @blog  = Blog.find params[:blog_id]
  end
end