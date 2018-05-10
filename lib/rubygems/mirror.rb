require 'rubygems'
require 'fileutils'

class Gem::Mirror
  autoload :Fetcher, 'rubygems/mirror/fetcher'
  autoload :Pool, 'rubygems/mirror/pool'

  VERSION = '1.1.0'

  SPECS_FILES = [ "specs.#{Gem.marshal_version}", "prerelease_specs.#{Gem.marshal_version}", "latest_specs.#{Gem.marshal_version}" ]

  DEFAULT_URI = 'http://production.cf.rubygems.org/'
  DEFAULT_TO = File.join(Gem.user_home, '.gem', 'mirror')

  RUBY = 'ruby'

  def initialize(from = DEFAULT_URI, to = DEFAULT_TO, parallelism = nil, retries = nil, skiperror = nil)
    @from, @to = from, to
    @fetcher = Fetcher.new :retries => retries, :skiperror => skiperror
    @pool = Pool.new(parallelism || 10)
  end

  def from(*args)
    File.join(@from, *args)
  end

  def to(*args)
    File.join(@to, *args)
  end

  def update_specs
    SPECS_FILES.each do |sf|
      sfz = "#{sf}.gz"

      specz = to(sfz)
      @fetcher.fetch(from(sfz), specz)
      open(to(sf), 'wb') { |f| f << Gem.gunzip(File.read(specz)) }
    end
  end

  def gems
    gems = []

    SPECS_FILES.each do |sf|
      update_specs unless File.exist?(to(sf))

      gems += Marshal.load(File.read(to(sf)))
    end

    gems.map! do |name, ver, plat|
      # If the platform is ruby, it is not in the gem name
      "#{name}-#{ver}#{"-#{plat}" unless plat == RUBY}.gem"
    end
    gems
  end

  def existing_gems
    Dir.glob(to('gems', '*.gem'), File::FNM_DOTMATCH).entries.map { |f| File.basename(f) }
  end

  def existing_gemspecs
    Dir[to("quick/Marshal.#{Gem.marshal_version}", '*.rz')].entries.map { |f| File.basename(f) }
  end

  def gems_to_fetch
    gems - existing_gems
  end

  def gemspecs_to_fetch
    gems.map { |g| "#{g}spec.rz" } - existing_gemspecs
  end

  def gems_to_delete
    existing_gems - gems
  end

  def update_gems
    gems_to_fetch.each do |g|
      @pool.job do
        @fetcher.fetch(from('gems', g), to('gems', g))
        yield if block_given?
      end
    end

    gemspecs_to_fetch.each do |g_spec|
      @pool.job do
        @fetcher.fetch(from("quick/Marshal.#{Gem.marshal_version}", g_spec), to("quick/Marshal.#{Gem.marshal_version}", g_spec))
        yield if block_given?
      end
    end

    @pool.run_til_done
  end

  def delete_gems
    gems_to_delete.each do |g|
      @pool.job do
        File.delete(to('gems', g))
        yield if block_given?
      end
    end

    @pool.run_til_done
  end

  def update
    update_specs
    update_gems
    cleanup_gems
  end
end
