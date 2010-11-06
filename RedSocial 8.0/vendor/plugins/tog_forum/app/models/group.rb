class Group < ActiveRecord::Base
  has_many :forums
  has_many :topics
  has_many :posts
end