# A sample Gemfile
source "https://rubygems.org"

gem 'falkorlib' #, :path => '~/git/github.com/Falkor/falkorlib'

# Puppet stuff
puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 3.3']
gem "puppet", puppetversion
#gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint',            '>= 0.3.2'
gem 'puppet-syntax'
gem 'facter',                 '>= 1.7.0'
gem 'rspec-puppet'
