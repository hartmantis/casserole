require "chefspec"

describe "casserole::encryption" do
  let (:chef_run) { ChefSpec::ChefRunner.new }

  before(:each) do
    chef_run.node.automatic_attrs["platform_family"] = "rhel"
    chef_run.node.set["cassandra"]["encryption_options"]["key"] = "stuff"
    chef_run.node.set["cassandra"]["encryption_options"]["crt"] = "more"
    @rcp = "casserole::encryption"
  end

  context "encryption for all nodes" do
    before :each do
      chef_run.node.
        set["cassandra"]["encryption_options"]["internode_encryption"] = "all"
      chef_run.converge @rcp
    end

    it "should create the keystore and truststore directory" do
      chef_run.should create_directory "/etc/cassandra/conf"
    end

    it "should dump the .key and .crt files to disk" do
      chef_run.should create_file_with_content("/var/chef/cache/casserole.key",
        "stuff")
      chef_run.should create_file_with_content("/var/chef/cache/casserole.crt",
        "more")
    end

    it "should run the update_keystore script" do
      chef_run.script("update_keystore").should be
    end

    it "should run the update_truststore script" do
      chef_run.script("update_truststore").should be
    end

    it "should clean up the .key and .crt files" do
      chef_run.should delete_file "/var/chef/cache/casserole.key"
      chef_run.should delete_file "/var/chef/cache/casserole.crt"
    end
  end

  context "an unsupported encryption config" do
    before :each do
      Chef::Formatters::Base.any_instance.stub(:file_load_failed)
      chef_run.node.
        set["cassandra"]["encryption_options"]["internode_encryption"] = "monk"
    end

    it "should raise an unsupported exception" do
      expect { chef_run.converge @rcp }.to raise_error(
        Chef::Exceptions::ConfigurationError,
        "Unsupported encryption scheme: monk")
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
