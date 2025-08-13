# frozen_string_literal: true

require_relative 'lib/nested_hash_builder/version'

Gem::Specification.new do |spec|
  spec.name = 'nested_hash_builder'
  spec.version = NestedHashBuilder::VERSION
  spec.authors = ['Mateusz Drewniak']
  spec.email = ['m.drewniak@espago.com']

  spec.summary = 'A Ruby library for building nested Hashes'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/Verseth/ruby-nested_hash_builder'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://raw.githubusercontent.com/Verseth/ruby-nested_hash_builder/refs/heads/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ sorbet/ Gemfile .gitignore test/ .gitlab-ci.yml .rubocop.yml])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'sorbet-runtime', '>= 0.5'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
