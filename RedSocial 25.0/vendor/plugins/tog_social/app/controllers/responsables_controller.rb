class Member::ResponsablesController < Member::BaseController
  
  before_filter :find_responsable_profile
  
  def add_responsable
    if @responsable.añadir_responsable(current_user.profile) 
      flash[:ok]=I18n.t("tog_social.friendships.member.responsable.request", :responsable_name => @responsable.full_name)
      Message.new(
        :from => current_user,
        :to   => @responsable.user,
        :subject => I18n.t("tog_social.friendships.member.mail.request_responsable.subject", :user_name => current_user.profile.full_name),
        :content => I18n.t("tog_social.friendships.member.mail.request_responsable.content", 
                           :user_name   => current_user.profile.full_name, 
                           :responsable_name => @responsable.full_name, 
                           :user_profile_url => profile_url(current_user.profile) , 
                           :confirm_url      => member_confirm_responsable_url(current_user.profile))
      ).dispatch!
    end
    redirect_back_or_default(profile_path(current_user.profile))
  end
  
  def confirm_responsable
    if @responsable.añadir_responsable1(current_user.profile) 
      flash[:ok]=I18n.t("tog_social.friendships.member.responsable.confirmed", :responsable_name => @responsable.full_name)
      Message.new(
        :from => current_user,
        :to   => @responsable.user,
        :subject => I18n.t("tog_social.friendships.member.mail.confirm_responsable.subject", :user_name => current_user.profile.full_name),
        :content => I18n.t("tog_social.friendships.member.mail.confirm_responsable.content", 
                           :user_name   => current_user.profile.full_name, 
                           :responsable_name => @responsable.full_name, 
                           :user_profile_url => profile_url(current_user.profile)) 
      ).dispatch! 
    end
    
    redirect_back_or_default(profile_path(current_user.profile))
  end
  
  def remove_responsable
    if @responsable.eliminar_responsable(current_user.profile)
      flash[:ok]=I18n.t("tog_social.friendships.member.exresponsible", :user_name => @responsable.full_name)
      Message.new(
        :from => current_user,
        :to   => @responsable.user,
        :subject => I18n.t("tog_social.friendships.member.mail.remove_responsable.subject", :user_name => current_user.profile.full_name),
        :content => I18n.t("tog_social.friendships.member.mail.remove_responsable.content", 
                           :user_name   => current_user.profile.full_name, 
                           :responsable_name => @responsable.full_name, 
                           :user_profile_url => profile_url(current_user.profile))
      ).dispatch!
    end
    redirect_back_or_default(profile_path(current_user.profile))    
  end
  
    
  private
  def find_responsable_profile
    @responsable = Profile.find(params[:responsable_id])
    unless @responsable
      flash[:error] = I18n.t("tog_social.friendships.member.not_found", :id => params[:responsable_id].to_s)
      redirect_to profiles_path
    end
  end  
end
