require "sinatra"
require "sequel"
require "logger"

require "worker"

database = Sequel.connect(
  ENV.fetch("DATABASE_URL", "postgres://localhost/mob-ai"),
  loggers: [Logger.new($stderr)]
)

def serialize job
  {
    id: job[:id],
    type: job[:type],
    status: job[:status],
    result: JSON.parse(job[:result] || "null"),
    updated_at: job[:updated_at]&.to_s,
  }
end

before do
  content_type 'application/json'
end

post "/jobs" do
  type, payload = JSON.parse(request.body.read).values_at("type", "payload")

  if TaskRunner.task(type).valid?(payload)
    database[:jobs]
      .returning(:id)
      .insert(type: type, payload: JSON.generate(payload), status: "new")
      .first.to_json
  else
    400
  end
end

get "/jobs/:id" do
  serialize(database[:jobs].where(id: params[:id]).first).to_json
end

delete "/jobs/:id" do
  database[:jobs]
    .where(status: "new", id: params[:id])
    .update(status: "cancelled")

  204
end

get "/jobs" do
  database[:jobs].all.map { |job| serialize job }.to_json
end
