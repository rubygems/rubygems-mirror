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
end

Rake::TestTask.new

namespace :test do
  task :integration do
    sh Gem.ruby, '-Ilib', '-S', 'gem', 'mirror'
  end
end
