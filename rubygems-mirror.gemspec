# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubygems-mirror".freeze
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["James Tucker".freeze]
  s.description = "This is an update to the old `gem mirror` command. It uses net/http/persistent\nand threads to grab the mirror set a little faster than the original.\nEventually it will replace `gem mirror` completely. Right now the API is not\ncompletely stable (it will change several times before release), however, I\nwill maintain stability in master.".freeze
  s.email = ["jftucker@gmail.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "CHANGELOG.rdoc".freeze, "README.rdoc".freeze, "pkg/rubygems-mirror-1.2.0/CHANGELOG.rdoc".freeze, "pkg/rubygems-mirror-1.2.0/README.rdoc".freeze]
  s.files = File.read('Manifest.txt').split
  s.homepage = "https://github.com/rubygems/rubygems-mirror".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "2.7.6".freeze
  s.summary = "This is an update to the old `gem mirror` command".freeze
  s.specification_version = 4

  s.add_runtime_dependency(%q<net-http-persistent>.freeze, ["~> 2.9"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.7"])
  s.add_development_dependency(%q<rdoc>.freeze, ["< 7", ">= 4.0"])
  s.add_development_dependency(%q<hoe>.freeze, ["~> 3.17"])
end
