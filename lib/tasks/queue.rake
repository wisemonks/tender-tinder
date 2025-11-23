namespace :db do
  namespace :queue do
    desc "Load the queue schema"
    task schema_load: :environment do
      # Get the database configuration
      db_config = Rails.application.config.database_configuration[Rails.env]
      queue_config = db_config["queue"]

      if queue_config.nil?
        puts "No queue database configured in database.yml"
        exit 1
      end

      # Establish connection to queue database
      ActiveRecord::Base.establish_connection(queue_config)

      # Load the schema
      load Rails.root.join("db/queue_schema.rb")

      # Restore the primary connection
      ActiveRecord::Base.establish_connection(:primary)

      puts "Queue schema loaded successfully!"
    end
  end
end
