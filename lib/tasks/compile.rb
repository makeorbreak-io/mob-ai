require "fileutils"
require "tmpdir"

module Tasks
  class Compile < Struct.new(:params)
    def run
      sdk, program_id, source_code = params.values_at("sdk", "program_id", "source_code")

      Dir.mktmpdir("robot-#{program_id}-") do |tmpdir|
        bot_filename = File.read(File.join("sdks", sdk, ".mob-ai-filename")).strip
        FileUtils.cp_r(File.join("sdks", sdk, "."), File.join(tmpdir))
        File.write(File.join(tmpdir, bot_filename), source_code)

        Dir.chdir(tmpdir) do
          `docker build . -f Dockerfile.base -t mob-ai-#{sdk}`
          `docker build . -f Dockerfile.builder -t robot-#{program_id} --network none`
        end

        { "docker_image": "robot-#{program_id}" }
      end
    end

    class << self
      def sdks
        @sdks ||= Dir["sdks/*"].map { |x| x.split("/").last }
      end

      def valid? params
        [
          sdks.include?(params["sdk"]),
          /\A[\w-]+\z/.match?(params["program_id"]),
          /\A.+\z/m.match?(params["source_code"]),
        ].all?
      end
    end
  end
end
