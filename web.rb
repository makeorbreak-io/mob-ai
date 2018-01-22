require "sinatra"
require "sequel"
require "logger"

require "worker"

database = Sequel.connect(
  ENV.fetch("DATABASE_URL", "postgres://localhost/mob-ai"),
  loggers: [Logger.new($stderr)]
)

post "/jobs" do
  params = JSON.parse(request.body.read)

  raise unless Worker.task(params["type"]).valid?(params["payload"])

  database[:jobs].insert(
    type: params["type"],
    payload: JSON.generate(params["payload"]),
    status: "new",
  )
end
