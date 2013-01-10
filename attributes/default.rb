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
#   http://www.apache.org/licenses/LICENSE-2.0
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

default["cassandra"]["clustered"] = false
default["cassandra"]["data_bag"] = nil
default["cassandra"]["node_id"] = node["fqdn"]

# Cluster definition attributes can be overridden by the data bags that
# cluster_parser.rb merges in, or by higher precedence attributes applied
# later
default["cassandra"]["cluster_name"] = "Casserole Cluster"
default["cassandra"]["cluster_nodes"] = {}
default["cassandra"]["listen_address"] = node["ipaddress"]
default["cassandra"]["broadcast_address"] = nil # Empty = reuse listen_address
default["cassandra"]["endpoint_snitch"] = "SimpleSnitch"
default["cassandra"]["seed_list"] = nil
default["cassandra"]["datacenter"] = nil
default["cassandra"]["rack"] = nil
default["cassandra"]["initial_token"] = nil # Empty = auto-bootstrap
default["cassandra"]["default_datacenter"] = "DC1"
default["cassandra"]["default_rack"] = "RAC1"

default["cassandra"]["name"] = "cassandra"
default["cassandra"]["user"] = "cassandra"
default["cassandra"]["group"] = "cassandra"
default["cassandra"]["home_dir"] = "/usr/share/cassandra"
default["cassandra"]["pid_file"] = "/var/run/cassandra/cassandra.pid"
default["cassandra"]["extra_services"] = ["opscenterd"]
default["cassandra"]["packages"] = {
  "python-cql" => { "version" => "1.0.10-1" },
  "dsc1.1" => { "version" => "1.1.6-1" },
  "opscenter-free" => { "version" => "2.1.2-1" }
}
default["cassandra"]["chef_gems"] = {
  "cassandra-cql" => { "version" => "1.1.4" }
}
default["cassandra"]["storage_port"] = 7000
default["cassandra"]["ssl_storage_port"] = 7001

# Encryption options
default["cassandra"]["encryption_options"]["internode_encryption"] = "none"
default["cassandra"]["encryption_options"]["key"] = nil
default["cassandra"]["encryption_options"]["keystore"] = ".keystore"
default["cassandra"]["encryption_options"]["keystore_password"] = "cassandra"
default["cassandra"]["encryption_options"]["crt"] = nil
default["cassandra"]["encryption_options"]["truststore"] = ".truststore"
default["cassandra"]["encryption_options"]["truststore_password"] = "cassandra"

# Advanced encryption options
default["cassandra"]["encryption_options"]["protocol"] = "TLS"
default["cassandra"]["encryption_options"]["algorithm"] = "SunX509"
default["cassandra"]["encryption_options"]["store_type"] = "JKS"
default["cassandra"]["encryption_options"]["cipher_suites"] = %w{
  TLS_RSA_WITH_AES_128_CBC_SHA
  TLS_RSA_WITH_AES_256_CBC_SHA
}

case node["platform_family"]
when "rhel"
  ds_url = "http://rpm.datastax.com/community"
  ds_key = nil
  ds_components = nil
  default["cassandra"]["packages"].delete("python-cql")
  default["cassandra"]["conf_dir"] = "/etc/cassandra/conf"
when "debian"
  ds_url = "http://debian.datastax.com/community"
  ds_key = "http://debian.datastax.com/debian/repo_key"
  ds_components = ["stable", "main"]
  default["cassandra"]["conf_dir"] = "/etc/cassandra"
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

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
