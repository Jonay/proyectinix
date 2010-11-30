class Member::Conversatio::BloggershipsController < Member::BaseController
  
  before_filter :find_blog, :only => [:index, :add_editor, :remove_editor]
  
  def index
    @bloggerships = @blog.bloggerships.paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'], :page => params[:page]
  end
  
=begin
  Método para añadir editores a un blog enviándole un mensaje
  1º buscamos el usuario bloggership que será el receptor
  2º si ese usuario está relacionado con el usuario actual(emisor), envíamos un mail al receptor
     indicándole que queremos añadirlo como editor de nuestro blog pasándole una url 
     para que confirme que desea ser editor del  blog. En el caso de que el usuario receptor
     pique en el link se ejecutará la acción de confirm_editor. Y mostramos por pantalla un flash[:ok].
  3º Sino está relacionado con el usuario actual mostramos un mensaje indicando 
     que no está relacionado con el usuario. 
  4º Redireccionamos a la ruta member_conversatio_blog_bloggerships.
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
                           :blog_url => conversatio_blog_url(blog),
      #url para confirmar pasándole usuario actual y el blog
                           :confirm_url => member_conversatio_blog_confirm_editor_url(@blog.id, current_user.profile))
      ).dispatch! 
      flash[:ok]= I18n.t("tog_conversatio.member.bloggerships.add_editor_request", :bloggership_name => u.profile.full_name)
    else
      flash[:error]=I18n.t("tog_conversatio.member.bloggerships.user_not_related")
    end
    
    redirect_to member_conversatio_blog_bloggerships_path(@blog)
  end
  
=begin
  Método para confirmar ser editor de un blog
  1º buscamos el usuario que fue emisor anteriormente
  2º si el usuario actual es editor del blog lo eliminamos, luego creamos como nuevo miembro 
     y editor del blog al usuario actual.Y envía un mensaje al usuario que le nominó 
     para ser editor indicándole que ha aceptado su solicitud.
     Y mostramos por pantalla un flash[:ok].
  3º Redireccionamos a la ruta member_conversatio_blog_bloggerships.
=end   
  
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
  
=begin
  Método para eliminar editores a un blog
  1º almacenamos el acutor del blog en la variable admin, y si el editor a eliminar es el usuario
     indicamos con un mensaje que no se puede elimnar al autor del blog. 
     De tal forma que nunca podrán eliminar al autor del blog.
  1º Si el usuario actual es editor y solo hay un editor no se puede autoeliminar
     hasta que no añada un nuevo editor.
  2º Si hay más editores del blog entonces eliminamos a ese editor.
  3º Redireccionamos a la ruta member_conversatio_blog_bloggerships.
=end  
  
  def remove_editor
    #u es el usuario al que le envíamos el mensaje
    u = User.find(params[:id]) 
    
    admin = @blog.author_id
    
    if u.id == admin
      flash[:error] = I18n.t("tog_conversatio.member.bloggerships.is_the_main_editor")
    else
      if @blog.bloggerships.size == 1
        flash[:error] = I18n.t("tog_conversatio.member.bloggerships.last_editor")
      else 
        
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
      end
    end
    redirect_to member_conversatio_blog_bloggerships_path(@blog)
    
  end
  
  private
  
  def find_blog
    @blog = Blog.find(params[:blog_id])
  end
end

