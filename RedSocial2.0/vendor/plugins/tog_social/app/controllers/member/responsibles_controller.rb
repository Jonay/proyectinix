class Member::ResponsiblesController < Member::BaseController

  def create
    @responsibles = current_user.responsibles.build(params[:responsible].values)
    @responsible.save!
    
    flash[:ok] = I18n.t("tog_picto.member.responsibles_created") 
    redirect_to profile_path(profile)
  end

  def update
    responsible.update_attributes!(params[:responsibles])
    responsible.save
    flash[:ok] = I18n.t("tog_social.profiles.member.responsibles_created") 
    redirect_to profile_path(profile)
  end

end