require "chefspec"

describe "casserole::default" do
    let (:chef_run) { ChefSpec::ChefRunner.new }

    before(:each) do
        chef_run.node.automatic_attrs["platform_family"] = "rhel"
        %w{java casserole::repos casserole::packages}.each do |r|
            chef_run.node.run_state.seen_recipes[r] = true
        end
    end

    it "should install Oracle Java" do
        chef_run.converge "casserole::default"
        chef_run.node.java.install_flavor.should == "oracle"
        chef_run.node.java.oracle.accept_oracle_download_terms.should == true
        chef_run.should include_recipe "java"
    end

    it "should include the required recipes" do
        chef_run.converge "casserole::default"
        chef_run.should include_recipe "casserole::repos"
        chef_run.should include_recipe "casserole::packages"
    end
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
