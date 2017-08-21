#!/usr/bin/env ruby
##########################################################################
# puppet_module_setup.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Mon 2017-08-21 13:01 svarrette>
#
# @description Prepare the Vagrant box to test this Puppet module
#
# Copyright (c) 2014-2017 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'json'
require 'yaml'
require 'falkorlib'

include FalkorLib::Common

# Load metadata
basedir   = File.directory?('/vagrant') ? '/vagrant' : Dir.pwd
jsonfile  = File.join( basedir, 'metadata.json')
puppetdir = '/etc/puppetlabs'

error "Unable to find the metadata.json" unless File.exists?(jsonfile)

metadata   = JSON.parse( IO.read( jsonfile ) )
name = metadata["name"].gsub(/^[^\/-]+[\/-]/,'')
modulepath=`puppet config print modulepath`.chomp
moduledir=modulepath.split(':').first


run %{ cd #{moduledir}/.. && librarian-puppet clean && rm Puppetfile* }
run %{ ln -s /vagrant/metadata.json #{moduledir}/../ }
run %{ cd #{moduledir}/.. && librarian-puppet install --verbose }


# metadata["dependencies"].each do |dep|
# 	lib = dep["name"]
#     shortname = lib.gsub(/^.*[\/-]/,'')
#     action = File.directory?("#{moduledir}/#{shortname}") ? 'upgrade --force' : 'install'
# 	run %{ puppet module #{action} #{lib} }
# end

puts "Module path: #{modulepath}"
puts "Moduledir:   #{moduledir}"

info "set symlink to the '#{basedir}' module for local developments"
run %{ ln -s #{basedir} #{moduledir}/#{name}  } unless File.exists?("#{moduledir}/#{name}")

# Use of 'hiera.yaml' version 3 is deprecated. It should be converted to version 5
hiera = '/etc/puppetlabs/puppet/hiera.yaml'




# Prepare hiera
# unless File.exists?('/etc/puppet/hiera.yaml')
#     run %{ ln -s /etc/hiera.yaml /etc/puppet/hiera.yaml } if File.exists?("/etc/hiera.yaml")
# end
# # # hieracfg = YAML::load_file('/etc/hiera.yaml')
# # # [ '/vagrant/tests/hiera' ].each do |d|
# # #     hieracfg[:datadir] = [] if hieracfg[:datadir].nil?
# # #     hieracfg[:datadir] << d #if File.directory?('#{d}')
# # # end
# # # hieracfg[:hierarchy] = [] if hieracfg[:hierarchy].nil?
# # # hieracfg[:hierarchy] << 'common' unless hieracfg[:hierarchy].include?('common')
# hieracfg = {
#     :backends  => [ 'yaml' ],
#     :hierarchy => [ 'defaults', 'common' ],
#     :yaml      => {
#         :datadir   => '/vagrant/tests/hiera',
#     }
# }
# FalkorLib::Common.store_config('/etc/hiera.yaml', hieracfg, {:no_interaction => true})
