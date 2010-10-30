class TopicsController < ApplicationController
  
  before_filter :login_required, :only => [:new, :create, :edit, :update]   
  before_filter :admin?, :only => [:destroy] # or post.user?
  before_filter :find_forum
  before_filter :find_topic, :only => [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
      format.xml do
        @topics = @forum.topics.paginate :per_page => 10,
                                         :page => @page,
                                         :order => "updated_at DESC"
        render :xml => @topics
      end
    end
  end
  
  def edit
    return false unless user_can_alter?
  end
  
  def show
    @page = params[:page] || '1'
    @highlighted_post = @topic.posts.find(params[:post_id]) if params[:post_id]
    @posts = @topic.posts.paginate :per_page => 10, :page => @page, :order => "updated_at ASC"
    @post = @topic.posts.build(:user => current_user)

    respond_to do |format|
      format.html
      format.xml { render :xml => @posts }
    end
  end  

  def new
    @topic = @forum.topics.build(:user => current_user)
    @post = @topic.posts.build(:user => current_user)
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @topic }
    end
  end
    
  def create
    @topic = @forum.topics.build params[:topic]
    @topic.user = current_user
    
    respond_to do |format|
      if @topic.save
        if params[:post]
          @post = @topic.posts.build params[:post]
          @post.user = current_user
          
          if @post and @post.valid? and @post.save
            flash[:ok] = I18n.t('tog_forum.views.topics.topic_and_post_created')
            format.html { redirect_to forum_topic_path(@forum, @topic) }
            format.xml { render :xml => @topic, :status => :created, :location => forum_topic_url(@forum, @topic) }
          else
            flash[:error] = I18n.t('tog_forum.views.posts.no_post_created', :error => @post.errors.full_messages)
            format.html { render :action => "new" }
            format.xml { render :xml => @post.errors, :status => :unprocessable_entity }
          end
        else
          flash[:ok] = I18n.t('tog_forum.views.topics.created')
          format.html { redirect_to forum_topic_path(@forum, @topic) }
          format.xml { render :xml => @topic, :status => :created, :location => forum_topic_url(@forum, @topic) }
        end
        
      else
        flash[:error] = I18n.t('tog_forum.views.topics.no_topic_created', :error => @topic.errors.full_messages)
        format.html { render :action => "new" }
        format.xml { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    return false unless user_can_alter?
    
    @topic.update_attributes(params[:tog_forum_topic]) if user_can_alter?
    respond_to do |format|
      if @topic.errors.empty? and user_can_alter?
        flash[:ok] = I18n.t('tog_forum.views.topics.updated')
        format.html { redirect_to forum_topic_path(@forum, @topic) }
        format.xml { head :ok }
      elsif not user_can_alter?
        flash[:error] = "Sorry, you're not allowed to update this!"
        format.html { redirect_to forum_topic_path(@forum, @topic) }
        format.xml { head :ok }
        
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    respond_to do |format|
      if @topic.destroy
        flash[:ok] = "El tema ha sido eliminado correctamente"
      else
        flash[:error] = "Ocurrió un error mientras trataba de eliminar el tema: #{@topic.errors.full_messages}"
      end
      format.html { redirect_to forum_path(@forum) }
      format.xml { head :ok }
    end
  end
    
private
  def find_forum
    @forum = TogForum::Forum.find(params[:forum_id], :include => [:topics]) if params[:forum_id]
  end

  def find_topic
    @topic = @forum.topics.find(params[:id]) if params[:id]    
  end
  
  def user_can_alter?
    return false unless current_user
    (@topic and @topic.user and current_user == @topic.user)
  end
end
