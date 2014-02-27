include_recipe 'java'
include_recipe 'nginx-zoo::default'

group node["cojure_web"]["group"] do
  action :create
end

user node["clojure_web"]["user"] do
  gid node["cojure_web"]["group"]
end

directory "/opt/#{node["clojure_web"]["app_name"]}" do
  mode "0755"
  owner node["clojure_web"]["user"]
  group node["clojure_web"]["group"]
  action :create
end

remote_file "/opt/#{node["clojure_web"]["app_name"]}/#{node["clojure_web"]["app_name"]}_#{node["clojure_web"]["app_version"]}.jar" do
  action :create
  owner node["clojure_web"]["user"]
  mode "0644"
  source node["clojure_web"]["artefact"]
end

template "/etc/init/#{node["clojure_web"]["app_name"]}.conf" do
  source "kafka.upstart.conf.erb"
  owner "root"
  group "root"
  variables ({
    name: node["clojure_web"]["app_name"],
    user: node["clojure_web"]["user"],
    group: node["clojure_web"]["group"]
  })
  mode "0644"
end

service node["clojure_web"]["app_name"] do
  provider Chef::Provider::Service::Upstart
  supports start: true, restart: true
  action [:enable, :start]
end

template "/usr/local/nginx/conf/sites-available/#{node['clojure_web']['app_name']}.conf" do
  source "default.conf.erb"
  owner node['nginx']['user']
  group node['nginx']['group']
  mode "0644"
  variables({app_name: node['clojure_web']['app_name']})
  action :create
end

unless ::File.exist?("/usr/local/nginx/conf/sites-enabled/#{node['clojure_web']['app_name']}.conf")
  src = "/usr/local/nginx/conf/sites-available/#{node['clojure_web']['app_name']}.conf"
  dest = "/usr/local/nginx/conf/sites-enabled/#{node['clojure_web']['app_name']}.conf"
  execute "symlink to sites-enabled" do
    command "ln -s #{src} #{dest}"

    notifies :restart, "service[nginx]"
    notifies :start, "service[#{node['app_name']['name']}]"
  end
end
