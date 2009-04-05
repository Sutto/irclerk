require 'rubygems'
require 'couchrest'
require 'haml'
require 'ostruct'

require 'sinatra' unless defined?(Sinatra)

configure do
  SiteConfig = OpenStruct.new(
                 :title    => 'IRClerk',
                 :author   => 'Your Name',
                 :url_base => 'http://localhost:4567/',
                 :db_uri   => File.read(File.join(File.dirname(__FILE__), "..", "database_uri")).strip
               )

  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
end
