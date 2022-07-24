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
  }
]

Vagrant.configure("2") do |config|
  machines.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = "ubuntu/focal64"
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", type: "dhcp"
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
        "all_groups:children" => ["elasticsearch", "kibana", "logstash"]
      }
      # STDOUT.write "groups " . ansible.groups.to_json
      # ansible.host_vars = machines.inject({}) do |host_vars, machine|
      #   host_vars[machine[:hostname]] = {
      #     :tags => machine[:tags].join(' ')
      #   }
      #   host_vars
      # end
      
    end
  end
end
