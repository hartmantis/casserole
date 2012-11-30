require "chefspec"

describe "casserole::packages" do
    let (:chef_run) { ChefSpec::ChefRunner.new }

    before(:each) do
        @rcp = "casserole::packages"
        chef_run.node.automatic_attrs["platform_family"] = "rhel"
    end

    context "RHEL servers" do
        before(:each) do
            chef_run.node.automatic_attrs["platform_family"] = "rhel"
            chef_run.converge @rcp
        end

        it "should install the appropriate RHEL packages" do
            chef_run.node.cassandra.packages.each do |p, attrs|
                chef_run.should install_package_at_version(p, attrs["version"])
            end
            chef_run.should_not install_package "python-cql"
        end
    end

    context "Debian servers" do
        before(:each) do
            chef_run.node.automatic_attrs["platform_family"] = "debian"
            chef_run.converge @rcp
        end

        it "should install the appropriate Debian packages" do
            chef_run.node.cassandra.packages.each do |p, attrs|
                chef_run.should install_package_at_version(p, attrs["version"])
            end
            chef_run.should install_package "python-cql"
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

    # This test intentionally left failing
    #it "should start the Cassandra services" do
    #    chef_run.converge @rcp
    #    chef_run.node.cassandra.services.each do |s|
    #        chef_run.should set_service_to_start_on_boot s
    #        chef_run.should start_service s
    #    end
    #end
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
