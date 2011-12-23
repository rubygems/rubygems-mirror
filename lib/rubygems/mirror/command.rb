require 'rubygems/mirror'
require 'rubygems/command'
require 'yaml'

class Gem::Commands::MirrorCommand < Gem::Command
  SUPPORTS_INFO_SIGNAL = Signal.list['INFO']

  def initialize
    super 'mirror', 'Mirror a gem repository'
  end

  def description # :nodoc:
    <<-EOF
The mirror command uses the ~/.gem/.mirrorrc config file to mirror
remote gem repositories to a local path. The config file is a YAML
document that looks like this:

  ---
  - from: http://gems.example.com # source repository URI
    to: /path/to/mirror           # destination directory
    parallelism: 10               # use 10 threads for downloads

Multiple sources and destinations may be specified.
    EOF
  end

  def execute
    config_file = File.join Gem.user_home, '.gem', '.mirrorrc'

    raise "Config file #{config_file} not found" unless File.exist? config_file

    mirrors = YAML.load_file config_file

    raise "Invalid config file #{config_file}" unless mirrors.respond_to? :each

    mirrors.each do |mir|
      raise "mirror missing 'from' field" unless mir.has_key? 'from'
      raise "mirror missing 'to' field" unless mir.has_key? 'to'

      get_from = mir['from']
      save_to = File.expand_path mir['to']
      parallelism = mir['parallelism']

      raise "Directory not found: #{save_to}" unless File.exist? save_to
      raise "Not a directory: #{save_to}" unless File.directory? save_to

      mirror = Gem::Mirror.new(get_from, save_to, parallelism)
      
      say "Fetching: #{mirror.from(Gem::Mirror::SPECS_FILE_Z)} with #{parallelism} threads"
      mirror.update_specs

      say "Total gems: #{mirror.gems.size}"

      num_to_fetch = mirror.gems_to_fetch.size

      progress = ui.progress_reporter num_to_fetch,
                                  "Fetching #{num_to_fetch} gems"

      trap(:INFO) { puts "Fetched: #{progress.count}/#{num_to_fetch}" } if SUPPORTS_INFO_SIGNAL

      mirror.update_gems { progress.updated true }

      num_to_delete = mirror.gems_to_delete.size

      progress = ui.progress_reporter num_to_delete,
                                 "Deleting #{num_to_delete} gems"

      trap(:INFO) { puts "Fetched: #{progress.count}/#{num_to_delete}" } if SUPPORTS_INFO_SIGNAL

      mirror.delete_gems { progress.updated true }
    end
  end
end
