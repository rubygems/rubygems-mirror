require 'rubygems'
require 'fileutils'

class Gem::Mirror
  autoload :Fetcher, 'rubygems/mirror/fetcher'
  autoload :Pool, 'rubygems/mirror/pool'

  VERSION = '1.0.1'
  
  SPECS_FILE = "specs.#{Gem.marshal_version}"
  SPECS_FILE_Z = "specs.#{Gem.marshal_version}.gz"
  SPECS_FILES = ["yaml","yaml.Z","latest_specs.#{Gem.marshal_version}","latest_specs.#{Gem.marshal_version}.gz",
                "Marshal.#{Gem.marshal_version}", "Marshal.#{Gem.marshal_version}.Z",
                "prerelease_specs.#{Gem.marshal_version}","prerelease_specs.#{Gem.marshal_version}.gz",
                "specs.#{Gem.marshal_version}","specs.#{Gem.marshal_version}.gz"]

  DEFAULT_URI = 'http://production.cf.rubygems.org/'
  DEFAULT_TO = File.join(Gem.user_home, '.gem', 'mirror')

  RUBY = 'ruby'

  def initialize(from = DEFAULT_URI, to = DEFAULT_TO, parallelism = nil)
    @from, @to = from, to
    @fetcher = Fetcher.new
    @pool = Pool.new(parallelism || 10)
  end

  def from(*args)
    File.join(@from, *args)
  end

  def to(*args)
    File.join(@to, *args)
  end

  def update_specs
    specz = to(SPECS_FILE_Z)
    @fetcher.fetch(from(SPECS_FILE_Z), specz)
    open(to(SPECS_FILE), 'wb') { |f| f << Gem.gunzip(File.read(specz)) }
  end
  
  def fetch_all_specs
    SPECS_FILES.each do |spec_file|
      print "Fetching #{spec_file}..."
      @fetcher.fetch(from(spec_file), to(spec_file))
      puts "[Done]"
    end
  end

  def gems
    update_specs unless File.exists?(to(SPECS_FILE))

    gems = Marshal.load(File.read(to(SPECS_FILE)))
    gems.map! do |name, ver, plat|
      # If the platform is ruby, it is not in the gem name
      "#{name}-#{ver}#{"-#{plat}" unless plat == RUBY}.gem"
    end
    gems
  end

  def existing_gems
    Dir[to('gems', '*.gem')].entries.map { |f| File.basename(f) }
  end

  def gems_to_fetch
    gems - existing_gems
  end

  def gems_to_delete
    existing_gems - gems
  end

  def update_gems
    fetch_all_specs
    puts ""
    puts "-"*100
    print "#{gems_to_fetch.count} Gems need to update"
    gems_to_fetch.each do |g|
      @pool.job do
        @fetcher.fetch(from('gems', g), to('gems', g))
        # download gemspec.rz
        g_spec = "#{g}spec.rz"
        @fetcher.fetch(from("quick/Marshal.#{Gem.marshal_version}", g_spec), to("quick/Marshal.#{Gem.marshal_version}", g_spec))
        print "."
        yield if block_given?
      end
    end

    @pool.run_til_done
  end

  def delete_gems
    # gems_to_delete.each do |g|
    #   @pool.job do
    #     File.delete(to('gems', g))
    #     yield if block_given?
    #   end
    # end
    # 
    # @pool.run_til_done
  end

  def update
    update_specs
    update_gems
    cleanup_gems
  end
end
