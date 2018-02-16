require "fileutils"
require "tmpdir"

module Tasks
  class Compile < Struct.new(:params)
    def run
      sdk, program_id, source_code = params.values_at("sdk", "program_id", "source_code")

      Dir.mktmpdir("robot-#{program_id}-") do |tmpdir|
        FileUtils.cp_r(File.join("builders", sdk, "Dockerfile"), tmpdir)
        FileUtils.cp_r(File.join("engines", sdk, "."), File.join(tmpdir, "engine"))
        File.write(File.join(tmpdir, "source_code"), source_code)

        `docker build #{tmpdir} -t robot-#{program_id} --network none`

        { "docker_image": "robot-#{program_id}" }
      end
    end

    class << self
      def builders
        @builders ||= Dir["builders/*"].map { |x| x.split("/").last }
      end

      def valid? params
        [
          builders.include?(params["sdk"]),
          /\A[\w-]+\z/.match?(params["program_id"]),
          /\A.+\z/.match?(params["source_code"]),
        ].all?
      end
    end
  end
end
