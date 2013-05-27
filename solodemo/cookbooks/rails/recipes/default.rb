include_recipe "nginx"
include_recipe "unicorn"

package "libsqlite3-dev"

gem_package "bundler"

# name        : this is your application name
# app_root    : where is your store app path
# path_root   : root
# user        : username of server
# server_names: your domain name of your app
# environment : environment of your app (ex: staging , production , test, development ...).

common = {:name => "testviet", :app_root => "/home/rubyviet/www/testviet", :environment => "staging", :path_root => "/home/rubyviet", :user => "rubyviet", :server_names => "testviet.vn www.testviet.vn"}

directory common[:app_root] do
  owner common[:user]
  recursive true
end

directory "#{common[:path_root]}/www" do
  owner common[:user]
end

directory common[:app_root]+"/shared" do
  owner common[:user]
end

%w(config log tmp sockets pids).each do |dir|
  directory "#{common[:app_root]}/shared/#{dir}" do
    owner common[:user]
    recursive true
    mode 0755
  end
end

template "#{common[:app_root]}/shared/config/database.yml" do
  mode 0755
  source "database.conf.erb"
  variables common
end

template "#{node[:unicorn][:config_path]}/#{common[:name]}.conf.rb" do
  mode 0644
  source "unicorn.conf.erb"
  variables common
end

nginx_config_path = "/etc/nginx/sites-available/#{common[:name]}.conf"

template nginx_config_path do
  mode 0644
  source "nginx.conf.erb"
  variables common.merge(:server_names => common[:server_names])
  notifies :reload, "service[nginx]"
end

nginx_site common[:name] do
  config_path nginx_config_path
  action :enable
end