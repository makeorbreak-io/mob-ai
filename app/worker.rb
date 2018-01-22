require 'tasks/compile'
require 'tasks/compete'

class Worker < Struct.new(:database, :worker_id)
  def self.task type
    {
      "compile" => Tasks::Compile,
      "compete" => Tasks::Compete,
    }.fetch(type)
  end

  def process_pending_jobs(database, worker_id)
    while (job = database[:jobs].where(status: "reserved", worker: worker_id).first) do
      update_job(job, status: "processing")

      begin
        result = self.class.task(job[:type]).new(JSON.parse(job[:payload])).run
        update_job(job, status: "processed", result: JSON.generate(result))
      rescue => e
        puts e
        update_job(job, status: "error")
      end
    end
  end

  def update_job(job, params)
    database[:jobs].where(id: job[:id]).update(params.merge(updated_at: Time.now))
  end

  def reserve_job(database, worker_id)
    database[:jobs].
      where(id: database[:jobs].where(status: "new").limit(1).select(:id)).
      update(worker: worker_id, status: "reserved") == 1
  end

  def run
    loop do
      sleep 5 unless reserve_job(database, worker_id)

      process_pending_jobs(database, worker_id)
    end
  end
end

