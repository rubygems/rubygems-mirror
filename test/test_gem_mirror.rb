require 'builder/xchar'

require "rubygems_plugin"
require "rubygems/mirror"
require "rubygems/mirror/test_setup"

require "minitest/autorun"

class TestGemMirror < Minitest::Test
  include Gem::Mirror::TestSetup

  # Used to make sure we don't raise on construction, works against defaults
  def opts
    ['http://localhost:8808/', mirror_path, 1]
  end

  def test_update_specs
    with_server do
      mirror = Gem::Mirror.new(*opts)
      mirror.update_specs
      Gem::Mirror::SPECS_FILES.each do |sf|
        assert File.exist?(mirror_path + "/#{sf}.gz")
      end
    end
  end

  def test_update_gems
    with_server do
      mirror = Gem::Mirror.new(*opts)

      updates = 0
      mirror.update_gems { updates += 1 }

      source_gems, mirror_gems = [source_path, mirror_path].map do |path|
        Dir[path + '/gems/*'].map { |f| File.basename(f) }
      end

      source_rz_specs, mirror_rz_specs = [source_path, mirror_path].map do |path|
        Dir[path + "/quick/Marshal.#{Gem.marshal_version}/*"].map { |f| File.basename(f) }
      end

      assert_equal source_gems, mirror_gems
      assert_equal source_rz_specs, mirror_rz_specs
      # XXX(raggi): need to figure out how to hide the system gems in 2.0
      assert 10 <= updates
    end
  end

  def test_delete_gems
    with_server do
      mirror = Gem::Mirror.new(*opts)
      FileUtils.mkdir_p mirror.to('gems')
      FileUtils.touch mirror.to('gems', 'd-1.0.gem')

      updates = 0
      mirror.delete_gems { updates += 1 }

      gems = Dir[mirror_path + '/gems/*.gem'].map { |f| File.basename f }
      assert_equal [], gems
      assert_equal 1, updates
    end
  end
end
