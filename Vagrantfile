# -*- mode: ruby -*-
# vi: set ft=ruby :
# Time-stamp: <Tue 2017-08-22 23:58 svarrette>
###########################################################################################
#              __     __                          _    __ _ _
#              \ \   / /_ _  __ _ _ __ __ _ _ __ | |_ / _(_) | ___
#               \ \ / / _` |/ _` | '__/ _` | '_ \| __| |_| | |/ _ \
#                \ V / (_| | (_| | | | (_| | | | | |_|  _| | |  __/
#                 \_/ \__,_|\__, |_|  \__,_|_| |_|\__|_| |_|_|\___|
#                           |___/
###########################################################################################
require 'yaml'
require 'ipaddr'
require 'deep_merge'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
TOP_SRCDIR = File.expand_path File.dirname(__FILE__)
TOP_VAGRANT_TESTDIR  = File.join(TOP_SRCDIR, 'tests', 'vagrant')
config_file   = File.join(TOP_VAGRANT_TESTDIR, 'config.yaml')

###### Expected Vagrant plugins detection ######
# For more information on the below plugins:
# - https://github.com/oscar-stack/vagrant-hosts
# - https://github.com/dotless-de/vagrant-vbguest
# - https://github.com/emyl/vagrant-triggers
# - https://github.com/fgrehm/vagrant-cachier
# Terminal-table is a nice ruby gem for automatically print tables with nice layout
###
[ 'vagrant-hosts', 'vagrant-vbguest', 'vagrant-triggers', 'vagrant-cachier', 'terminal-table' ].each do |plugin|
    abort "Install the  '#{plugin}' plugin with 'vagrant plugin install #{plugin}'" unless Vagrant.has_plugin?("#{plugin}")
end
require 'terminal-table'

### Default settings ###
DEFAULT_SETTINGS = {
    :defaults => {
        :os     => :centos7,
        :ram    => 512,
        :vcpus  => 4,
        :vbguest_auto_update => true,
    },
    # Default domain settings
    :network => {
        :domain => 'vagrant.dev',
        :range  => '10.10.1.0/24',
        :ip_offset => 10,
    },
    # Default Boxes
    :boxes => {
        :centos7  => 'centos/7',
        :debian8  => 'debian/contrib-jessie64',
        :ubuntu14 => 'ubuntu/trusty64'
    },
    :vms => {
        'default' => { }
    },
}

# List of default provisioning scripts
DEFAULT_PROVISIONING_SCRIPTS = [
    "tests/vagrant/bootstrap.sh",
    "tests/vagrant/puppet_modules_setup.rb"
]

# Load the settings (eventually overwritten using values from the yaml file 'config.yaml')
settings = DEFAULT_SETTINGS.clone
if File.exist?(config_file)
    config = YAML::load_file config_file
    settings.deep_merge!( config ) if config
end
abort "Undefined settings" if settings.nil?


############################################################
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    defaults = settings[:defaults]
    network  = settings[:network]

    ### Common configs shared by all VMs ###
    # Cache plugin -- Supports local cache, so you don't wast bandwitdh
    # vagrant plugin install vagrant-cachier   # see https://github.com/fgrehm/vagrant-cachier
    config.cache.auto_detect = true if Vagrant.has_plugin?("vagrant-cachier")

    # check if VirtualBox Guest Additions are up to date
    if Vagrant.has_plugin?("vagrant-vbguest")
        # set auto_update to false, if you do NOT want to check the correct
        # additions version when booting these boxes
        config.vbguest.auto_update = defaults[:vbguest_auto_update]
    end

    # Shell provisioner, to setup minimal conditions for Puppet provisioning
    DEFAULT_PROVISIONING_SCRIPTS.each do |script|
        config.vm.provision "shell", path: "#{script}", keep_color: true
    end
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

    # network settings
    ipaddr   = IPAddr.new network[:range]
    ip_range = ipaddr.to_range.to_a

    # cosmetics for the post-up message
    __table = {
        :title    => "Puppet Testing infrastructure deployed on Vagrant",
        :headings => [ 'Name', 'Hostname', 'OS', 'vCPU/RAM', 'Description', 'IP' ],
        :rows => [],
    }
    #__________________________________
    settings[:vms].each do |name, node|
        boxname  =  defaults[:os].to_s.downcase.gsub(/([^\d]+)(\d+)/, '\\1-\\2')
        name     = boxname if name == 'default'
        hostname = node[:hostname] ? node[:hostname] : name
        domain   = network[:domain]
        fqdn     =    "#{hostname}.#{domain}"
        os       =    node[:os]       ? node[:os].to_sym : defaults[:os].to_sym
        ram      =    node[:ram]      ? node[:ram]       : defaults[:ram]
        vcpus    =    node[:vcpus]    ? node[:vcpus]     : defaults[:vcpus]
        desc     =    node[:desc]     ? node[:desc]      : 'n/a'

        abort "Non-existing box OS '#{os}' for the VM '#{name}'" if  settings[:boxes][os.to_sym].nil?
        abort "Empty IP address range" if ip_range.empty?
        ip = ip_range[ network[:ip_offset].to_i ].to_s

        config.vm.define "#{name}" do |c|
            c.vm.box      = settings[:boxes][os.to_sym]
            c.vm.hostname = "#{fqdn}"
            c.vm.network :private_network, :ip => ip
            c.vm.provision :hosts, :sync_hosts => true
            c.vm.provider "virtualbox" do |v|
                v.customize [ 'modifyvm', :id, '--name', hostname, '--memory', ram.to_s ]
                v.customize [ 'modifyvm', :id, '--cpus', vcpus.to_s ] if vcpus.to_i > 1
            end
            __table[:rows] << [ name, fqdn, os.to_sym, "#{vcpus}/#{ram}", desc, ip]
        end
    end

    config.trigger.after :up do
        puts Terminal::Table.new __table
    end
end
