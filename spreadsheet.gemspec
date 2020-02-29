# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spreadsheet/version'

Gem::Specification.new do |spec|
  spec.name          = "spreadsheet"
  spec.version       = Spreadsheet::VERSION
  spec.authors       = ["Franklin Chen"]
  spec.email         = ["franklinchen@franklinchen.com"]

  spec.summary       = %q{Monadic spreadsheet}
  spec.description   = %q{Monadic spreadsheet}
  spec.homepage      = "https://github.com/FranklinChen/spreadsheet-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
end
