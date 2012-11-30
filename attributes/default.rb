#
# Cookbook Name:: casserole
# Attributes:: default
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

# Override OpenJDK to Oracle Java instead
normal["java"]["install_flavor"] = "oracle"
normal["java"]["oracle"]["accept_oracle_download_terms"] = true

default["cassandra"]["name"] = "cassandra"
default["cassandra"]["conf_dir"] = "/etc/cassandra"
default["cassandra"]["extra_services"] = ["opscenterd"]
default["cassandra"]["packages"] = {
    "python-cql" => {"version" => "1.0.10-1"},
    "dsc1.1" => {"version" => "1.1.6-1"},
    "opscenter-free" => {"version" => "2.1.2-1"}
}

case node["platform_family"]
when "rhel"
    ds_url = "http://rpm.datastax.com/community"
    ds_key = nil
    ds_components = nil
    default["cassandra"]["packages"].delete("python-cql")
when "debian"
    ds_url = "http://debian.datastax.com/community"
    ds_key = "http://debian.datastax.com/debian/repo_key"
    ds_components = ["stable", "main"]
else
    raise Chef::Exceptions::UnsupportedAction,
        "Cookbook does not support #{node["platform"]} platform"
end
default["cassandra"]["repos"] = {
    "datastax_community" => {
        "description" => "DataStax Community Repo for Apache Cassandra",
        "url" => ds_url,
        "key" => ds_key,
        "components" => ds_components
    }
}

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
