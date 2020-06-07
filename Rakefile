require "bundler"
Bundler::GemHelper.install_tasks

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
    sh Gem.ruby, '-Ilib', '-S', 'gem', 'mirror'
  end
end
