require 'rubygems/command_manager'
require 'rubygems/mirror/command'

module Gem #:nodoc:
end

class Gem::Mirror
  #          1.0.0
  VERSION = '1.0.0'
end

Gem::CommandManager.instance.register_command :mirror
