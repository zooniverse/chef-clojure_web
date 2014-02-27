# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.hostname = "clojure-web-berkshelf"

  config.vm.box = "opscode_ubuntu-12.04"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_ubuntu-12.04_chef-provisionerless.box"

  config.vm.network :private_network, ip: "33.33.33.11"

  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  config.vm.provider :virtualbox do |vm|
    vm.customize ["modifyvm", :id, "--memory", 2048]
    vm.customize ["modifyvm", :id, "--cpus", 2]
  end

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      clojure_web: {
        app_name: "zoo-live",
        app_version: "0.2.0-SNAPSHOT",
        artefact: "http://ubret.s3.amazonaws.com/zoo-live-0.2.0-SNAPSHOT.jar",
        conf: "http://ubret.s3.amazonaws.com/zoo-live-0.2.0-SNAPSHOT.edn"
      }
    }

    chef.run_list = [
      "recipe[apt]",
      "recipe[clojure_web::default]"
    ]
  end
end
