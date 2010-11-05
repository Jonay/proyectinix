=begin
---------------------------------------------------------- Class: TempIO
     A StringIO duck-typed class that uses Tempfile instead of String as
     the backing store.

------------------------------------------------------------------------


Class methods:
--------------
     new


Instance methods:
-----------------
     method_missing, respond_to?, string

=end
class IO < Object
  include File::Constants
  include Enumerable

  def self.sysopen(arg0, arg1, *rest)
  end

  def self.popen3(arg0, arg1, *rest)
  end

  def self.select(arg0, arg1, *rest)
  end

  def self.read(arg0, arg1, *rest)
  end

  def self.popen(arg0, arg1, *rest)
  end

  def self.open(arg0, arg1, *rest)
  end

  # ------------------------------------------------------------ TempIO::new
  #      TempIO::new(string = '')
  # ------------------------------------------------------------------------
  #      (no description...)
  def self.new(arg0, arg1, *rest)
  end

  def self.pipe
  end

  def self.for_fd(arg0, arg1, *rest)
  end

  def self.foreach(arg0, arg1, *rest)
  end

  def self.readlines(arg0, arg1, *rest)
  end

  def ioctl
  end

  def tty?
  end

  def pos=
  end

  def sync
  end

  def ungetc
  end

  def seek
  end

  def lineno
  end

  def puts
  end

  def putc
  end

  def readpartial
  end

  def each_line
  end

  def gets
  end

  def to_inputstream
  end

  def readlines
  end

  def isatty
  end

  def <<
  end

  def reopen
  end

  def to_channel
  end

  def eof?
  end

  def print
  end

  def read
  end

  def to_io
  end

  def each_byte
  end

  def initialize_copy
  end

  def getc
  end

  def close_write
  end

  def close_read
  end

  def pid
  end

  def readchar
  end

  def to_i
  end

  def stat
  end

  def lineno=
  end

  def flush
  end

  def binmode
  end

  def readline
  end

  def read_nonblock
  end

  def rewind
  end

  def printf
  end

  def sysseek
  end

  def tell
  end

  def fileno
  end

  def fsync
  end

  def write_nonblock
  end

  def fcntl
  end

  def eof
  end

  def sysread
  end

  def close
  end

  def sync=
  end

  def to_outputstream
  end

  def closed?
  end

  def pos
  end

  def syswrite
  end

  def write
  end

  def each
  end

end
