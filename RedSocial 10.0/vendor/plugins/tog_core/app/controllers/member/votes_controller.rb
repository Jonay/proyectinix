class Member::VotesController < Member::BaseController

  def create
    voteable_type = params[:type]
    voteable = voteable_type.constantize.find(params[:id])

    if voteable.voted_by_user?(current_user)
      flash[:error] = I18n.t('tog_core.site.voting.already_voted')
    else
      vote = params[:vote].eql?('for') ? true : false
      voteable.votes << Vote.new(:vote => vote, :user => current_user)
      flash[:ok] = I18n.t('tog_core.site.voting.added')
    end
    respond_to do |format|
      format.html { redirect_to request.referer }
    end
  end
end