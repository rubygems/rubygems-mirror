require 'rubygems/mirror'
require 'rubygems/command'
require 'yaml'

class Gem::Mirror::Command < Gem::Command
  SUPPORTS_INFO_SIGNAL = Signal.list['INFO']

  def initialize
    super 'mirror', 'Mirror a gem repository'
  end

  def description # :nodoc:
    <<-EOF
The mirror command uses the ~/.gemmirrorrc config file to mirror remote gem
repositories to a local path. The config file is a YAML document that looks
like this:

  ---
  - from: http://gems.example.com # source repository URI
    to: /path/to/mirror           # destination directory

Multiple sources and destinations may be specified.
    EOF
  end

  def execute
    config_file = File.join Gem.user_home, '.gemmirrorrc'

    raise "Config file #{config_file} not found" unless File.exist? config_file

    mirrors = YAML.load_file config_file

    raise "Invalid config file #{config_file}" unless mirrors.respond_to? :each

    mirrors.each do |mir|
      raise "mirror missing 'from' field" unless mir.has_key? 'from'
      raise "mirror missing 'to' field" unless mir.has_key? 'to'

      get_from = mir['from']
      save_to = File.expand_path mir['to']

      raise "Directory not found: #{save_to}" unless File.exist? save_to
      raise "Not a directory: #{save_to}" unless File.directory? save_to

      mirror = Gem::Mirror.new(get_from, save_to)
      
      say "Fetching: #{mirror.from(Gem::Mirror::SPECS_FILE_Z)}"
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
