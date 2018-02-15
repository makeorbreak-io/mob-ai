require 'tasks/compile'
require 'tasks/compete'

class TaskRunner < Struct.new(:database, :worker_id)
  def self.task type
    {
      "compile" => Tasks::Compile,
      "compete" => Tasks::Compete,
    }.fetch(type)
  end

  def run
    loop do
      reserve_job or sleep 5

      process_pending_jobs
    end
  end

  private

  def process_pending_jobs
    while (job = jobs.where(status: "reserved", worker: worker_id).first) do
      process_job job
    end
  end

  def process_job(job)
    update_job(job, status: "processing")

    begin
      result = self.class
        .task(job[:type])
        .new(JSON.parse(job[:payload]))
        .run

      update_job(job, status: "processed", result: JSON.generate(result))
    rescue => e
      puts e
      update_job(job, status: "error", result: e.to_json)
    end
  end

  def update_job(job, params)
    jobs.where(id: job[:id]).update(params.merge(updated_at: Time.now))

    # POST callback with status & results
  end

  def reserve_job
    jobs.
      where(status: "new", id: jobs.where(status: "new").limit(1).select(:id)).
      update(worker: worker_id, status: "reserved") == 1
  end

  def jobs
    database[:jobs]
  end
end
