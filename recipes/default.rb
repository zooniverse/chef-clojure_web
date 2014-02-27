include_recipe 'java'
include_recipe 'nginx-zoo::default'

group node["clojure_web"]["group"] do
  action :create
end

user node["clojure_web"]["user"] do
  gid node["clojure_web"]["group"]
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

remote_file "/opt/#{node["clojure_web"]["app_name"]}/#{node["clojure_web"]["app_name"]}_#{node["clojure_web"]["app_version"]}.edn" do
  action :create
  owner node["clojure_web"]["user"]
  mode "0644"
  source node["clojure_web"]["conf"]
end

template "/etc/init/#{node["clojure_web"]["app_name"]}.conf" do
  source "clojure_web.upstart.conf.erb"
  owner "root"
  group "root"
  variables ({
    name: "#{node["clojure_web"]["app_name"]}/#{node["clojure_web"]["app_name"]}_#{node["clojure_web"]["app_version"]}",
    user: node["clojure_web"]["user"],
    group: node["clojure_web"]["group"],
    max_heap: node["clojure_web"]["max_heap"],
    init_heap: node["clojure_web"]["init_heap"]
  })
  mode "0644"
end

service node["clojure_web"]["app_name"] do
  provider Chef::Provider::Service::Upstart
  supports start: true, restart: true
  action [:enable, :start]
end

template "/usr/local/nginx/conf/sites-available/#{node['clojure_web']['app_name']}.conf" do
  source "site.conf.erb"
  owner node['nginx']['user']
  group node['nginx']['group']
  mode "0644"
  variables({name: node['clojure_web']['app_name']})
  action :create
end

unless ::File.exist?("/usr/local/nginx/conf/sites-enabled/#{node['clojure_web']['app_name']}.conf")
  src = "/usr/local/nginx/conf/sites-available/#{node['clojure_web']['app_name']}.conf"
  dest = "/usr/local/nginx/conf/sites-enabled/#{node['clojure_web']['app_name']}.conf"
  execute "symlink to sites-enabled" do
    command "ln -s #{src} #{dest}"

    notifies :restart, "service[nginx]"
    notifies :start, "service[#{node['clojure_web']['app_name']}]"
  end
end
