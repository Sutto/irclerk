Database = CouchRest.database!(SiteConfig.db_uri)

class Channel
  
  attr_accessor :name, :slug
  
  def initialize(name, slug)
    @name = name
    @slug = slug
  end
  
  def inspect
    "#<Channel name=#{@name.inspect} slug=#{@slug.inspect}>"
  end
  
  def ==(other)
    other.is_a?(self.class) && other.name == @name && other.slug == @slug
  end
  
  def recent_path
    "/c/#{self.slug}/recent"
  end
  
  def before_path(offset)
    "/c/#{self.slug}/b/#{offset.to_s(36)}"
  end
  
  def after_path(offset)
    "/c/#{self.slug}/a/#{offset.to_s(36)}"
  end
  
  def self.all
    Database.view('channels/name', :group => true, :group => true)['rows'].map do |row|
      Channel.new(row["value"], row["key"])
    end
  end
  
  def self.from_slug(slug)
    doc = Database.view("channels/name", :key => slug, :group => true)['rows'].first
    if doc.nil?
      return nil
    else
      return Channel.new(doc["value"], doc["key"])
    end
  end
  
end

class Message
  
  cattr_accessor :per_page, :max_date_offset
  self.per_page = 10
  self.max_date_offset = 99999999999999
  
  attr_accessor :_id, :_rev, :channel, :message, :origin, :received_at, :date, :offset
  
  def initialize(doc)
    params = doc["value"]
    @_id  = params["_id"]
    @_rev = params["_rev"]
    @channel = Channel.new(params["channel"], params["slug"])
    @message = params["message"]
    @origin  = params["origin"]
    @received_at = params["received_at"] && Time.parse(params["received_at"])
    @date    = params["date"]
  end
  
  def ==(other)
    other.is_?(self.class) && self._id == other._id
  end
  
  def self.all_before(channel, offset)
    all_by_date(channel, offset - 1)
  end
  
  def self.all_after(channel, offset)
    all_by_date(channel, offset + 1, :reversed => true)
  end
  
  def self.recent(channel)
    all_before(channel, 99999999999999)
  end
  
  protected
  
  # end_time = since ? since.to_i : 99999999999999
  # real_opts = {:descending => true, :limit => PER_PAGE}.merge(opts)
  # real_opts[:startkey] = [channel, end_time]
  # real_opts[:endkey]   = [channel]
  # view = DB.view("messages/recent", real_opts)
  
  def self.all_by_date(channel, offset, opts = {})
    real_opts = {:limit => self.per_page, :descending => true}.merge(opts)
    reversed = real_opts.delete(:reversed)
    if reversed
      real_opts[:descending] = false # Flip it
      real_opts[:startkey] = [channel.slug, offset]
      real_opts[:endkey] = [channel.slug, self.max_date_offset]
    else
      real_opts[:startkey] = [channel.slug, offset]
      real_opts[:endkey] = [channel.slug]
    end
    results = Database.view('messages/recent', real_opts)['rows'].map do |document|
      message = Message.new(document)
      message.offset = document["key"][1].to_i
      message
    end
    results.reverse! if reversed
    return results
  end
  
end