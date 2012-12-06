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
            [
                "CASSANDRA_CONF=/etc/cassandra/conf",
                "for jar in /usr/share/cassandra/lib/*.jar; do"
            ].each do |c|
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
    end

    context "a single, un-clustered node (default)" do
        before(:each) do
            chef_run.node.automatic_attrs["ipaddress"] = "1.2.3.4"
            chef_run.converge @rcp
        end

        it "should create cassandra.yaml" do
            f = "/etc/cassandra/conf/cassandra.yaml"
            [
                "cluster_name: 'Casserole Cluster'",
                "initial_token: \n",
                "- seeds: \"127.0.0.1\"",
                "listen_address: 1.2.3.4",
                "broadcast_address: \n",
                "endpoint_snitch: SimpleSnitch"
            ].each do |c|
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
            [
                "# Cassandra Node IP=Data Center:Rack\n\n# default for",
                "default=DC1:RAC1\n"
            ].each do |c|
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
                "cluster_name" => "cluster1"
            }
            f = "../../test/data_bags/cassandra_clusters/cluster1.json"
            bag = JSON.load(File.open(File.expand_path(f, __FILE__)))
            Chef::Recipe.any_instance.should_receive(:data_bag_item).
                with("cassandra_clusters", "cluster1").and_return(bag)
            chef_run.converge @rcp
        end

        it "should create cassandra.yaml" do
            f = "/etc/cassandra/conf/cassandra.yaml"
            [
                "cluster_name: 'cluster1'",
                "initial_token: 85070591730234615865843651857942052864",
                "- seeds: \"192.168.201.2,192.168.201.4\"",
                "listen_address: 4.3.2.1",
                "broadcast_address: 192.168.201.2",
                "endpoint_snitch: PropertyFileSnitch"
            ].each do |c|
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
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
