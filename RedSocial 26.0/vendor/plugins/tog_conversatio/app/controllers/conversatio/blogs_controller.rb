class Conversatio::BlogsController < ApplicationController

  def index
    if logged_in? 
      @order = params[:order] || 'title'
      @page = params[:page] || '1'
      @asc = params[:asc] || 'asc'
      @blogs = Blog.paginate :per_page => 10,
                             :page => @page,
                             :order => @order + " " + @asc
    else
      redirect_to root_path
    end
  end

  def show
    @page = params[:page] || '1'

    @blog = Blog.find params[:id]
    @posts = @blog.posts.published.paginate :per_page => 2,
                                           :page => @page, 
                                           :order => "published_at desc"

    respond_to do |format|
      format.html
      format.atom { render(:layout => false) }
    end
  end

end