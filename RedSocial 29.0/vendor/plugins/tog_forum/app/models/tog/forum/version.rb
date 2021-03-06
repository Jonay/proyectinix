module Version
  MAJOR = 0
  MINOR = 1
  TINY  = 0
  MODULE = "tog_forum"
  STRING = [MAJOR, MINOR, TINY].join('.')

  class << self
    def to_s
      STRING
    end
    def full_version
      "#{MODULE} #{STRING}"
    end
    alias :to_str :to_s
  end
end
