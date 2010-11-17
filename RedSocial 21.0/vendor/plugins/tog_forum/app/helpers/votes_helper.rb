module VotesHelper
  def vote_link(voteable, vote)
    link_to I18n.t("tog_core.site.voting.#{vote.to_s}"),
      member_vote_path(:type => voteable.class.name, :id => voteable.id, :vote => vote)
  end
end