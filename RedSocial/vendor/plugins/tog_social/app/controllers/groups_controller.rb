class GroupsController < ApplicationController

  before_filter :login_required, :only => [:join, :leave]
  before_filter :load_group, :only => [:show, :join, :leave, :members, :accept_invitation, :reject_invitation, :share]

  def index
    if logged_in?
      @order = params[:order] || 'created_at'
      @page = params[:page] || '1'
      @asc = params[:asc] || 'desc'
      @groups = Group.active.public.paginate  :per_page => 10,
                                              :page => @page,
                                              :order => @order + " " + @asc
                                          
      respond_to do |format|
        format.html
        format.rss { render(:layout => false) }
      end
    else
      #render :action => :index
      redirect_to root_path
    end  
    
  end

  def search
    @order = params[:order] || 'name'
    @page = params[:page] || '1'
    @search_term = params[:search_term]
    term = '%' + @search_term + '%'
    @asc = params[:asc] || 'asc'
    @groups = Group.active.public.paginate  :per_page => 10,
                                            :conditions => ["(name like ? or description like ?)", term, term],
                                            :page => @page,
                                            :order => @order + " " + @asc
    respond_to do |format|
       format.html { render :template => "groups/index"}
       format.xml  { render :xml => @groups }
    end
  end

  def show 
  end

  def members
  end

  def blogs

    id = params[:id]
    @blogs = Blog.find(:all, :conditions => {:id_referencia => id, :tipo => 'Grupo'})
    
    respond_to do |format|
      format.html # blogs.html.erb
      format.xml  { render :xml => @blogs.to_xml }
    end                               
   
  end

  def events
    id = params[:id]
    @events = Event.find(:all, :conditions => {:id_referencia => id, :tipo => 'Grupo'})
    
    respond_to do |format|
      format.html # events.html.erb
      format.xml  { render :xml => @events.to_xml }
    end 
  end
  
  def photosets
    id = params[:id]
    @photosets = Photoset.find(:all, :conditions => {:id_referencia => id, :tipo => 'Grupo'})
    
    respond_to do |format|
      format.html # photosets.html.erb
      format.xml  { render :xml => @photosets.to_xml }
    end 
  end

  def forums
    id = params[:id]
    @forums = TogForum::Forum.find(:all, :conditions => {:id_referencia => id, :tipo => 'Grupo'})
    
    respond_to do |format|
      format.html # forums.html.erb
      format.xml  { render :xml => @forums.to_xml }
    end     
  end
  
  def tag
    @tag = params[:tag]
    @groups = Group.active.public.find_tagged_with(@tag)
    respond_to do |format|
      format.html # tag.html.erb
      format.xml  { render :xml => @groups.to_xml }
    end
  end

  def join
    if @group.members.include? current_user
      flash[:notice] = I18n.t("tog_social.groups.site.already_member")
    else
      if @group.pending_members.include? current_user
        flash[:notice] = I18n.t("tog_social.groups.site.request_waiting")
      else
        @group.join(current_user)
        if @group.moderated == true
          GroupMailer.deliver_join_request(@group, current_user)
          flash[:ok] = I18n.t("tog_social.groups.site.request_received")
        else
          @group.activate_membership(current_user)
          flash[:ok] = I18n.t("tog_social.groups.site.welcome", :name => @group.name)
        end
      end
    end
    redirect_to group_url(@group)
  end

  def leave
    if !@group.members.include?(current_user) && !@group.pending_members.include?(current_user)
      flash[:error] = I18n.t("tog_social.groups.site.not_member")
    else
      if @group.moderators.include?(current_user) && @group.moderators.size == 1
        flash[:error] = I18n.t("tog_social.groups.site.last_moderator")
      else
        @group.leave(current_user)
        #todo: eliminar cuando este claro que sucede si un usuario ya es miembro
        flash[:ok] = I18n.t("tog_social.groups.site.leaved")
      end
    end
    redirect_to member_groups_path
  end
  
  def accept_invitation
    if(@group.accept_invitation(current_user))
      flash[:ok] = I18n.t("tog_social.groups.site.invite.invitation_accepted")
    else
      flash[:error] = I18n.t("tog_social.groups.site.invite.you_are_not_invited")
    end
    redirect_to group_path(@group)
  end
  
  def reject_invitation
    if(@group.leave(current_user))
      flash[:ok] = I18n.t("tog_social.groups.site.invite.invitation_rejected")
    else
      flash[:error] = I18n.t("tog_social.groups.site.invite.you_are_not_invited")
    end
    redirect_to group_path(@group)
  end
  
  protected
    def load_group
      #TODO be more specific with this error control
      begin
        @group = Group.find(params[:id])
        raise I18n.t("tog_social.site.groups.unactive") unless @group.active?
      rescue
        flash[:error] = I18n.t("tog_social.groups.site.not_found")
        redirect_to groups_path
      end
    end

    def send_message_to_moderators(group, user, subject, body)
      group.moderators.each do |moderator|
        message = Message.new(
          :from     => user,
          :to       => moderator,
          :subject  => subject,
          :content  => body)
        message.dispatch!
      end
    end
end
