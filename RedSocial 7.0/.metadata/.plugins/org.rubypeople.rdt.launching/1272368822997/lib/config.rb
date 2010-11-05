=begin
---------------------------------------------------------- Class: Config
     (no description...)
------------------------------------------------------------------------


Class methods:
--------------
     datadir

=end
module Config

  # -------------------------------------------------------- Config::datadir
  #      Config::datadir(package_name)
  # ------------------------------------------------------------------------
  #      Return the path to the data directory associated with the given
  #      package name. Normally this is just
  #      "#{Config::CONFIG['datadir']}/#{package_name}", but may be modified
  #      by packages like RubyGems to handle versioned data directories.
  # 
  def self.datadir(arg0)
  end

end
