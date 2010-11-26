class UpgradeTogConclave20100826115137 < ActiveRecord::Migration
  def self.up
    
      migrate_plugin "tog_conclave", 8
    
  end

  def self.down
    
      migrate_plugin "tog_conclave", 7
    
  end
end