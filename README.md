[![Build Status](https://travis-ci.org/RoboticCheese/casserole.png?branch=master)](https://travis-ci.org/RoboticCheese/casserole)

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

* RHEL/CentOS 5/6 or Ubuntu 10.04/12.04 (possibly other untested distros/vers)
* For proper clustering `node["ipaddress"]` and `node["fqdn"]` Ohai attributes
that will match what is fed in via the cluster's data bag item.

Attributes
==========

Some important attributes that a person might want to override for their own
deployment:

    normal["java"]["install_flavor"] = "oracle"

Oracle Java seems to be the recommended for Cassandra, but OpenJDK would work

    default["cassandra"]["clustered"] = false

Is this node meant to be a part of a multi-node cluster?

    default["cassandra"]["cluster_name"] = "Casserole Cluster"

Name of the cluster of which the node is a member

    default["cassandra"]["data_bag"] = nil

Cluster information can be obtained from a central data bag instead of node
attributes if a data bag name is set.

    default["cassandra"]["node_id"] = node["fqdn"]

The unique name the node is identified by in the cluster's data bag item

    default["cassandra"]["encryption_options"]["internode_encryption"] = "none"
    default["cassandra"]["encryption_options"]["key"] = nil 
    default["cassandra"]["encryption_options"]["keystore"] = ".keystore"
    default["cassandra"]["encryption_options"]["keystore_password"] = "cassandra"
    default["cassandra"]["encryption_options"]["crt"] = nil 
    default["cassandra"]["encryption_options"]["truststore"] = ".truststore"
    default["cassandra"]["encryption_options"]["truststore_password"] = "cassandra"

Options for enabling SSL encryption of the Thrift traffic between nodes/datacenters

    default["cassandra"]["listen_address"] = node["ipaddress"]

The IP address for the node to listen on

    default["cassandra"]["name"] = "cassandra"

The name of the software, as used in the service definitions, etc

    default["cassandra"]["conf_dir"] = "/etc/cassandra/conf"

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
* Test Kitchen's integration\_tests are funky, can they do ChefSpec so the
preflight override isn't needed?
* Functional tests are not yet integrated to ensure Cassandra is working. :(
* What happens to the tokens and distribution if a current cluster needs a node
added?
* Authentication support for Cassandra
* Authentication support for the Opscenter web UI
* Support for IPv6
* Is restarting Cassandra on template changes really acceptable?
* Kitchen tests for a clustered configuration
* Find a more elegant way to handle the conf dirs (/etc/cassandra/conf in RHEL
vs /etc/cassandra in Ubuntu)
* Use search instead of data\_bag\_item to determine cluster ID, use
chef-solo-search to mock in test
* Better exception checking for the items that are required to come from a
data bag for a cluster
* Better logging, particularly when setting the cluster attributes and
calculating token IDs
* Can the two init scripts be combined with enough logic to be compatible
with Debian and RHEL, or do both really need to be maintained?
* Ubuntu 12.04 runs out of memory using the base box's 384MB, may mess with
being able to run Test Kitchen on Vagrant.
* Tokens are being calculated wrong:

    192.168.201.2   dc1         rack1       Up     Normal  20.39 KB        38.97%              57674485469197930195288808640163237968
    192.168.201.3   dc1         rack1       Up     Normal  20.39 KB        3.81%               64162880367564825393354959677131675083
    192.168.201.5   dc2         rack1       Up     Normal  20.39 KB        35.92%              125272177062940846191566045318489454887
    192.168.201.4   dc2         rack1       Up     Normal  20.39 KB        21.30%              161518014361785232698955613784408936953

* Need to template out `/etc/opscenter/opscenterd.conf`, bind address and possibly other stuff for Opscenter
* Firewall rules!
* Can the initial GUI setup of the Opscenter interface be automated?
* rpc\_address in cassandra.yaml
* Add support for individual encryption keys instead of one shared one
* Support both passworded *and* non-passworded key files
* Migrate JNA install to `java` community cookbook
* Migrate encryption keystore operations to `java` or a wrapper cookbook for it
* Refactor some of the RSpec tests to use contexts more
* Minitest tests for clustering (data bags + tokens) and encryption
