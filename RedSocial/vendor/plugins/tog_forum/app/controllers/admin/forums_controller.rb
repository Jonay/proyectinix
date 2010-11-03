class Admin::ForumsController < Admin::BaseController

  before_filter :find_forum, :only => [:show, :edit, :update, :destroy]

  def index
    @page = params[:page] || '1'
    @forums = TogForum::Forum.all.paginate({:page => @page})
    respond_to do |format|
      format.html
      format.rss { render :rss => @forums }    
    end
  end
  
  def show
  end
  
  # GET /forums/new
  # GET /forums/new.xml
  def new
    @forum = TogForum::Forum.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /forums/1/edit
  def edit
    respond_to do |format|
      format.html 
    end
  end

  # POST /forums
  # POST /forums.xml
  def create
    @forum = TogForum::Forum.new(params[:forum])
    @forum.id_referencia = params[:forum][:id_referencia]
    @forum.user = current_user
    if @forum.id_referencia == 'Para mi'
      @forum.id_referencia = current_user
      @forum.tipo = 'Usuario'
    else
      @forum.tipo = 'Grupo'
    end

    respond_to do |format|
      if @forum.save
        flash[:ok] = I18n.t('tog_forum.admin.forum_created')
        format.html { redirect_to(admin_forum_url(@forum)) }
        format.rss { render :rss => @forum, :status => :created, :location => @forum }
      else
        format.html { render :action => "new" }
        format.rss { render :rss => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /forums/1
  # PUT /forums/1.xml
  def update
    respond_to do |format|
      if @forum.update_attributes(params[:forum])
        flash[:notice] = 'El foro fue actualizado correctamente.'
        format.html { redirect_to(admin_forum_url(@forum)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.rss { render :rss => @forum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /forums/1
  # DELETE /forums/1.xml
  def destroy

    if @forum.destroy
      flash[:ok] = I18n.t('tog_forum.admin.forum_deleted')
    else
      flash[:error] = "Ocurrió un error: #{@forum.errors.full_messages}"
    end
    
    respond_to do |format|
      format.html { redirect_to(admin_forums_url) }
      format.xml  { head :ok }
    end
  end
  
  private
    def find_forum
      @forum = TogForum::Forum.find_by_id(params[:id]) || TogForum::Forum.top_level
      if @forum.blank? and Tog::Config["plugins.tog_forum.ensure_top_level"]
        @forum = TogForum::Forum.create_top_level
      end
    end  
  
  
end
