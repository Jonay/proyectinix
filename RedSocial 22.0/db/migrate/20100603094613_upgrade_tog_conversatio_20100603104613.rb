class UpgradeTogConversatio20100603104613 < ActiveRecord::Migration
  def self.up
    
      migrate_plugin "tog_conversatio", 5
    
  end

  def self.down
    
      migrate_plugin "tog_conversatio", 0
    
  end
end