module TogForum
  class Post < ActiveRecord::Base
    set_table_name "tog_forum_posts"

    white_list :only => [ :body ]

    belongs_to :user
    belongs_to :topic, :class_name => "TogForum::Topic"
    validates_length_of :body, :minimum => 4
    validates_presence_of :body

    acts_as_voteable

    unless Tog::Plugins.settings(:tog_forum, 'search.skip_indices')
      define_index do
        indexes body
      end

      def self.site_search(query, options = {})
        self.search query, options
      end
    end

    def after_create
      topic.update_attributes :last_post_at => created_at,
                              :last_post_by => user_id
    end

    def poster_profile
      self.user.profile rescue nil
    end

  end
end
