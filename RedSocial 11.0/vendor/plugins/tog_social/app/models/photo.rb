class Photo < ActiveRecord::Base
  
  belongs_to :group
  belongs_to :photoset
  
end