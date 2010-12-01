class Member::ResponsiblesController < Member::BaseController
  
  def update_responsibles
    @responsibles = current_user.responsibles.build(params[:responsible].values)
    #recorremos mediante un bucle los responsables y si el nombre es '' lo eliminamos 
    #sino lo asignamos a la tabla de responsables
    @responsibles.each do |r|
      if r.responsible_name == ''
        r.destroy
      else
        profile.responsibles << r
      end
    end
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