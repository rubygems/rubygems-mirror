# -*- encoding: utf-8 -*-
require_relative "lib/rubygems/mirror/version"

Gem::Specification.new do |s|
  s.name = "rubygems-mirror".freeze
  s.version = Gem::Mirror::VERSION

  s.summary = "This is an update to the old `gem mirror` command".freeze
  s.description = "This is an update to the old `gem mirror` command. It uses net/http/persistent\nand threads to grab the mirror set a little faster than the original.\nEventually it will replace `gem mirror` completely. Right now the API is not\ncompletely stable (it will change several times before release), however, I\nwill maintain stability in master.".freeze

  s.authors = ["James Tucker".freeze, "Hiroshi SHIBATA".freeze]
  s.email = ["jftucker@gmail.com".freeze, "hsbt@ruby-lang.org".freeze]
  s.files = File.read('Manifest.txt').split
  s.homepage = "https://github.com/rubygems/rubygems-mirror".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.extra_rdoc_files = ["CHANGELOG.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "CHANGELOG.rdoc".freeze, "README.rdoc".freeze]
  s.require_paths = ["lib".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.specification_version = 4

  s.add_runtime_dependency(%q<net-http-persistent>.freeze, ["~> 2.9"])
end
