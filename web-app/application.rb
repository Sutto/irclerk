require 'rubygems'
require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  
  def newer_link(label = "Newer", title = "Show newer messages")
    unless @messages.first.nil?
      "<a id='newer-messages' href='#{@channel.after_path(@messages.first.offset)}' title='#{title}'>#{label}</a>"
    end
  end
  
  def older_link(label = "Older", title = "Show older messages")
    unless @messages.last.nil?
      "<a id='older-messages' href='#{@channel.before_path(@messages.last.offset)}' title='#{title}'>#{label}</a>"
    end
  end
  
end

# root page
get '/' do
  @channels = Channel.all
  haml :root
end

# Channel Routes

get '/c/:slug' do
  redirect "/c/#{params[:slug]}/recent"
end

get '/c/:slug/recent' do
  @channel = Channel.from_slug(params[:slug])
  @messages = Message.recent(@channel)
  haml :listing
end

get '/c/:slug/b/:offset' do
  @channel = Channel.from_slug(params[:slug])
  @messages = Message.all_before(@channel, params[:offset].to_i(36))
  haml :listing
end

get '/c/:slug/a/:offset' do
  @channel = Channel.from_slug(params[:slug])
  @messages = Message.all_after(@channel, params[:offset].to_i(36))
  haml :listing
end
