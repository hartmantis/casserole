Description
===========

A cookbook for deploying DataStax Community Cassandra and OpsCenter and
configuring a basic Cassandra cluster.

Heavy influence for this cookbook has been drawn from 
[DataStax's](https://github.com/riptano/chef) own set of cookbooks and the
Cassandra community
[cookbook](http://community.opscode.com/cookbooks/cassandra). It's been some
time since either of those were updated, and this cookbook is written to meet
a slightly different set of needs, hence the new cookbook.

This cookbook is designed to hopefully be overrideable to the point where
non-DataStax packages could easily be dropped in instead, as there are at least
a few packagers of Apache Cassandra..

Requirements
============

RHEL/CentOS 5/6 or Ubuntu 10.04/12.04 (possibly other untested distros/vers)

Attributes
==========

Some important attributes that a person might want to override for their own
deployment:

    normal["java"]["install_flavor"] = "oracle"

Oracle Java seems to be the recommended for Cassandra, but OpenJDK would work

    default["cassandra"]["name"] = "cassandra"

The name of the software, as used in the service definitions, etc

    default["cassandra"]["conf_dir"] = "/etc/cassandra"

Cassandra's main configuration directory

    default["cassandra"]["extra_services"] = ["opscenterd"]

Any services beyond `node["cassandra"]["name"]` that the cookbook manages

    default["cassandra"]["packages"] = {
        "python-cql" => {"version" => "1.0.10-1"},
        "dsc1.1" => {"version" => "1.1.6-1"},
        "opscenter-free" => {"version" => "2.1.2-1"}
    }

The packages and versions (or nil values) Cassandra needs

    default["cassandra"]["repos"] = {
        "datastax_community" => {
            "description" => "DataStax Community Repo for Apache Cassandra",
            "url" => ds_url,
            "key" => ds_key,
            "components" => ds_components
        }
    }

The package repositories required for the Cassandra packages.

Usage
=====

Nothing special yet, but complexity will increase as full clustering
functionality is added

Development
=====

Pull requests are gladly accepted!

This cookbook uses a number of tools that are required for development:

* [Vagrant](http://vagrantup.com/) and
[VirtualBox](https://www.virtualbox.org/) for creating virtual environments
* [Berkshelf](http://berkshelf.com/) for retrieving cookbook dependencies
* [Foodcritic](http://acrmp.github.com/foodcritic/) for lint testing
* [ChefSpec](https://github.com/acrmp/chefspec/) for the cookbook tests (see
the cookbook spec/ directory)
* [Minitest Chef Handler](https://github.com/calavera/minitest-chef-handler)
for the integration tests
* [Test Kitchen](https://github.com/opscode/test-kitchen) for wrapping all the
tests in a neat, little package

Testing
=====

To have Berkshelf pull in all dependencies and start a Vagrant development env:

    vagrant up

To run the Foodcritic lint tests:

    foodcritic .

To run the ChefSpec tests:

    rspec

To run the full Test Kitchen convergence suite:

    kitchen test

To Do
=====

* Should every recipe really get its own Minitests? Test Kitchen runs would go
much faster with only one configuration, e.g. everything in default.
* Test Kitchen's integration\_tests are funky, can that do ChefSpec?
* Functional tests are not yet integrated to ensure Cassandra is working. :(
* CLUSTERING!!!
