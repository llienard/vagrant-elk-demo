# -*- mode: ruby -*-
# vi: set ft=ruby :

# vms = [
#   {
#     :type => "elastic",
#     :role => "master",
#     :hostname => "elk",
#     :private_ip => "192.168.56.10",
#     :ram => 8048,
#     :cpu => 4
#   },
#   {
#   :type => "elastic",
#    :role => "node",
#    :hostname => "elastic-node-1",
#    :private_ip => "192.168.56.11",
#    :ram => 2048,
#    :cpu => 1
#   },
#   {
#    :type => "elastic",
#    :role => "node",
#    :hostname => "elastic-node-2",
#    :private_ip => "192.168.56.12",
#    :ram => 2048,
#    :cpu => 1
#   },
#   {
#   :type => "kibana",
#   :role => "kibana",
#   :hostname => "elastic-kibana",
#   :private_ip => "192.168.56.100",
#   :ram => 1024,
#   :cpu => 2
#   }
# ]

machines = [
  {
    :hostname => "elk",
    :private_ip => "192.168.56.10",
    :ram => 8192,
    :cpu => 6,
    :tags => [ "elasticsearch", "kibana" ]
  },
  {
    :hostname => "work1",
    :private_ip => "192.168.56.20",
    :ram => 2048,
    :cpu => 1,
    :tags => [ "filebeat" ]
  }
]

Vagrant.configure("2") do |config|
  config.vagrant.plugins = ['vagrant-hostmanager']
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  machines.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = "ubuntu/focal64"
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:private_ip], virtualbox__intnet: true
      
      if machine[:tags].include? 'elasticsearch'
        node.vm.network "forwarded_port", guest: 9200, host: 9200
      end
      
      if machine[:tags].include? 'kibana'
        node.vm.network "forwarded_port", guest: 5601, host: 5601
      end

      node.vm.provider "virtualbox" do |v|
        v.name = machine[:hostname]
        v.check_guest_additions = false
        v.memory = machine[:ram]
        v.cpus = machine[:cpu]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      end
    end

    #
    # Run Ansible from the Vagrant Host
    #
    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "playbook_elk.yml"
      ansible.groups = {
        "elasticsearch" => machines.select { |machine| machine[:tags].include? 'elasticsearch' }.collect { |machine| machine[:hostname] },
        "kibana" => machines.select { |machine| machine[:tags].include? 'kibana' }.collect { |machine| machine[:hostname] },
        "logstash" => machines.select { |machine| machine[:tags].include? 'logstash' }.collect { |machine| machine[:hostname] },
        "filebeat" => machines.select { |machine| machine[:tags].include? 'filebeat' }.collect { |machine| machine[:hostname] },
        "all_groups:children" => ["elasticsearch", "kibana", "logstash", "filebeat"]
      }
      ansible.host_vars = {
        "es_url" => "http://#{machines.find {  |machine| machine[:tags].include? 'elasticsearch' }[:private_ip]}:9200",
        "kibana_url" => "http://#{machines.find {  |machine| machine[:tags].include? 'kibana' }[:private_ip]}:5601",

      }
      
    end
  end
end
