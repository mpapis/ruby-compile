=begin
Copyright 2014 Michal Papis <mpapis@gmail.com>

See the file LICENSE for copying permission.
=end

lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "compile/version"

Gem::Specification.new do |spec|
  spec.name        = "compile"
  spec.version     = ::Compile::VERSION
  spec.licenses    = ["MIT"]

  spec.authors     = ["Michal Papis"]
  spec.email       = ["mpapis@gmail.com"]

  spec.homepage    = "https://github.com/mpapis/ruby-compile"
  spec.summary     = "Compile ruby from source locally and remotely"

  spec.add_dependency("command-designer")
  spec.add_dependency("remote-exec")

  spec.files        = Dir.glob("lib/**/*.rb")
  spec.test_files   = Dir.glob("test/**/*.rb")
end
