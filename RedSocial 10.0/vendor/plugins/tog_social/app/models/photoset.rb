class Photoset < ActiveRecord::Base
  
  belongs_to :group
  has_many   :photos
  
end