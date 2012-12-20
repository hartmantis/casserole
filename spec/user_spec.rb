require "chefspec"

describe "casserole::user" do
  let (:chef_run) { ChefSpec::ChefRunner.new }

  before(:each) do
    chef_run.node.automatic_attrs["platform_family"] = "rhel"
    @rcp = "casserole::user"
  end

  it "should create the Cassandra user" do
    chef_run.converge @rcp
    chef_run.should create_user "cassandra"
  end

  # ChefSpec has no create_group test
  it "should create the Cassandra group" do
    Chef::Recipe.any_instance.should_receive(:group).with "cassandra"
    chef_run.converge @rcp
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
