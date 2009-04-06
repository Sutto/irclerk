require 'rubygems'
require 'sinatra'
require 'spec'
require 'spec/interop/test'
require 'rack/test'

# set test environment
Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require 'application'

ENV['SILENTIMPORT'] = 'true'
SiteConfig.db_uri += "-test"

def reset_database!
  system File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "couchdb-setup", "initialize-database")), SiteConfig.db_uri
end

Spec::Runner.configure do |config|
  
  config.before(:each) do
    reset_database!
  end
  
end
