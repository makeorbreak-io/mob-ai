require "sequel"
require "logger"

require "worker"

worker_id = ENV.fetch("WORKER_ID", "me")
database = Sequel.connect(
  ENV.fetch("DATABASE_URL", "postgres://localhost/mob-ai"),
  loggers: [Logger.new($stderr)]
)

Worker.new(database, worker_id).run
