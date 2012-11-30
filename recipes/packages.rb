#
# Cookbook Name:: casserole
# Recipe:: packages
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

node["cassandra"]["packages"].each do |pkg, attrs|
    package pkg do
        action :install
        version attrs["version"] if attrs["version"]
    end
end

# Some packages start the service and some don't, strive for parity here and
# auto-generated data can be destroyed as part of the bootstrap process
service node["cassandra"]["name"] do
    action [:enable, :start]
end

# vim:et:fdm=marker:sts=4:sw=4:ts=4:
