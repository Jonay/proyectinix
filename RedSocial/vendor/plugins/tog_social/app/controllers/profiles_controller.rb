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

end
