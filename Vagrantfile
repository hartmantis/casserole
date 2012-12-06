# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV["BERKSHELF_PATH"] = File.expand_path(".berkshelf")
require "berkshelf/vagrant"

box_prefix = "https://opscode-vm.s3.amazonaws.com/vagrant/boxes"

Vagrant::Config.run do |config|
    # Seed nodes MUST be started first
    config.vm.define :centos5 do |centos|
        centos.vm.box = "opscode-centos-5.8"
        centos.vm.box_url = "#{box_prefix}/opscode-centos-5.8.box"
        centos.vm.host_name = "cassandra1.dc1.example.com"
        centos.vm.network :hostonly, "192.168.201.2"
    end

    config.vm.define :ubuntu1004 do |ubuntu|
        ubuntu.vm.box = "opscode-ubuntu-10.04"
        ubuntu.vm.box_url = "#{box_prefix}/opscode-ubuntu-10.04.box"
        ubuntu.vm.host_name = "cassandra1.dc2.example.com"
        ubuntu.vm.network :hostonly, "192.168.201.4"
    end

    config.vm.define :centos6 do |centos|
        centos.vm.box = "opscode-centos-6.3"
        centos.vm.box_url = "#{box_prefix}/opscode-centos-6.3.box"
        centos.vm.host_name = "cassandra2.dc1.example.com"
        centos.vm.network :hostonly, "192.168.201.3"
    end

    config.vm.define :ubuntu1204 do |ubuntu|
        ubuntu.vm.box = "opscode-ubuntu-12.04"
        ubuntu.vm.box_url = "#{box_prefix}/opscode-ubuntu-12.04.box"
        ubuntu.vm.host_name = "cassandra2.dc2.example.com"
        ubuntu.vm.network :hostonly, "192.168.201.5"
    end

#    config.vm.define :singlenode do |singlenode|
#        singlenode.vm.box = "opscode-centos-6.3"
#        singlenode.vm.box_url = "#{box_prefix}/opscode-centos-6.3.box"
#        singlenode.vm.host_name = "singlenode.example.com"
#    end
        
    config.vm.provision :chef_solo do |chef|
        chef.add_recipe "casserole"
        chef.json = {
            :cassandra => {
                :clustered => true,
                :cluster_name => "cluster1"
            }
        }
        chef.data_bags_path = "test/data_bags"
    end
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
