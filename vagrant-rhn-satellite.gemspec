# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-rhn-satellite/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-rhn-satellite"
  spec.version       = VagrantPlugins::RhnSatellite::VERSION
  spec.authors       = ["Brandon Raabe"]
  spec.email         = ["brandocorp@gmail.com"]
  spec.summary       = %q{Register vagrant nodes with a Red Hat Network Satellite server}
  spec.description   = %q{A vagrant plugin that allows registration with a Red Hat Network Satellite server as part of the provisioning process.}
  spec.homepage      = "https://github.com/brandocorp/vagrant-rhn-satellite"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
