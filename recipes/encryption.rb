#
# Cookbook Name:: casserole
# Recipe:: encryption
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

conf_dir = node["cassandra"]["conf_dir"]
internode_encryption =
  node["cassandra"]["encryption_options"]["internode_encryption"]
key = node["cassandra"]["encryption_options"]["key"]
keystore = File.expand_path(
  node["cassandra"]["encryption_options"]["keystore"], conf_dir)
keystore_password =
  node["cassandra"]["encryption_options"]["keystore_password"]
crt = node["cassandra"]["encryption_options"]["crt"]
truststore = File.expand_path(
  node["cassandra"]["encryption_options"]["truststore"], conf_dir)
truststore_password =
  node["cassandra"]["encryption_options"]["truststore_password"]

if !%w{all dc rack}.include?(internode_encryption)
  raise Chef::Exceptions::ConfigurationError,
    "Unsupported encryption scheme: #{internode_encryption}"
end

[File.dirname(keystore), File.dirname(truststore)].uniq.each do |d|
  directory d do
    owner node["cassandra"]["user"]
    group node["cassandra"]["group"]
    mode "0755"
    action :create
    recursive true
  end
end

{ "key" => key, "crt" => crt }.each do |k, v|
  file File.expand_path("casserole.#{k}", Chef::Config["file_cache_path"]) do
    content v
  end
end

script "update_keystore" do
  interpreter "bash"
  cwd Chef::Config["file_cache_path"]
  code <<-EOH.gsub(/^ +/, "")
    openssl pkcs12 -export -out casserole.p12 \
      -passout pass:#{keystore_password} -inkey casserole.key -in casserole.crt \
      -certfile casserole.crt -name casserole;
    $JAVA_HOME/bin/keytool -importkeystore \
      -deststorepass #{keystore_password} -destkeypass #{keystore_password} \
      -destkeystore #{keystore} -srckeystore casserole.p12 \
      -srcstoretype PKCS12 -srcstorepass #{keystore_password} \
      -alias casserole;
  EOH
  action :run
  only_if do
    %x{$JAVA_HOME/bin/keytool -list -alias casserole -keystore #{keystore} \
      -storepass #{keystore_password}}
    $?.exitstatus != 0
  end
end

script "update_truststore" do
  interpreter "bash"
  cwd Chef::Config["file_cache_path"]
  code <<-EOH.gsub(/^ +/, "")
    $JAVA_HOME/bin/keytool -import -alias casserole -file casserole.crt \
      -keystore #{truststore} -storepass #{truststore_password} -noprompt;
  EOH
  action :run
  only_if do
    %x{$JAVA_HOME/bin/keytool -list -alias casserole -keystore #{truststore} \
      -storepass #{truststore_password}}
    $?.exitstatus != 0
  end
end

{ "key" => key, "crt" => crt }.each do |k, v|
  file File.expand_path("casserole.#{k}", Chef::Config["file_cache_path"]) do
    action :delete
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby fdm=marker
