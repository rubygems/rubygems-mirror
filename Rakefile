require "bundler"
Bundler::GemHelper.install_tasks
require "rake/testtask"

task :default => :test

namespace :mirror do
  desc "Run the Gem::Mirror::Command"
  task :update do
    $:.unshift 'lib'
    require 'rubygems/mirror/command'

    mirror = Gem::Commands::MirrorCommand.new
    mirror.execute
  end

  task :latest do
    ENV["RUBYGEMS_MIRROR_ONLY_LATEST"] = "TRUE"
    Rake::Task["mirror:update"].invoke
  end
end

Rake::TestTask.new

namespace :test do
  task :integration do
    sh Gem.ruby, '-Ilib', '-S', 'gem', 'mirror'
  end
end
