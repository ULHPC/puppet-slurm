#!/usr/bin/env ruby 
##########################################################################
# vagrant_init.rb
# @author Sebastien Varrette <Sebastien.Varrette@uni.lu>
# Time-stamp: <Tue 2015-06-02 22:43 svarrette>
#
# @description 
#
# Copyright (c) 2014 Sebastien Varrette <Sebastien.Varrette@uni.lu>
# .             http://varrette.gforge.uni.lu
##############################################################################

require 'json'
require 'yaml'
require 'falkorlib'

include FalkorLib::Common

# Load metadata
basedir   = File.directory?('/vagrant') ? '/vagrant' : Dir.pwd
jsonfile  = File.join( basedir, 'metadata.json')

error "Unable to find the metadata.json" unless File.exists?(jsonfile)

metadata   = JSON.parse( IO.read( jsonfile ) )
name = metadata["name"].gsub(/^[^\/-]+[\/-]/,'') 
modulepath=`puppet config print modulepath`.chomp
moduledir=modulepath.split(':').first


run %{ cd /etc/puppet && librarian-puppet clean && rm Puppetfile* }
run %{ ln -s /vagrant/metadata.json /etc/puppet/ }
run %{ cd /etc/puppet && librarian-puppet install --verbose }


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

# Prepare hiera
unless File.exists?('/etc/puppet/hiera.yaml')
    run %{ ln -s /etc/hiera.yaml /etc/puppet/hiera.yaml } if File.exists?("/etc/hiera.yaml")
end
# # hieracfg = YAML::load_file('/etc/hiera.yaml')
# # [ '/vagrant/tests/hiera' ].each do |d|
# #     hieracfg[:datadir] = [] if hieracfg[:datadir].nil?
# #     hieracfg[:datadir] << d #if File.directory?('#{d}')
# # end
# # hieracfg[:hierarchy] = [] if hieracfg[:hierarchy].nil?
# # hieracfg[:hierarchy] << 'common' unless hieracfg[:hierarchy].include?('common')
hieracfg = {
    :backends  => [ 'yaml' ],
    :hierarchy => [ 'defaults', 'common' ],
    :yaml      => {
        :datadir   => '/vagrant/tests/hiera',
    }
}
FalkorLib::Common.store_config('/etc/hiera.yaml', hieracfg, {:no_interaction => true})
