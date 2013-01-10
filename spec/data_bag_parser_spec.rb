require "chefspec"

describe "casserole::data_bag_parser" do
  let (:chef_run) { ChefSpec::ChefRunner.new }

  before(:each) do
    chef_run.node.automatic_attrs["platform_family"] = "rhel"
    chef_run.node.automatic_attrs["ipaddress"] = "192.168.201.2"
    chef_run.node.automatic_attrs["fqdn"] =
      "cassandra1.dc1.example.com"
    chef_run.node.set["cassandra"]["data_bag"] = "clusterfarks"
    chef_run.node.set["cassandra"]["cluster_name"] = "dragons"
    @rcp = "casserole::data_bag_parser"
  end

  context "all attributes overridden by data bag items" do
    before(:each) do
      @bag = {
        "id" => "dragons",
        "nodes" => {
          "cassandra1.dc1.example.com" => {
            "listen_address" => "1.2.3.4",
            "broadcast_address" => "192.168.201.2",
            "datacenter" => "dc1",
            "rack" => "rack1",
            "seed" => true,
            "initial_token" => "wang"
          },
          "cassandra1.dc2.example.com" => {
            "listen_address" => "1.2.3.5",
            "broadcast_address" => "192.168.202.2",
            "datacenter" => "dc2",
            "rack" => "rack1",
            "seed" => true,
            "initial_token" => "bang"
          },
          "cassandra2.dc2.example.com" => {
            "listen_address" => "1.2.3.6",
            "broadcast_address" => "192.168.202.3",
            "datacenter" => "dc2",
            "rack" => "rack2",
            "initial_token" => "tang"
          }
        },
        "endpoint_snitch" => "flavius",
        "encryption_options" => {
          "internode_encryption" => "some",
          "key" => "gibberish",
          "keystore" => "/hi/there.keystore",
          "keystore_password" => "secure",
          "crt" => "moregibberish",
          "truststore" => "/hi/there.truststore",
          "truststore_password" => "supersecure",
          "protocol" => "1",
          "algorithm" => "AlGoreRhythm",
          "store_type" => "SKJ",
          "cipher_suites" => %w{monkeys pants}
        }
      }
      Chef::Recipe.any_instance.should_receive(:data_bag_item).
        with("clusterfarks", "dragons").and_return(@bag)
      chef_run.converge @rcp
    end

    attrs = {
      "listen_address" => "1.2.3.4",
      "broadcast_address" => "192.168.201.2",
      "datacenter" => "dc1",
      "rack" => "rack1",
      "endpoint_snitch" => "flavius",
      "seed_list" => ["192.168.201.2", "192.168.202.2"],
      "initial_token" => "wang"
    }
    attrs.each do |attr, val|
      it "sets the #{attr} Cassandra attribute" do
        chef_run.node["cassandra"][attr].should == val
      end
    end

    it "sets the cluster_nodes attributes" do
      @bag["nodes"].each do |node, attrs|
        attrs.each do |k, v|
          chef_run.node["cassandra"]["cluster_nodes"][node][k].should == v
        end
      end
    end

    it "sets the encryption_options attributes" do
      @bag["encryption_options"].each do |k, v|
        chef_run.node["cassandra"]["encryption_options"][k].should == v
      end
    end
  end

  context "only some attributes overridden by data bag items" do
    it "does something" do
      pending
    end
  end

  context "a data bag was provided without the local node defined in it" do
    it "does something" do
      pending
    end

  end

  context "a data bag was provided resulting in an empty seed list" do
    it "does something" do
      pending
    end

  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
