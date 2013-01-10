require "chefspec"
require "json"

describe "casserole::configs" do
  let (:chef_run) { ChefSpec::ChefRunner.new }

  before(:each) do
    chef_run.node.automatic_attrs["platform_family"] = "rhel"
    @rcp = "casserole::configs"
    @user = "cassandra"
    @group = "cassandra"
  end

  context "test results that don't change between clustered and non" do
    before(:each) do
      chef_run.converge @rcp
    end

    it "should make sure the conf directory is created" do
      dir = "/etc/cassandra/conf"
      chef_run.should create_directory dir
      chef_run.directory(dir).should be_owned_by(@user, @group)
    end

    it "should create cassandra.in.sh" do
      f = "/etc/cassandra/conf/cassandra.in.sh"
      strs = [
        "CASSANDRA_CONF=/etc/cassandra/conf",
        "for jar in /usr/share/cassandra/*.jar /usr/share/cassandra/lib/*.jar;"
      ]
      strs.each do |c|
        chef_run.should create_file_with_content(f, c)
      end
      chef_run.template(f).should be_owned_by(@user, @group)
      chef_run.template(f).should notify("service[cassandra]", :restart)
    end

    it "should create cassandra-env.sh" do
      f = "/etc/cassandra/conf/cassandra-env.sh"
      chef_run.should create_file f
      chef_run.template(f).should be_owned_by(@user, @group)
      chef_run.template(f).should notify("service[cassandra]", :restart)
    end

    # ChefSpec can't test if/not_if conditionals yet
    it "should call the script to alter the cluster_name" do
      chef_run.script("alter_cluster_name").should be
    end
  end

  context "a single, un-clustered node (default)" do
    before(:each) do
      chef_run.node.automatic_attrs["ipaddress"] = "1.2.3.4"
      chef_run.converge @rcp
    end

    it "should create cassandra.yaml" do
      f = "/etc/cassandra/conf/cassandra.yaml"
      strs = [
        "cluster_name: 'Casserole Cluster'",
        "initial_token: \n",
        "- seeds: \"127.0.0.1\"",
        "storage_port: 7000\n",
        "ssl_storage_port: 7001\n",
        "listen_address: 1.2.3.4",
        "broadcast_address: \n",
        "endpoint_snitch: SimpleSnitch",
        "internode_encryption: none\n",
        "keystore: /etc/cassandra/conf/.keystore\n",
        "keystore_password: cassandra\n",
        "truststore: /etc/cassandra/conf/.truststore\n",
        "truststore_password: cassandra\n"
      ]
      strs.each do |c|
        chef_run.should create_file_with_content(f, c)
      end
      chef_run.template(f).should be_owned_by(@user, @group)
      chef_run.template(f).should notify("service[cassandra]", :restart)
    end

    it "should create cassandra-rackdc.properties" do
      f = "/etc/cassandra/conf/cassandra-rackdc.properties"
      ["dc=DC1\n", "rack=RAC1\n"].each do |c|
        chef_run.should create_file_with_content(f, c)
      end
      chef_run.template(f).should be_owned_by(@user, @group)
      chef_run.template(f).should notify("service[cassandra]", :restart)
    end

    it "should create cassandra-topology.properties" do
      f = "/etc/cassandra/conf/cassandra-topology.properties"
      strs = [
        "# Cassandra Node IP=Data Center:Rack\n\n# default for",
        "default=DC1:RAC1\n"
      ]
      strs.each do |c|
        chef_run.should create_file_with_content(f, c)
      end
      chef_run.template(f).should be_owned_by(@user, @group)
      chef_run.template(f).should notify("service[cassandra]", :restart)
    end
  end

  context "a node that is part of a cluster" do
    before(:each) do
      chef_run.node.automatic_attrs["ipaddress"] = "4.3.2.1"
      chef_run.node.automatic_attrs["fqdn"] =
        "cassandra1.dc1.example.com"
      chef_run.node.set["cassandra"] = {
        "clustered" => true,
        "datacenter" => "dc1",
        "rack" => "rack1",
        "broadcast_address" => "192.168.201.2",
        "initial_token" => "85070591730234615865843651857942052864",
        "seed_list" => ["192.168.201.2", "192.168.201.4"],
        "cluster_name" => "cluster1",
        "endpoint_snitch" => "PropertyFileSnitch",
        "cluster_nodes" => {
          "cassandra1.dc1.example.com" => {
            "broadcast_address" => "192.168.201.2",
            "datacenter" => "dc1",
            "rack" => "rack1",
            "seed" => true
          },
          "cassandra2.dc1.example.com" => {
            "broadcast_address" => "192.168.201.3",
            "datacenter" => "dc1",
            "rack" => "rack1"
          },
          "cassandra1.dc2.example.com" => {
            "broadcast_address" => "192.168.201.4",
            "datacenter" => "dc2",
            "rack" => "rack1",
            "seed" => true
          },
          "cassandra2.dc2.example.com" => {
            "broadcast_address" => "192.168.201.5",
            "datacenter" => "dc2",
            "rack" => "rack1"
          }
        }
      }
      chef_run.converge @rcp
    end

    it "should create cassandra.yaml" do
      f = "/etc/cassandra/conf/cassandra.yaml"
      strs = [
        "cluster_name: 'cluster1'",
        "initial_token: 85070591730234615865843651857942052864",
        "- seeds: \"192.168.201.2,192.168.201.4\"",
        "listen_address: 4.3.2.1",
        "broadcast_address: 192.168.201.2",
        "endpoint_snitch: PropertyFileSnitch"
      ]
      strs.each do |c|
        chef_run.should create_file_with_content(f, c)
      end
      chef_run.template(f).should be_owned_by(@user, @group)
      chef_run.template(f).should notify("service[cassandra]", :restart)
    end

    it "should create cassandra-rackdc.properties" do
      f = "/etc/cassandra/conf/cassandra-rackdc.properties"
      ["dc=dc1\n", "rack=rack1\n"].each do |c|
        chef_run.should create_file_with_content(f, c)
      end
      chef_run.template(f).should be_owned_by(@user, @group)
      chef_run.template(f).should notify("service[cassandra]", :restart)
    end

    it "should create cassandra-topology.properties" do
      f = "/etc/cassandra/conf/cassandra-topology.properties"
      content = <<-END.gsub(/^ +/, "")
        # Cassandra Node IP=Data Center:Rack
        192.168.201.2=dc1:rack1
        192.168.201.3=dc1:rack1
        192.168.201.4=dc2:rack1
        192.168.201.5=dc2:rack1
        
        # default for unknown nodes
        default=DC1:RAC1
      END
      chef_run.should create_file_with_content(f, content)
      chef_run.template(f).should be_owned_by(@user, @group)
      chef_run.template(f).should notify("service[cassandra]", :restart)
    end
  end

  context "a node with overridden encryption options" do
    before(:each) do
      @f = "/etc/cassandra/conf/cassandra.yaml"
      @enc = {
        "internode_encryption" => "aardvark",
        "keystore" => "/alli/gator",
        "keystore_password" => "anaconda",
        "truststore" => "/ant/elope",
        "truststore_password" => "angelfish",
        "protocol" => "ape",
        "algorithm" => "armadillo",
        "store_type" => "ass",
        "cipher_suites" => %w{auk auklet}
      }
      chef_run.node.set["cassandra"]["encryption_options"] = @enc
      chef_run.converge @rcp
    end

    it "should set overridden encryption options in cassandra.yaml" do
      @enc.each do |k, v|
        unless k == "cipher_suites"
          chef_run.should create_file_with_content(@f, "#{k}: #{v}\n")
        else
          chef_run.should create_file_with_content(@f,
            "#{k}: [#{v.join(",")}]\n")
        end
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
