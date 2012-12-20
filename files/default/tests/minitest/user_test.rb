#
# Cookbook Name:: casserole
# Spec:: user_test
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

describe_recipe "casserole::user" do
  include Helpers::Casserole

  it "ensures the Cassandra user and group are created" do
    user(node["cassandra"]["user"]).must_exist
    group(node["cassandra"]["group"]).must_exist
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
