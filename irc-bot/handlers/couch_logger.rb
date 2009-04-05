require 'couchrest'
require 'stringex'

class CouchLogger < Marvin::LoggingHandler
  
  cattr_accessor :database_location, :database
  self.database_location = File.read(File.join(File.dirname(__FILE__), "..", "..", "database_uri")).strip
  self.database = CouchRest.database!(self.database_location)
  
  attr_accessor :messages_buffer
  
  def setup_logging
    self.messages_buffer = []
    EventMachine.add_periodic_timer(30) { self.dump_messages! }
  end
  
  def teardown_logging
    dump_messages!
  end
  
  def log_message(server, nick, target, message)
    if (target[0, 1] == "#")
      self.messages_buffer << {
        :type        => "message",
        :server      => server,
        :origin      => nick,
        :channel     => target,
        :message     => message,
        :received_at => (t = Time.now.utc),
        :date        => t.strftime("%Y/%m/%d"),
        :slug        => target.gsub(/[^a-zA-Z0-9\-\_]+/, "")
      }
    end
  end
  
  def dump_messages!
    messages = self.messages_buffer
    self.messages_buffer = []
   unless messages.empty?
     logger.info "Dumping #{messages.size} messages to disk"
     self.database.bulk_save(messages)
    end
  end
  
end