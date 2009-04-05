Marvin::Loader.before_run do
  CouchLogger.register! if Marvin::Loader.client?
end