class Member::Conversatio::BloggershipsController < Member::BaseController
  
  before_filter :find_blog, :only => [:index, :add_editor, :remove_editor]
  
  def index
    @bloggerships = @blog.bloggerships.paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'], :page => params[:page]
  end
=begin  
  def create
    u = User.find(params[:bloggership][:user_id])
    if current_user.profile.is_related_to?(u.profile)
      @bloggership = u.bloggerships.create(:blog => @blog)
      flash[:ok]= I18n.t("tog_conversatio.member.bloggerships.editor_added")
    else
      flash[:error]=I18n.t("tog_conversatio.member.bloggerships.user_not_related")
    end
    redirect_to member_conversatio_blog_bloggerships_path(@blog)
  end
  
  def destroy
    @bloggership = @blog.bloggerships.find(params[:id]).destroy
    
    flash[:ok]=I18n.t("tog_conversatio.member.bloggerships.editor_deleted")
    redirect_to member_conversatio_blog_bloggerships_path(@blog)
  end
=end  
  
  
  def add_editor
    
    #receptor que será el editor a añadir
    u = User.find(params[:bloggership][:user_id])
    #almacenamo el grupo para pasarlo por mensaje
    blog = @blog
    if current_user.profile.is_related_to?(u.profile) 
      Message.new(
          :from => current_user,
          :to => u,
          :subject => I18n.t("tog_conversatio.member.mail.add_editor.subject", :blog_name => blog.title),
          :content => I18n.t("tog_conversatio.member.mail.add_editor.content", :blog_name => blog.title, 
                           :user_name   => current_user.profile.full_name, 
                           :bloggership_name => u.profile.full_name, 
                           :blog_url => conversatio_blog_path(blog),
      #url para confirmar pasándole usuario actual y el blog
                           :confirm_url => member_conversatio_blog_confirm_editor_url(@blog.id, current_user.profile))
      ).dispatch! 
      flash[:ok]= I18n.t("tog_conversatio.member.bloggerships.add_editor_request", :bloggership_name => u.profile.full_name)
    else
      flash[:error]=I18n.t("tog_conversatio.member.bloggerships.user_not_related")
    end
    
    redirect_to member_conversatio_blog_bloggerships_path(@blog)
  end
  
  def confirm_editor
    u = User.find(params[:user_id]) #emisor antes ahora receptor
    @blog = Blog.find(params[:blog_id])#almacenamos el blog para saber si el usuario actual es miembro del blog
    
    #creamos el nuevo miembro
    @bloggership = current_user.bloggerships.create(:blog => @blog)
    Message.new(
          :from => current_user,
          :to => u,
          :subject => I18n.t("tog_conversatio.member.mail.confirm_editor.subject", :user_name => current_user.profile.full_name),
          :content => I18n.t("tog_conversatio.member.mail.confirm_editor.content", :u_name => u.profile.full_name, 
                           :user_name   => current_user.profile.full_name, 
                           :blog_name => @blog.title, 
                           :user_profile_url => profile_url(current_user.profile))
    ).dispatch! 
    
    flash[:ok]= I18n.t("tog_conversatio.member.bloggerships.editor_confirmed", :blog_name => @blog.title)
    redirect_to member_conversatio_blog_bloggerships_path(@blog)
  end
  
  def remove_editor
    #u es el usuario al que le envíamos el mensaje
    u = User.find(params[:id]) 
    
    
    #bloggership es el miembro a eliminar
    @bloggership = @blog.bloggerships.find(params[:bloggership]).destroy
    Message.new(
             :from => current_user,
             :to => u,
             :subject => I18n.t("tog_conversatio.member.mail.remove_editor.subject", :user_name => current_user.profile.full_name),
             :content => I18n.t("tog_conversatio.member.mail.remove_editor.content", :u_name => u.profile.full_name, 
                             :user_name   => current_user.profile.full_name, 
                             :blog_name => @blog.title, 
                             :user_profile_url => profile_url(current_user.profile))
    ).dispatch!
    flash[:ok]=I18n.t("tog_conversatio.member.bloggerships.editor_deleted")
    redirect_to member_conversatio_blog_bloggerships_path(@blog)
    
  end
  
  private
  
  def find_blog
    @blog = Blog.find(params[:blog_id])
  end
end

