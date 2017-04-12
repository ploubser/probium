require 'logger'

class Log
  @@log = Logger.new(STDOUT)
  @@log.level = Logger::WARN

  def self.initialize
    @@log.level = Logger::DEBUG
    @@log.formatter = proc do |severity, datetime, progname, msg|
      calling_position = caller[5].split(/^.+\//).last.split(/:/)[0,2].join(':') # gross
      "[#{datetime}] #{calling_position}: - #{msg}\n"
    end
  end

  def self.debug(&blk)
    @@log.debug &blk
  end
end
