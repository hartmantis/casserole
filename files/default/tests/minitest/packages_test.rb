#
# Cookbook Name:: casserole
# Spec:: packages_test
#
# Copyright 2012, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path("../support/helpers.rb", __FILE__)

describe_recipe "casserole::packages" do
  include Helpers::Casserole

  it "installs the appropriate packages" do
    node["cassandra"]["packages"].each do |pkg, attrs|
      if attrs["version"]
        package(pkg).must_be_installed.with(:version, attrs["version"])
      else
        package(pkg).must_be_installed
      end
    end
  end

  it "installs the cql Python library" do
    found_pycql = false
    %w{python2.7 python2.6 python}.each do |p|
      res = %x{which #{p}}
      $?.exitstatus == 0 and %x{#{p} -c "import cql"} == "" and
        found_pycql = true and break
    end
    found_pycql.must_equal true
  end

  it "installs the cqlsh shell client" do
    res = %x{which cqlsh}
    res.wont_equal ""
    $?.exitstatus.must_equal 0
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
