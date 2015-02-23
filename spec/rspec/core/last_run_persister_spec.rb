module RSpec::Core
  RSpec.describe LastRunPersister do
    def persist_failures(dir, failures)
      LastRunPersister.new(dir).persist_failures(failures)
    end

    def persisted_from(dir)
      LastRunPersister.new(dir).failures_from_last_run
    end

    it 'persists the failures from the last run' do
      persist_failures("./tmp", %w[ failure1 failure17 ])
      expect(persisted_from("./tmp")).to eq(%w[ failure1 failure17 ])
    end

    it 'stomps the failures written the prior time' do
      persist_failures("./tmp", %w[ failure1 failure17 ])
      persist_failures("./tmp", %w[ failure2 failure18 ])

      expect(persisted_from("./tmp")).to eq(%w[ failure2 failure18 ])
    end

    it 'separates its storage based on the given directory name' do
      FileUtils.mkdir_p("./tmp/project1")
      FileUtils.mkdir_p("./tmp/project2")

      persist_failures("./tmp/project1", %w[ failure1 ])
      persist_failures("./tmp/project2", %w[ failure2 ])

      expect(persisted_from("./tmp/project1")).to eq(%w[ failure1 ])
      expect(persisted_from("./tmp/project2")).to eq(%w[ failure2 ])
    end

    it 'makes any intermediary directories that do not yet exist so that it can write there' do
      FileUtils.rm_rf("./tmp/start")
      persist_failures("./tmp/start/of/long/path", %w[ f1 ])
      expect(persisted_from("./tmp/start/of/long/path")).to eq(%w[ f1 ])
    end

    describe ".for_current_project.directory", :isolated_home do
      let(:dir_for_current_project) { LastRunPersister.for_current_project.directory }

      it 'starts with #{home}/.rspec_last_run so it is scoped to the user' do
        expect(dir_for_current_project).to start_with(File.join(Dir.home, ".rspec_last_run"))
      end

      it 'includes the current project path so that it is scoped to the project' do
        expect(dir_for_current_project).to end_with(RubyProject.root)
      end
    end
  end
end
