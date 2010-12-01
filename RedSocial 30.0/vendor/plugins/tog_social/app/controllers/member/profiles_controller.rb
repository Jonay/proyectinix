class Member::ProfilesController < Member::BaseController

  def edit
    @profile = current_user.profile
  end

=begin
  Definimos la función update, que consiste en actualizar el perfil de un usuario
  y crear los responsbles de la empresa ya que son dos formularios que están anidados
  en la vista edit.html.erb(tog_social/app/views/member)
=end
  def update
    profile = current_user.profile
    profile.update_attributes!(params[:profile])
    #creamos los responsables de empresa siempre que el perfil sea una organización
    if profile.user.es_pyme == 'Organización'
      @responsibles = current_user.profile.responsibles.build(params[:responsible].values)
      #recorremos mediante un bucle los responsables y si el nombre es '' lo eliminamos 
      #sino lo asignamos a la tabla de responsables
      @responsibles.each do |r|
        if r.responsible_name == ''
           r.destroy
         else
           profile.responsibles << r
        end
      end
    end
    profile.save
    flash[:ok] = I18n.t("tog_social.profiles.member.updated") 
    redirect_to profile_path(profile)
  rescue ActiveRecord::RecordInvalid
    flash[:error] = I18n.t("tog_social.profiles.member.error")
    redirect_to edit_member_profile_path(profile)
  end

end