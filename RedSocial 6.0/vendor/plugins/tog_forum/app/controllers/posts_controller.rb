class PostsController < ApplicationController
  
  before_filter :login_required, :only => [:new, :create, :destroy]   
  before_filter :admin?, :only => [:destroy] # or post.user?
  before_filter :find_topic
  before_filter :find_post, :only => [:edit, :update, :destroy]

  def show
    respond_to do |format|
      format.html
      format.rss { render(:layout => false) }
    end    
  end 

	def edit
    return false unless user_can_alter?
  end  
  
  def new
    @page = params[:page] || '1'
    @posts = @topic.posts.paginate :per_page => 10, :page => @page, :order => "updated_at ASC"
    @post = @topic.posts.build(:user => current_user)
    if params[:quote]
      @quoting_post = TogForum::Post.find(params[:quote])
      @post.text = "[quote=\"" + @quoting_post.user.login + "\"]" + @quoting_post.text + "[/quote]"
    end
  end
  
  def create
    @post = @topic.posts.build(params[:post])
    @post.user = current_user
    
    respond_to do |format|
      if @post.save
        flash[:ok] = I18n.t('tog_forum.views.posts.created')
        format.html { redirect_to(forum_topic_path(@topic.forum, @topic)) }
        format.xml { render :xml => @topic, :status => :created, :location => forum_topic_url(@topic.forum, @topic) }
      else
        flash[:error] = I18n.t('tog_forum.views.posts.no_post_created', :error => @post.errors.full_messages)
        format.html { render :action => "edit" }
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    respond_to do |format|
      if @post.destroy
        flash[:ok] = "El post ha sido eliminado correctamente"
      else
        flash[:error] = "Ocurrió un error mientras trataba de eliminar el post: #{@post.errors.full_messages}"
      end
      format.html { redirect_to forum_topic_path(@topic.forum, @topic) }
      format.xml { head :ok }
    end
  end
  
private
  def find_topic
    @topic = TogForum::Topic.find(params[:topic_id], :include => :posts) if params[:topic_id]    
  end

  def find_post
    @post = TogForum::Post.find(params[:post_id]) if params[:post_id]
    @post ||= TogForum::Post.find(params[:id]) if params[:id]    
  end

  def user_can_alter?
    return false unless current_user
    (@post and @post.user and current_user == @post.user)
  end
end
