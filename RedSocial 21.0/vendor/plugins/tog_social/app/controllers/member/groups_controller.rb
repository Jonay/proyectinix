class Member::GroupsController < Member::BaseController
  
  before_filter :find_group, :except => [:index, :new, :create]
  
  def index
    @moderator_memberships = current_user.moderator_memberships
    @plain_memberships = current_user.plain_memberships
  end
  
  def create
    @group = Group.new(params[:group])
    @group.author = current_user
    @group.save
    
    
    if @group.errors.empty?
      
      @group.join(current_user, true)
      #    @group.activate_membership(current_user)
      
      if current_user.admin == true || Tog::Config['plugins.tog_social.group.moderation.creation'] != true
        @group.activate!
        flash[:ok] = I18n.t("tog_social.groups.member.created")
        redirect_to group_path(@group)
      else
        
        admins = User.find_all_by_admin(true)        
        admins.each do |admin|
          Message.new(
            :from => current_user,
            :to   => admin,
            :subject => I18n.t("tog_social.groups.member.mail.activation_request.subject", :group_name => @group.name),
            :content => I18n.t("tog_social.groups.member.mail.activation_request.content", 
                               :user_name   => current_user.profile.full_name, 
                               :group_name => @group.name, 
                               :activation_url => edit_admin_group_url(@group)) 
          ).dispatch!     
        end
        
        flash[:warning] = I18n.t("tog_social.groups.member.pending")
        redirect_to groups_path
      end
    else
      render :action => 'new'
    end
    
  end
  
  def update
    @group.update_attributes!(params[:group])
    @group.tag_list = params[:group][:tag_list]
    @group.save
    flash[:ok] =  I18n.t("tog_social.groups.member.updated", :name => @group.name) 
    redirect_to group_path(@group)
  end
  
  def reject_member
    user = User.find(params[:user_id])
    if !user
      flash[:error] = I18n.t("tog_social.groups.member.user_doesnot_exists")
      redirect_to pending_members_paths(@group)
      return
    end
    @group.leave(user)
    if @group.membership_of(user)
      GroupMailer.deliver_reject_join_request(@group, current_user, user)
      flash[:ok] = I18n.t("tog_social.groups.member.user_rejected", :name => user.profile.full_name) 
    else
      flash[:error] = I18n.t("tog_social.groups.member.error") 
    end
    redirect_to member_group_pending_members_url(@group)
  end
  
  def accept_member
    user = User.find(params[:user_id])
    if !user
      flash[:error] = I18n.t("tog_social.groups.member.user_doesnot_exists")
      redirect_to pending_members_paths(@group)
      return
    end
    @group.activate_membership(user)
    if @group.members.include? user
      GroupMailer.deliver_accept_join_request(@group, current_user, user)
      flash[:ok] = I18n.t("tog_social.groups.member.user_accepted", :name => user.profile.full_name)
    else
      flash[:error] = I18n.t("tog_social.groups.member.error") 
    end
    redirect_to member_group_pending_members_url(@group)
  end
  
  def invitations
    @memberships = @group.memberships.paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'], :page => params[:page]
  end

=begin
  -- Método para enviar invitaciones a un grupo privado --
  1º) Cogemos el user al que deseamos invitar a nuestro clúster
  2º) Si el usuario ya es miebro mostramos un mensaje
      sino si el usuario ya ha sido invitado mostramos un mensaje
      sino si el usuario está relacionado con nosotros lo invitamos al grupo
      y le envíamos un mensaje indicándole que queremos añadirlo como miembro de nuestro grupo
      pasándole en ese mensaje la url para confirmar la solicitud.
  3º) Redireccionamos a la página de invitaciones.
=end
  def invite
    u = User.find(params[:membership][:user_id])
    group = @group
      if @group.members.include? u
        flash[:notice] = I18n.t("tog_social.groups.member.invitation.already_member")
      else
        if @group.invited_members.include? u
          flash[:error] = I18n.t("tog_social.groups.member.invitation.already_invited")
        else
          
          if current_user.profile.is_related_to?(u.profile)
      
            @group.invite(u)
           
            Message.new(
             :from => current_user,
             :to => u,
             :subject => I18n.t("tog_social.groups.member.mail.invitation.subject", :group_name => @group.name),
             :content => I18n.t("tog_social.groups.member.mail.invitation.content", :group_name => @group.name, 
                           :user_name   => current_user.profile.full_name, 
                           :membership_name => u.profile.full_name, 
                           :group_url => group_path(group),
                            #url para confirmar pasándole usuario actual y el grupo
                           :confirm_url => member_group_accept_invitation_url(current_user.profile, @group.id))
            ).dispatch!
      
           flash[:ok] = I18n.t("tog_social.groups.member.invitation.invited_membership_request", :membership_name => u.profile.full_name)
      
          else
            flash[:error]=I18n.t("tog_social.groups.member.invitation.user_not_related")
          end
      end
    end
    redirect_to member_group_manage_invitations_path(@group)
  end
  
=begin
  -- Método para aceptar invitaciones --
  1º) Si el usuario acepta la invitacion cambiamos su estado de invitado a activo y
      envía un mensaje al usuario que lo invitó.
  2º) Si el usuario no acepta ya es miembro.
