class ProfilesController < ApplicationController
  
  def index
    if logged_in?
      @order = params[:order] || 'created_at'
      @page = params[:page] || '1'
      @asc = params[:asc] || 'desc'   
      @profiles = Profile.active.paginate :per_page => Tog::Config["plugins.tog_social.profile.list.page.size"],
                                   :page => @page,
                                   :order => "profiles.#{@order} #{@asc}"
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @profiles }
      end
    else
      #render :action => :index
      redirect_to root_path
    end 
  end
  
  def show
    @profile = Profile.active.find(params[:id])
    store_location
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profile }
    end
  end
  
  
  def edit_responsible
    @responsible = Responsible.find(params[:id])
  end
  
  def update_responsible
    profile = current_user.profile
    responsible = current_user.profile.responsibles.find(params[:id])
    responsible.update_attributes!(params[:responsible])
    responsible.save
    flash[:ok] = I18n.t("tog_social.profiles.member.responsible_updated") 
    redirect_to profile_path(profile)
  end
  
  def remove_responsible
    profile = current_user.profile
    responsible = current_user.profile.responsibles.find(params[:id])
    responsible.destroy
    flash[:ok] = I18n.t("tog_social.profiles.member.responsible_removed") 
    redirect_to profile_path(profile)
  end
  
  def pymes
    if logged_in?
      @pymes = User.find(:all, :conditions => {:es_pyme => 'Organización'}) 
      respond_to do |format|
        format.html # pymes.html.erb
        format.xml  { render :xml => @pymes }
      end
    else
      #render :action => :index
      redirect_to root_path
    end 
  end
  
  def users
    if logged_in?
      @usuarios = User.find(:all, :conditions => {:es_pyme => 'Usuario'})
      respond_to do |format|
        format.html # users.html.erb
        format.xml  { render :xml => @users }
      end
    else
      #render :action => :index
      redirect_to root_path
    end 
  end
  
end