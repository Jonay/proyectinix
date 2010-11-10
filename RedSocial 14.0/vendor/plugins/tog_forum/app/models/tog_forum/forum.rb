module TogForum
  Tog::Config["plugins.tog_forum.search.skip_indices"] = true
  class Forum < ActiveRecord::Base    
    set_table_name "tog_forum_forums"
    
    white_list :only => [ :title ]
    
    belongs_to :user
    belongs_to :reference, :class_name => "Group", :foreign_key => "id_referencia"
    
    has_many :topics, :class_name => "TogForum::Topic", :order => "created_at DESC", :dependent => :destroy
    has_many :posts, :through => :topics, :source => :posts, :order => "created_at DESC"
    validates_presence_of :title, :message => I18n.t("tog_forum.model.write_title")
    validates_presence_of :user_id
    validates_presence_of :id_referencia, :message => I18n.t("tog_forum.model.select_for_who") 

    unless Tog::Plugins.settings(:tog_forum, 'search.skip_indices')
      define_index do
        indexes title
      end

      def self.site_search(query, options = {})
        self.search query, options
      end
    end 

    def validate
      errors.add(:user_id, "must be an administrator") unless user
    end

    def self.top_level
      self.find(:first, :order => "updated_at DESC")
    end
    
    ## if your site depends on a single forum existing (has a flat structure of topics -> posts)
    ## this method will be called if no forum can be found 
    ## this is a configurable option config["plugins.tog_forum.ensure_top_level"]
    def self.create_top_level
      forum_title = Tog::Config['plugins.tog_core.site.name']
      self.create(:title => forum_title)
    end

  end
end