=end
  def accept_invitation
    u = User.find(params[:id]) #emisor antes ahora receptor
    @group = Group.find(params[:group_id])#almacenamos el grupo para saber si el usuario actual es miembro del grupo
    if(@group.accept_invitation(current_user))
      Message.new(
          :from => current_user,
          :to => u,
          :subject => I18n.t("tog_social.groups.member.mail.confirm_invitation.subject", :user_name => current_user.profile.full_name),
          :content => I18n.t("tog_social.groups.member.mail.confirm_invitation.content", :u_name => u.profile.full_name, 
                           :user_name   => current_user.profile.full_name, 
                           :group_name => @group.name, 
                           :user_profile_url => profile_url(current_user.profile))
      ).dispatch! 
      flash[:ok] = I18n.t("tog_social.groups.member.invitation.invitation_accepted")
    else
      flash[:error] = I18n.t("tog_social.groups.member.invitation.already_member")
    end
    redirect_to group_path(@group)
  end
  
  
  def manage_moderators
    @moderator_memberships = @group.moderator_memberships.paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'], :page => params[:page]
  end
  
  
=begin
  Método para añadir moderadores a un grupo enviándole un mensaje
  1º buscamos el usuario membership que será el receptor
  2º si ese usuario está relacionado con el usuario actual(emisor), envíamos un mail al receptor
     indicándole que queremos añadirlo como moderador de nuestro clúster pasándole una url 
     para que confirme que desea ser moderador del clúster. En el caso de que el usuario receptor
     pique en el link se ejecutará la acción de confirm_moderator. Y mostramos por pantalla un flash[:ok].
  3º Sino está relacionado con el usuario actual mostramos un mensaje indicando 
     que no está relacionado con el usuario. 
  4º Redireccionamos a la ruta group_manage_moderators.
=end
  def add_moderator
    #receptor que será el moderador a añadir
    u = User.find(params[:membership][:user_id])
    #almacenamo el grupo para pasarlo por mensaje
    group= @group
    if current_user.profile.is_related_to?(u.profile) 
      Message.new(
          :from => current_user,
          :to => u,
          :subject => I18n.t("tog_social.groups.member.mail.add_moderator.subject", :group_name => @group.name),
          :content => I18n.t("tog_social.groups.member.mail.add_moderator.content", :group_name => @group.name, 
                           :user_name   => current_user.profile.full_name, 
                           :membership_name => u.profile.full_name, 
                           :group_url => group_path(group),
      #url para confirmar pasándole usuario actual y el grupo
                           :confirm_url => member_group_confirm_moderator_url(current_user.profile, @group.id))
      ).dispatch! 
      flash[:ok]= I18n.t("tog_social.groups.member.moderator.add_moderator_request", :membership_name => u.profile.full_name)
    else
      flash[:error]=I18n.t("tog_social.groups.member.moderator.user_not_related")
    end
    redirect_to member_group_manage_moderators_path(@group)
  end
  
=begin
  Método para confirmar ser moderador de un clúster
  1º buscamos el usuario que fue emisor anteriormente
  2º si el usuario actual es miembro del clúster lo eliminamos, luego creamos como nuevo miebro 
     y moderador del clúster al usuario actual.Y envía un mensaje al usuario que le nominó 
     para ser moderador indicándole que ha aceptado su solicitud
     Y mostramos por pantalla un flash[:ok].
  3º Redireccionamos a la ruta group_manage_moderators.
=end  
  
  def confirm_moderator 
    u = User.find(params[:id]) #emisor antes ahora receptor
    @group = Group.find(params[:group_id])#almacenamos el grupo para saber si el usuario actual es miembro del grupo
    
    if (@group.membership_of(current_user)) || (@group.members.include? current_user)
      @group.leave(current_user)
    end
    
    #creamos el nuevo miembro
    @membership = current_user.memberships.create(:group_id => @group.id, :moderator => true,  :state => 'active')
    Message.new(
          :from => current_user,
          :to => u,
          :subject => I18n.t("tog_social.groups.member.mail.confirm_moderator.subject", :user_name => current_user.profile.full_name),
          :content => I18n.t("tog_social.groups.member.mail.confirm_moderator.content", :u_name => u.profile.full_name, 
                           :user_name   => current_user.profile.full_name, 
                           :group_name => @group.name, 
                           :user_profile_url => profile_url(current_user.profile))
    ).dispatch! 
    
    flash[:ok]= I18n.t("tog_social.groups.member.moderator.moderator_confirmed", :group_name => @group.name)
    
    redirect_to member_group_manage_moderators_path(@group)
  end
  
=begin
  Método para eliminar moderadores a un grupo
  1º Si el usuario actual es moderador y solo hay un moderador no se puede autoeliminar
     hasta que no añada un nuevo moderador.
  2º Si hay más moderadores del grupo entonces eliminamos a ese moderador.
  3º Redireccionamos a la ruta group_manage_moderators.
=end
  def remove_moderator
    #u es el usuario al que le envíamos el mensaje
    u = User.find(params[:user_id])
    if @group.moderators.include?(current_user) && @group.moderators.size == 1
      flash[:error] = I18n.t("tog_social.groups.site.last_moderator")
    else    
      #membership es el miembro a eliminar
      @membership = @group.memberships.find(params[:membership]).destroy
      Message.new(
             :from => current_user,
             :to => u,
             :subject => I18n.t("tog_social.groups.member.mail.remove_moderator.subject", :user_name => current_user.profile.full_name),
             :content => I18n.t("tog_social.groups.member.mail.remove_moderator.content", :u_name => u.profile.full_name, 
                             :user_name   => current_user.profile.full_name, 
                             :group_name => @group.name, 
                             :user_profile_url => profile_url(current_user.profile))
      ).dispatch!
      flash[:ok]=I18n.t("tog_social.groups.member.moderator.moderator_removed")
    end
    redirect_to member_group_manage_moderators_path(@group)
  end
  
  
  protected
  
  
  def find_group
    @group = Group.find(params[:id]) if params[:id]
  end
  
  
end