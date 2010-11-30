class Group < ActiveRecord::Base
  has_many :bloggerships
  has_many :blogs, :through => :bloggerships
end