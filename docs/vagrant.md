-*- mode: markdown; mode: visual-line; -*-

# Slurm Puppet Module Tests with Vagrant

The best way to test this module in a non-intrusive way is to rely on [Vagrant](http://www.vagrantup.com/).
[Vagrant](http://vagrantup.com/) uses [Oracle's VirtualBox](http://www.virtualbox.org/)
to build configurable, lightweight, and portable virtual machines dynamically.

* [Reference installation notes](http://docs.vagrantup.com/v2/installation/) -- assuming you have installed [Oracle's VirtualBox](http://www.virtualbox.org/)
* [installation notes on Mac OS](http://sourabhbajaj.com/mac-setup/Vagrant/README.html) using [Homebrew](http://brew.sh/) and [Cask](http://sourabhbajaj.com/mac-setup/Homebrew/Cask.html)

The `Vagrantfile` at the root of the repository pilot the provisioning a vagrant boxes.
It can run any OS you set in `tests/vagrant/config.yaml` as follows:

```yaml


```

You can list the available vagrant box as follows:

```bash
$> vagrant status
Current machine states:

centos-7                  running (virtualbox)

The VM is running. To stop this VM, you can run `vagrant halt` to
shut it down forcefully, or you can run `vagrant suspend` to simply
suspend the virtual machine. In either case, to restart it again,
simply run `vagrant up`.
```

You can boot the VM and provision it (using the scripts under `tests/vagrant/`) by running:

```bash
$> vagrant up
```

Then you can ssh into the machine afterwards:

```bash
$> vagrant ssh
```

When you run `vagrant up <name>` to boot the VM, the provisioning scripts are responsible for:

| Script                    | Description                                     |
|---------------------------|-------------------------------------------------|
| `bootstrap.sh`            | Install puppet 4 and defaults packages and gems |
| `puppet_modules_setup.rb` | pre-install the necessary puppet modules        |

More precisely, the `tests/vagrant/puppet_modules_setup.rb` script.
This script is responsible for two main tasks:

1. pre-install the puppet modules listed as dependencies in `metadata.json`
2. make the appropriate symbolic link in the puppet module directory (to `/vagrant`) to ensure you can directly make changes and correct your own module transparently within the box.

So you can test the manifests of the `tests/` directory within the VM:

      $> vagrant ssh [<os>]
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
