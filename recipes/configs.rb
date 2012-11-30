#
# Cookbook Name:: casserole
# Recipe:: configs
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

service node["cassandra"]["name"]

# Set on the recipe side so install_flavor overrides will be recognized
case node["java"]["install_flavor"]
when "oracle"
    node.default["cassandra"]["jvm_stack_size"] = "160k"
else
    node.default["cassandra"]["jvm_stack_size"] = "128k"
end

template "#{node["cassandra"]["conf_dir"]}/cassandra-env.sh" do
    owner "root"
    group "root"
    mode "0755"
    source "configs/cassandra-env.sh.erb"
    action :create
    variables(
        :stack_size => node["cassandra"]["jvm_stack_size"]
    )
    notifies :restart, "service[#{node["cassandra"]["name"]}]"
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
