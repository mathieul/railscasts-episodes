DB_SERVER = CouchRest.new
DB_SERVER.default_database = "navigator-#{Rails.env}"