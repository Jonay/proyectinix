class InstallTogPlugins20101027113423 < ActiveRecord::Migration
  def self.up
    
      migrate_plugin "tog_user", 1
    
      migrate_plugin "tog_conclave", 8
    
      migrate_plugin "tog_social", 6
    
      migrate_plugin "tog_core", 7
    
      migrate_plugin "tog_forum", 1
    
      migrate_plugin "tog_picto", 7
    
      migrate_plugin "tog_mail", 2
    
      migrate_plugin "tog_conversatio", 5
    
  end

  def self.down
    
      migrate_plugin "tog_conversatio", 0
    
      migrate_plugin "tog_mail", 0
    
      migrate_plugin "tog_picto", 0
    
      migrate_plugin "tog_forum", 0
    
      migrate_plugin "tog_core", 0
    
      migrate_plugin "tog_social", 0
    
      migrate_plugin "tog_conclave", 0
    
      migrate_plugin "tog_user", 0
    
  end
end