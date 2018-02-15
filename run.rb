require "sequel"
require "logger"

require "task_runner"

worker_id = ENV.fetch("WORKER_ID", "me")
database = Sequel.connect(
  ENV.fetch("DATABASE_URL"),
  loggers: [Logger.new($stderr)]
)

TaskRunner.new(database, worker_id).run
