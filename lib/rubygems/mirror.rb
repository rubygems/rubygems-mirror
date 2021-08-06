require 'rubygems'
require 'fileutils'
require 'rubygems/mirror/version'
require 'rubygems/util'

class Gem::Mirror
  autoload :Fetcher, 'rubygems/mirror/fetcher'
  autoload :Pool, 'rubygems/mirror/pool'

  SPECS_FILES = [ "specs.#{Gem.marshal_version}", "prerelease_specs.#{Gem.marshal_version}", "latest_specs.#{Gem.marshal_version}" ]

  DEFAULT_URI = 'http://production.cf.rubygems.org/'
  DEFAULT_TO = File.join(Gem.user_home, '.gem', 'mirror')

  RUBY = 'ruby'

  def initialize(from = DEFAULT_URI, to = DEFAULT_TO, parallelism = nil, retries = nil, skiperror = nil, hashdir = false)
    @from, @to, @hashdir = from, to, hashdir
    @fetcher = Fetcher.new :retries => retries, :skiperror => skiperror
    @pool = Pool.new(parallelism || 10)
  end

  def from(*args)
    File.join(@from, *args)
  end

  def hash(path)
    return path unless @hashdir
    File.join(path[0], path[0,2], path)
  end

  def hash_glob(*args)
    args.insert(-2, "**") if @hashdir
    args
  end

  def to(*args)
    File.join(@to, *args)
  end

  def update_specs
    SPECS_FILES.each do |sf|
      sfz = "#{sf}.gz"
      specz = to(sfz)
      path = to(sf)

      @fetcher.fetch(from(sfz), specz)
      open(path, 'wb') { |f| f << Gem::Util.gunzip(File.binread(specz)) }
    end
  end

  def all_gems?
    ENV["RUBYGEMS_MIRROR_ONLY_LATEST"].to_s.upcase != "TRUE"
  end

  def gems
    gems = []

    SPECS_FILES.each do |sf|
      path = to(sf)
      update_specs unless File.exist?(path)

      gems += Marshal.load(File.binread(path))
    end

    if all_gems?
      gems.map! do |name, ver, plat|
        # If the platform is ruby, it is not in the gem name
        "#{name}-#{ver}#{"-#{plat}" unless plat == RUBY}.gem"
      end
    else
      latest_gems = {}

      gems.each do |name, ver, plat|
        next if ver.prerelease?
        next unless plat == RUBY
        latest_gems[name] = ver
      end

      gems = latest_gems.map do |name, ver|
        "#{name}-#{ver}.gem"
      end
    end

    gems
  end

  def existing_gems
    path = to(*hash_glob('gems', '*.gem'))

    Dir.glob(path, File::FNM_DOTMATCH).entries.map { |f| File.basename(f) }
  end

  def existing_gemspecs
    path = to(*hash_glob("quick/Marshal.#{Gem.marshal_version}", '*.rz'))

    Dir[path].entries.map { |f| File.basename(f) }
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
        path = to('gems', hash(g))

        @fetcher.fetch(from('gems', g), path)
        yield if block_given?
      end
    end

    if all_gems?
      gemspecs_to_fetch.each do |g_spec|
        @pool.job do
          path = to("quick/Marshal.#{Gem.marshal_version}", hash(g_spec))

          @fetcher.fetch(from("quick/Marshal.#{Gem.marshal_version}", g_spec), path)
          yield if block_given?
        end
      end
    end

    @pool.run_til_done
  end

  def delete_gems
    gems_to_delete.each do |g|
      @pool.job do
        File.delete(to('gems', hash(g)))
        yield if block_given?
      end
    end

    @pool.run_til_done
  end

  def update
    update_specs
    update_gems
    delete_gems
  end
end
