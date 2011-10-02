#!/usr/bin/env rake

require 'hoe'
Hoe.plugin :doofus, :git, :gemcutter

Hoe.spec 'rubygems-mirror' do
  developer('James Tucker', 'raggi@rubyforge.org')

  extra_dev_deps << %w[hoe-doofus >=1.0.0]
  extra_dev_deps << %w[hoe-git >=1.3.0]
  extra_dev_deps << %w[hoe-gemcutter >=1.0.0]
  extra_dev_deps << %w[builder >=2.1.2]
  extra_deps     << %w[net-http-persistent >=2.1]

  self.extra_rdoc_files = FileList["**/*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"
  self.rubyforge_name   = 'rubygems'
  self.testlib          = :minitest
end

namespace :mirror do
  desc "Run the Gem::Mirror::Command"
  task :update do
    $:.unshift 'lib'
    require 'rubygems/mirror/command'

    mirror = Gem::Commands::MirrorCommand.new
    mirror.execute
  end
end

namespace :test do
  task :integration do
    sh Gem.ruby, '-Ilib', '-rubygems', '-S', 'gem', 'mirror'
  end
end
