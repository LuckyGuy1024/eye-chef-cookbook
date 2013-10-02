#
# Cookbook Name:: eye
# Recipe:: default
#
# Copyright 2013, Holger Amann <holger@fehu.org>
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

gem_package "bundler"

directory node['eye']['install_dir'] do
  owner node['eye']['user']
  group node['eye']['group']
  mode 0755
  action :create
end

execute 'bundle_eye' do
  command "#{node['languages']['ruby']['bin_dir']}/bundle install --path vendor/bundle --binstubs --quiet"
  cwd node['eye']['install_dir']
  user node['eye']['user']
  action :nothing
end

template "#{node['eye']['install_dir']}/Gemfile" do
  source "Gemfile.erb"
  owner node['eye']['user']
  group node['eye']['group']
  variables :version => node['eye']['version']
  action :create
  notifies :run, resources(:execute => "bundle_eye")
end

if node['eye']['bin_link_dir']
  link "#{node['eye']['bin_link_dir']}/eye" do
    to node['eye']['bin']
  end
end

%w(conf_dir run_dir log_dir).each do |dir|
  directory "#{node['eye'][dir]}" do
    owner node['eye']['user']
    group node['eye']['group']
    recursive true
    mode 0755
  end
end
