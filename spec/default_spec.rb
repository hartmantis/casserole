require "chefspec"

describe "casserole::default" do
  let (:chef_run) { ChefSpec::ChefRunner.new }

  before(:each) do
    chef_run.node.automatic_attrs["platform_family"] = "rhel"
    %w{
      java
      casserole::user
      casserole::repos
      casserole::packages
      casserole::token_generator
      casserole::configs
    }.each do |r|
      chef_run.node.run_state.seen_recipes[r] = true
    end
    @rcp = "casserole::default"
  end

  it "should install Oracle Java" do
    chef_run.converge @rcp
    chef_run.node["java"]["install_flavor"].should == "oracle"
    chef_run.node["java"]["oracle"]["accept_oracle_download_terms"].
      should == true
    chef_run.should include_recipe "java"
  end

  it "should include the required recipes" do
    chef_run.converge @rcp
    %w{
      casserole::user
      casserole::repos
      casserole::packages
      casserole::configs
    }.each do |r|
      chef_run.should include_recipe r
    end
    chef_run.should_not include_recipe "casserole::data_bag_parser"
    chef_run.should_not include_recipe "casserole::encryption"
  end

  it "should include the data bag recipe if it's a clustered, bagged node" do
    chef_run.node.set["cassandra"]["clustered"] = true
    chef_run.node.set["cassandra"]["data_bag"] = "some_bag"
    chef_run.node.run_state.seen_recipes["casserole::data_bag_parser"] = true
    chef_run.converge @rcp
    chef_run.should include_recipe "casserole::data_bag_parser"
  end

  it "should call the token generator recipe if clustered with no token" do
    chef_run.node.set["cassandra"]["clustered"] = true
    chef_run.node.run_state.seen_recipes["casserole::token_generator"] = true
    chef_run.converge @rcp
    chef_run.should include_recipe "casserole::token_generator"
  end

  it "should call the encryption recipe if set for Thrift over SSL" do
    chef_run.node.set["cassandra"]["encryption_options"] = {
      "internode_encryption" => "all"
    }
    chef_run.node.run_state.seen_recipes["casserole::encryption"] = true
    chef_run.converge @rcp
    chef_run.should include_recipe "casserole::encryption"
  end

  it "should enable and start the relevant services" do
    chef_run.converge @rcp
    %w{cassandra opscenterd}.each do |s|
      chef_run.should set_service_to_start_on_boot s
      chef_run.should start_service s
    end
  end

  it "should write to chef_install.log if it's the first run" do
    chef_run.converge @rcp
    chef_run.should create_file "/usr/share/cassandra/chef_install.log"
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
