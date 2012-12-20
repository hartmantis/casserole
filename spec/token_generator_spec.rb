require "chefspec"

describe "casserole::token_generator" do
  let (:chef_run) { ChefSpec::ChefRunner.new }

  before(:each) do
    chef_run.node.automatic_attrs["platform_family"] = "rhel"
    chef_run.node.set["cassandra"]["node_id"] = "n2.dc3"
    chef_run.node.set["cassandra"]["datacenter"] = "dc3"
    chef_run.node.set["cassandra"]["cluster_nodes"] = {}
    (1..3).each do |dc|
      (1..5).each do |node|
        chef_run.node.set["cassandra"]["cluster_nodes"]["n#{node}.dc#{dc}"] = {
          "broadcast_address" => "1.2.#{dc}.#{node}",
          "datacenter" => "dc#{dc}"
        }
      end
    end
    @expected_token = 34028236692093846346337460743176821345
    chef_run.converge "casserole::token_generator"
  end

  it "should store the correct token attribute" do
    chef_run.node.cassandra.initial_token.should == @expected_token
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
