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
        "endpoint_snitch" => "flavius"
      }
      Chef::Recipe.any_instance.should_receive(:data_bag_item).
        with("clusterfarks", "dragons").and_return(@bag)
      chef_run.converge @rcp
    end

# Bug in ChefSpec(?) fails trying to cast the nodes hash as an array
#    it "sets the cluster_nodes attribute" do
#      puts @bag["nodes"]
#      chef_run.node["cassandra"]["cluster_nodes"].should == @bag["nodes"]
#    end

    {
      "listen_address" => "1.2.3.4",
      "broadcast_address" => "192.168.201.2",
      "datacenter" => "dc1",
      "rack" => "rack1",
      "endpoint_snitch" => "flavius",
      "seed_list" => ["192.168.201.2", "192.168.202.2"],
      "initial_token" => "wang"
    }.each do |attr, val|
      it "sets the #{attr} Cassandra attribute" do
        chef_run.node["cassandra"][attr].should == val
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
