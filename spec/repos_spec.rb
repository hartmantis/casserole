require "chefspec"

describe "casserole::repos" do
    let (:chef_run) { ChefSpec::ChefRunner.new }

    before(:each) do
        @rcp = "casserole::repos"
        @repo = "datastax_community"
    end

    context "RHEL servers" do
        before(:each) do
            chef_run.node.automatic_attrs["platform_family"] = "rhel"
            chef_run.node.run_state[:seen_recipes]["yum"] = true
            Chef::Recipe.any_instance.stub(:yum_key).
                with("RPM-GPG-KEY-#{@repo}")
            Chef::Recipe.any_instance.stub(:yum_repository).with(@repo)
        end

        it "should install EPEL for RHEL5 servers" do
            chef_run.node.automatic_attrs["platform_version"] = "5.8"
            chef_run.node.run_state[:seen_recipes]["yum::epel"] = true
            chef_run.converge @rcp
            chef_run.should include_recipe "yum::epel"
        end

        it "should install the YUM repo for RHEL" do
            Chef::Recipe.any_instance.unstub(:yum_key)
            Chef::Recipe.any_instance.unstub(:yum_repository)
            Chef::Recipe.any_instance.should_receive(:yum_key).
                with("RPM-GPG-KEY-#{@repo}")
            Chef::Recipe.any_instance.should_receive(:yum_repository).
                with(@repo)
            chef_run.converge @rcp
            chef_run.should include_recipe "yum"
        end
    end

    context "Debian servers" do
        before(:each) do
            chef_run.node.automatic_attrs["platform_family"] = "debian"
            chef_run.node.run_state[:seen_recipes]["apt"] = true
        end

        it "should install the APT repo for Debian" do
            Chef::Recipe.any_instance.should_receive(:apt_repository).
                with(@repo)
            chef_run.converge @rcp
            chef_run.should include_recipe "apt"
        end
    end

    context "Unsupported platforms" do
        before(:each) do
            Chef::Formatters::Base.any_instance.stub(:file_load_failed)
            chef_run.node.automatic_attrs["platform_family"] = "windows"
            chef_run.node.automatic_attrs["platform"] = "Windows XP"
        end

        it "should raise an exception for unsupported platforms" do
            expect {chef_run.converge @rcp}.to raise_error(
                Chef::Exceptions::UnsupportedAction,
                "Cookbook does not support Windows XP platform")
        end
    end
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
