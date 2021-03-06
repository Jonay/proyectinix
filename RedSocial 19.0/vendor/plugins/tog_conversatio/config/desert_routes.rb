namespace(:conversatio) do |conversatio|
  conversatio.resources :blogs, :path_prefix => "" do |blog|
    blog.resources :posts
  end
end

with_options(:controller => 'conversatio/posts', :conditions => { :method => :get }) do |post|
  post.tag_conversatio_blog_posts      '/blogs/:blog_id/posts/tag/:tag_name', :action => 'by_tag'
  post.tag_conversatio_blogs_posts     '/blogs/posts/tag/:tag_name',          :action => 'all_by_tag'
  post.with_options(:action => 'archives') do |archive|
    archive.daily_archives_conversatio_blog_posts   '/blogs/:blog_id/archives/:year/:month/:day', :action => 'archives'
    archive.monthly_archives_conversatio_blog_posts '/blogs/:blog_id/archives/:year/:month', :day => nil, :action => 'archives'
    archive.yearly_archives_conversatio_blog_posts  '/blogs/:blog_id/archives/:year', :month => nil, :day => nil, :action => 'archives'
  end
end


namespace(:member) do |member| 
  member.namespace(:conversatio) do |conversatio|
    conversatio.resources :blogs do |blog|
      blog.resources :posts
      blog.resources :bloggerships, :as => 'editors', :only => [:index] 
      blog.add_editor       '/:blog_id/add_editor',                     :controller => 'bloggerships',  :action => 'add_editor'
      blog.confirm_editor   '/:user_id/:blog_id/confirm_editor',        :controller => 'bloggerships',  :action => 'confirm_editor' 
      blog.remove_editor    '/:id/remove_editor/:bloggership',          :controller => 'bloggerships',  :action => 'remove_editor'
    end
  end
end

