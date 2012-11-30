#
# Cookbook Name:: casserole
# Spec:: repos_test
#
# Copyright 2012, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require File.expand_path("../support/helpers.rb", __FILE__)

describe_recipe "casserole::repos" do
    include Helpers::Casserole

    it "configures the appropriate package repos" do
        node["cassandra"]["repos"].each do |repo, attrs|
            repo_is_enabled = false
            case node["platform_family"]
            when "rhel"
                file("/etc/yum.repos.d/#{repo}.repo").must_exist
                %x{yum repolist #{repo}}.split("\n").each do |line|
                    line.split[0] == repo and repo_is_enabled = true and break
                end
            when "debian"
                file("/etc/apt/sources.list.d/#{repo}-source.list").must_exist
                %x{apt-cache policy}.split("\n").each do |line|
                    line.split[1].match(/^#{attrs["url"]}\/?$/) and
                        repo_is_enabled = true and break
                end
            end
            repo_is_enabled.must_equal true
        end
    end
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
