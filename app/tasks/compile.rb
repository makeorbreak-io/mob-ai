module Tasks
  class Compile < Struct.new(:job)
    def run
      `docker build -f builders/ruby/Dockerfile builders/ -t robot-#{job["program_id"]} --network none`

      # docker push

      { "docker_image": "robot-#{job["program_id"]}" }
    end

    def self.valid? params
      [
        params["sdk"] == "ruby",
        params["program_id"].match?(/\A[\w-]+\z/),
        params["source_code"].match?(/\A.+\z/),
      ].tap { |conditions| puts conditions }.all?
    end
  end
end
