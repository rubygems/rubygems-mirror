require 'tempfile'
require 'fileutils'
require 'stringio'
require 'webrick'

require "rubygems/user_interaction"
require "rubygems/indexer"

# All files must be proactively loaded, otherwhise when the Gem index is
# replaced, requires will fail!
require "rubygems/mirror"
require "rubygems/mirror/fetcher"
require "rubygems/mirror/pool"

class Gem::Mirror

  # Provide assistance for authors of code that utilises Gem::Mirror. The
  # module defines several setup and teardown methods that can be used to
  # provide a new gem source on disk.
  module TestSetup
    # An instance of TestSetup::UI, a mock UI for RubyGems.
    attr_reader :ui

    # The path in which setup_gem_source will place a RubyGems source index
    attr_reader :source_path

    # A list of gem names in the source_path
    attr_reader :source_gems

    # A temporary directory where mirrors might put their data
    attr_reader :mirror_path

    # An rcfile pointing at the source and mirror paths
    attr_reader :mirrorrc

    # Path to the mock, temporary mirrorrc
    attr_reader :mirrorrc_path

    class UI < Gem::StreamUI

      # All input and output from the Gem UI when using TestSetup will pass
      # through StringIO objects placed here. For more information, see the
      # arguments to Gem::StreamUI.
      attr_reader :ui_ios

      def initialize
        super(*(@ui_ios = Array.new(3) { StringIO.new }))
      end
    end

    # Setup a new mock UI using TestSetup::UI
    def setup_ui
      @old_ui = Gem::DefaultUserInteraction.ui
      @ui = Gem::DefaultUserInteraction.ui = UI.new
    end

    # Restore RubyGems default UI
    def teardown_ui
      Gem::DefaultUserInteraction.ui = @old_ui if @old_ui
    end

    # Setup a new gem source directory containing a few gems suitable for
    # testing mirrors, and place the path to that in source_path.
    def setup_gem_source
      @source_path = Dir.mktmpdir("test_gem_source_path_#{$$}")

      Dir.mkdir gemdir = File.join(@source_path, 'gems')

      @source_working = working = Dir.mktmpdir("test_gem_source_#{$$}")

      Dir.mkdir File.join(working, 'lib')

      gemspecs = %w[a b c].map do |name|
        FileUtils.touch File.join(working, 'lib', "#{name}.rb")
        Gem::Specification.new do |s|
          s.platform = Gem::Platform::RUBY
          s.name = name
          s.version = 1.0
          s.author = 'rubygems'
          s.email = 'example@example.com'
          s.homepage = 'http://example.com'
          s.has_rdoc = false
          s.description = 'desc'
          s.summary = "summ"
          s.require_paths = %w[lib]
          s.files = %W[lib/#{name}.rb]
          s.rubyforge_project = 'rubygems'
        end
      end

      gemspecs.each do |spec|
        path = File.join(working, "#{spec.name}.gemspec")
        open(path, 'w') do |io|
          io.write(spec.to_ruby)
        end
        Dir.chdir(working) do
          gem_file = Gem::Builder.new(spec).build
          FileUtils.mv(gem_file, File.join(@source_path, 'gems', gem_file))
        end
      end

      @source_gems = Dir[File.join(gemdir, '*.gem')].map {|p|File.basename(p)}

      Gem::Indexer.new(@source_path).generate_index
    end

    # Cleanup temporary directories that are created by setup_gem_source.
    def teardown_gem_source
      [@source_path, @source_working].each do |path|
        FileUtils.rm_rf path
      end
    end

    # Setup a new mirrorrc for Gem::Mirror based on a setup from
    # setup_gem_source.
    def setup_mirrorrc
      @mirror_path = Dir.mktmpdir("test_gem_mirror_path_#{$$}")
      @mirrorrc = Tempfile.new('testgemmirrorrc')
      opts = {
        'mirrors' => {
          'from' => "http://127.0.0.1:8808/", 'to' => @mirror_path
        }
      }
      @mirrorrc.write YAML.dump(opts)
      @mirrorrc_path = @mirrorrc.path
    end

    # Cleanup tempfiles created by setup_mirrorrc.
    def teardown_mirrorrc
      FileUtils.rm_rf @mirrorrc_path if @mirrorrc_path
      FileUtils.rm_rf @mirror_path if @mirror_path
    end

    # Starts a server using Rack that will host the gem source
    def setup_server
      opts = { :Port => 8808, :DocumentRoot => @source_path }
      unless $DEBUG
        require 'logger'
        opts[:Logger] = Logger.new('/dev/null')
        opts[:AccessLog] = Logger.new('/dev/null')
      end
      @server = WEBrick::HTTPServer.new opts
      @server_thread = Thread.new { @server.start }
      @server_thread.join(0.1) # pickup early errors and give it time to start
    end

    # Shutdown the local server hosting the source_path
    def teardown_server
      @server && @server.shutdown
      @server_thread && @server_thread.join
    end
    
    def with_server
      setup_ui
      setup_gem_source
      setup_mirrorrc
      setup_server
      yield
    ensure
      teardown_gem_source
      teardown_server
      teardown_mirrorrc
      teardown_ui
    end
  end
end
