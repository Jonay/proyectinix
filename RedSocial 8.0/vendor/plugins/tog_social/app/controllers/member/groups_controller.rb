class Member::GroupsController < Member::BaseController
  
  before_filter :find_group, :except => [:index, :new, :create]
  before_filter :check_moderator, :except => [:index, :new, :create, :invite, :accept_invitation, :reject_invitation]
  
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
  
  def invite
    @group = Group.find(params[:membership][:group_id])
    user = User.find(params[:membership][:user_id])
    if @group.can_invite?(current_user)
      if @group.members.include? user
        flash[:notice] = I18n.t("tog_social.groups.site.already_member")
      else
        if @group.invited_members.include? user
          flash[:error] = I18n.t("tog_social.groups.site.invite.already_invited")
        else
          @group.invite(user)
          @message = Message.new(
          :from => current_user,
          :to => user,
          :subject => I18n.t("tog_social.groups.member.mail.invitation.subject", :group=>@group.name),
          :content => render_to_string(:partial => 'invite_mail', :locals =>{:group=>@group})
          )
          @message.dispatch!
          flash[:ok] = I18n.t("tog_social.groups.site.invite.invited")
        end
      end
    else
      flash[:error] = flash[:error] = I18n.t("tog_social.groups.site.invite.you_could_not_invite")
    end
    redirect_to profile_path(user.profile)
  end
  
  
  def manage_moderators
    @moderator_memberships = @group.moderator_memberships.paginate :per_page => Tog::Config['plugins.tog_core.pagination_size'], :page => params[:page]
  end


=begin
  Método para añadir moderadores a un grupo
  1º buscamos el usuario membership
  2º si ese usuario está relacionado con el usuario actual y es miembro del grupo
     eliminamos ese miembro del grupo llamando a @group.leave y creamos uno nuevo 
     con los parámetros @group, indicando que es moderator = true y estado activo
     y mostramos un mensaje indicando que el moderador se añadió.
  3º Sino está relacionado con el usuario actual y no es miembro del grupo mostramos 
     un mensaje indicando que no está relacionado con el usuario. 
  4º Redireccionamos a la ruta group_manage_moderators.
=end
  def add_moderator
    u = User.find(params[:membership][:user_id])
    if current_user.profile.is_related_to?(u.profile) and (@group.membership_of(u))
      @group.leave(u)
      @membership = u.memberships.create(:group_id => @group, :moderator => true,  :state => 'active')
      flash[:ok]= I18n.t("tog_social.groups.member.moderator.moderator_added")
    else
      flash[:error]=I18n.t("tog_social.groups.member.moderator.user_not_related")
    end
    redirect_to member_group_manage_moderators_path(@group)
  end
  
  
  def remove_moderator
    @membership = @group.memberships.find(params[:id]).destroy

    flash[:ok]=I18n.t("tog_social.groups.member.moderator.moderator_removed")
    redirect_to member_group_manage_moderators_path(@group)
  end
  
  
  protected
  
  
  def find_group
    @group = Group.find(params[:id]) if params[:id]
  end
  
  def check_moderator
    unless @group.moderators.include? current_user
      flash[:error] = I18n.t("tog_social.groups.member.not_moderator") 
      redirect_to group_path(@group)
    end
  end
  
end