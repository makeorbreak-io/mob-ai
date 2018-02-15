require "fileutils"

module Tasks
  class Compile < Struct.new(:job)
    def run
      FileUtils.rm_rf Dir.glob("builders/user_content/*")

      # TODO: remove .rb reference
      File.write("builders/user_content/player.rb", job["source_code"])

      `docker build -f builders/#{job["sdk"]}/Dockerfile builders/ -t robot-#{job["program_id"]} --network none`

      FileUtils.rm_rf Dir.glob("builders/user_content/*")

      { "docker_image": "robot-#{job["program_id"]}" }
    end

    def self.valid? params
      [
        params["sdk"] == "ruby",
        params["program_id"]&.match?(/\A[\w-]+\z/),
        params["source_code"]&.match?(/\A.+\z/),
      ].all?
    end
  end
end
