##############################################################################
# Rakefile - Configuration file for rake (http://rake.rubyforge.org/)
# Time-stamp: <Mon 2017-08-21 22:42 svarrette>
#
# Copyright (c) 2017  UL HPC Team <hpc-sysadmins@uni.lu>
#                       ____       _         __ _ _
#                      |  _ \ __ _| | _____ / _(_) | ___
#                      | |_) / _` | |/ / _ \ |_| | |/ _ \
#                      |  _ < (_| |   <  __/  _| | |  __/
#                      |_| \_\__,_|_|\_\___|_| |_|_|\___|
#
# Use 'rake -T' to list the available actions
#
# Resources:
# * http://www.stuartellis.eu/articles/rake/
#
# See also https://github.com/garethr/puppet-module-skeleton
##############################################################################
require 'falkorlib'
require 'puppetlabs_spec_helper/rake_tasks'


## placeholder for custom configuration of FalkorLib.config.*
## See https://github.com/Falkor/falkorlib

# Adapt the versioning aspects
FalkorLib.config.versioning do |c|
	c[:type] = 'puppet_module'
end

# Adapt the Git flow aspects
FalkorLib.config.gitflow do |c|
	c[:branches] = {
		:master  => 'production',
		:develop => 'devel'
	}
end

###########   up   ###########
desc "Update your local branches"
task :up do |t|
    info "#{t.comment}"
    FalkorLib::Git.fetch
    branches = FalkorLib::Git.list_branch
    #puts branches.to_yaml
    unless FalkorLib::Git.dirty?
        FalkorLib.config.gitflow[:branches].each do |t, br|
            info "updating Git Flow #{t} branch '#{br}' with the 'origin' remote"
            run %{ git checkout #{br} && git merge origin/#{br} }
        end
        run %{ git checkout #{branches[0]} }  # Go back to the initial branch
    else
        warning "Unable to update -- your local repository copy is dirty"
    end

end # task up

require 'falkorlib/tasks/git'
require 'falkorlib/tasks/puppet'

##############################################################################
#TOP_SRCDIR = File.expand_path(File.join(File.dirname(__FILE__), "."))
