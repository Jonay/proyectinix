class Bloggership < ActiveRecord::Base
  belongs_to :blog
  belongs_to :user
  belongs_to :group
end
