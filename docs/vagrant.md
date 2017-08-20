-*- mode: markdown; mode: visual-line; -*-

# Slurm Puppet Module Tests with Vagrant

The best way to test this module in a non-intrusive way is to rely on [Vagrant](http://www.vagrantup.com/).
[Vagrant](http://vagrantup.com/) uses [Oracle's VirtualBox](http://www.virtualbox.org/)
to build configurable, lightweight, and portable virtual machines dynamically.

* [Reference installation notes](http://docs.vagrantup.com/v2/installation/) -- assuming you have installed [Oracle's VirtualBox](http://www.virtualbox.org/)
* [installation notes on Mac OS](http://sourabhbajaj.com/mac-setup/Vagrant/README.html) using [Homebrew](http://brew.sh/) and [Cask](http://sourabhbajaj.com/mac-setup/Homebrew/Cask.html)

The `Vagrantfile` at the root of the repository pilot the provisioning of many vagrant boxes generated through the [vagrant-vms](https://github.com/falkor/vagrant-vms) repository and available on [Vagrant cloud](https://atlas.hashicorp.com/boxes/search?utf8=%E2%9C%93&sort=&provider=virtualbox&q=svarrette).

You can list the available vagrant box as follows:

```bash
$> vagrant status
Current machine states:

     centos-7                  not created (virtualbox)
	   debian-7                  not created (virtualbox)

       This environment represents multiple VMs. The VMs are all listed
	   above with their current state. For more information about a specific
	   VM, run `vagrant status NAME`.
```

As suggested, you can run a debian 7 machine for instance by issuing:

      $> vagrant up debian-7

Then you can ssh into the machine afterwards:

      $> vagrant ssh debian-7

When you run `vagrant up <os>` to boot the VM, it is configured to be provisioned with the `.vagrant_init.rb` script.
This script is responsible for two main tasks:

1. pre-install the puppet modules listed as dependencies in `metadata.json`
2. make the appropriate symbolic link in the puppet module directory (to `/vagrant`) to ensure you can directly make changes and correct your own module transparently within the box.

So you can test the manifests of the `tests/` directory within the VM:

      $> vagrant ssh <os>
      [...]
      (vagrant)$> sudo puppet apply -t /vagrant/tests/init.pp

From now on, you can test (with --noop) the other manifests.

Run `vagrant halt` (or `vagrant destroy`) to stop (or kill) the VM once you've finished to play with it.

_Note_: The `Vagrantfile` at the root of this repository might evolve over the time with new boxes. To automatically get the last version available:

1. Upgrade the [`falkorlib`](https://rubygems.org/gems/falkorlib) gem

          $> bundle update falkorlib
		  $> git commit -s -m "Upgrade falkorlib to the latest version" Gemfile.lock

2. update the `Vagrantfile` to the last version by issuing:

          $> rake templates:upgrade:vagrant
