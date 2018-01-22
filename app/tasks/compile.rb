module Tasks
  class Compile < Struct.new(:job)
    def run
      `docker build -f builders/ruby/Dockerfile builders/ -t robot-#{job["program_id"]} --network none`

      # docker push

      { "docker_image": "robot-#{job["program_id"]}" }
    end
  end
end
