# A sample Gemfile
source "https://rubygems.org"

gem 'falkorlib' #, :path => '~/git/github.com/Falkor/falkorlib'
# Puppet stuff
#gem 'puppetlabs_spec_helper', '>= 0.1.0'

#gem 'puppet-syntax'
#gem 'facter',                 '>= 1.7.0'

group :test do
  gem "rake"
  gem "puppet", ENV['PUPPET_GEM_VERSION'] || '~> 4.4.0'
  gem 'puppet-strings'
  gem "rspec", '< 3.2.0'
  gem "rspec-puppet"
  gem "puppetlabs_spec_helper"
  gem "metadata-json-lint"
  gem "rspec-puppet-facts"
  gem 'rubocop',   '~> 0.51'
  gem 'simplecov', '>= 0.11.0'
  gem 'simplecov-console'
  gem "yard", ">= 0.9.20"

  #gem 'puppet-lint',            '>= 0.3.2'
  gem "puppet-lint-absolute_classname-check"
  gem "puppet-lint-leading_zero-check"
  gem "puppet-lint-trailing_comma-check"
  gem "puppet-lint-version_comparison-check"
  gem "puppet-lint-classes_and_types_beginning_with_digits-check"
  gem "puppet-lint-unquoted_string-check"
  gem 'puppet-lint-resource_reference_syntax'
  gem 'semantic_puppet'

  gem 'json_pure', '<= 2.0.1' if RUBY_VERSION < '2.0.0'
end

group :development do
  gem "travis"              if RUBY_VERSION >= '2.1.0'
  gem "travis-lint"         if RUBY_VERSION >= '2.1.0'
 # gem "puppet-blacksmith"
 # gem "guard-rake"          if RUBY_VERSION >= '2.2.5' # per dependency https://rubygems.org/gems/ruby_dep
end

group :system_tests do
  gem "beaker"
  gem "beaker-rspec"
  gem "beaker-puppet_install_helper"
end
