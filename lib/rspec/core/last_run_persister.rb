module RSpec
  module Core
    # Persists data about the last run of your spec suite so that it
    # can be re-used on the next run. For now, it only stores a list
    # of what failed in order to support the `--rerun-faliures` flag.
    # @private
    class LastRunPersister
      def self.for_current_project
        new(File.join(Dir.home, ".rspec_last_run", RubyProject.root))
      end

      attr_reader :directory

      def initialize(directory)
        @directory = directory
      end

      def persist_failures(failure_ids)
        File.open(failures_file_name, "w") do |f|
          f.write(failure_ids.join("\n"))
        end
      end

      def failures_from_last_run
        File.read(failures_file_name).split("\n")
      end

    private

      def failures_file_name
        @failures_file_name ||= File.join(directory, "failures.txt").tap do |f|
          RSpec::Support::DirectoryMaker.mkdir_p(File.dirname(f))
        end
      end
    end
  end
end
