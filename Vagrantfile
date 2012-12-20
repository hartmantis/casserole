# -*- mode: ruby -*-

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
    centos.vm.provision :chef_solo do |chef|
      chef.add_recipe "casserole"
      chef.json = {
        :cassandra => {
          :clustered => true,
          :data_bag => "cassandra_clusters",
          :cluster_name => "cluster1",
          :listen_address => "192.168.201.2"
        }
      }
      chef.data_bags_path = "test/data_bags"
    end
  end

  config.vm.define :ubuntu1004 do |ubuntu|
    ubuntu.vm.box = "opscode-ubuntu-10.04"
    ubuntu.vm.box_url = "#{box_prefix}/opscode-ubuntu-10.04.box"
    ubuntu.vm.host_name = "cassandra1.dc2.example.com"
    ubuntu.vm.network :hostonly, "192.168.201.4"
    ubuntu.vm.provision :chef_solo do |chef|
      chef.add_recipe "casserole"
      chef.json = {
        :cassandra => {
          :clustered => true,
          :data_bag => "cassandra_clusters",
          :cluster_name => "cluster1",
          :listen_address => "192.168.201.4"
        }
      }
      chef.data_bags_path = "test/data_bags"
    end
  end

  config.vm.define :centos6 do |centos|
    centos.vm.box = "opscode-centos-6.3"
    centos.vm.box_url = "#{box_prefix}/opscode-centos-6.3.box"
    centos.vm.host_name = "cassandra2.dc1.example.com"
    centos.vm.network :hostonly, "192.168.201.3"
    centos.vm.provision :chef_solo do |chef|
      chef.add_recipe "casserole"
      chef.json = {
        :cassandra => {
          :clustered => true,
          :data_bag => "cassandra_clusters",
          :cluster_name => "cluster1",
          :listen_address => "192.168.201.3"
        }
      }
      chef.data_bags_path = "test/data_bags"
    end
  end

  config.vm.define :ubuntu1204 do |ubuntu|
    ubuntu.vm.box = "opscode-ubuntu-12.04"
    ubuntu.vm.box_url = "#{box_prefix}/opscode-ubuntu-12.04.box"
    ubuntu.vm.customize ["modifyvm", :id, "--memory", 1024]
    ubuntu.vm.host_name = "cassandra2.dc2.example.com"
    ubuntu.vm.network :hostonly, "192.168.201.5"
    ubuntu.vm.provision :chef_solo do |chef|
      chef.add_recipe "casserole"
      chef.json = {
        :cassandra => {
          :clustered => true,
          :data_bag => "cassandra_clusters",
          :cluster_name => "cluster1",
          :listen_address => "192.168.201.5"
        }
      }
      chef.data_bags_path = "test/data_bags"
    end
  end

#  config.vm.define :singlenode do |singlenode|
#    singlenode.vm.box = "opscode-centos-6.3"
#    singlenode.vm.box_url = "#{box_prefix}/opscode-centos-6.3.box"
#    singlenode.vm.host_name = "singlenode.example.com"
#  end
    
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
