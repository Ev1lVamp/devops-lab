# -*- mode: ruby -*-
# DevOps-лабораторія: 4 віртуальні машини у VirtualBox.
#   control - Ansible, Git (звідси керуємо рештою)
#   web1/2  - Nginx + Docker
#   db      - PostgreSQL
#
# Порядок важливий: control піднімається першим і генерує SSH-ключ,
# який решта машин додає собі в authorized_keys.

NODES = [
  { name: "control", ip: "192.168.56.10", memory: 1024, cpus: 1, script: "scripts/control.sh" },
  { name: "web1",    ip: "192.168.56.11", memory: 1024, cpus: 1, script: "scripts/node.sh" },
  { name: "web2",    ip: "192.168.56.12", memory: 1024, cpus: 1, script: "scripts/node.sh" },
  { name: "db",      ip: "192.168.56.13", memory: 1024, cpus: 1, script: "scripts/node.sh" },
]

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"
  config.vm.box_check_update = false

  NODES.each do |n|
    config.vm.define n[:name] do |node|
      node.vm.hostname = n[:name]
      node.vm.network "private_network", ip: n[:ip]

      # Ansible ігнорує ansible.cfg у каталозі з правами 777,
      # тому на control монтуємо спільну папку з нормальними правами.
      if n[:name] == "control"
        node.vm.synced_folder ".", "/vagrant", mount_options: ["dmode=755", "fmode=644"]
      end

      node.vm.provider "virtualbox" do |vb|
        vb.name   = "devops-lab-#{n[:name]}"
        vb.memory = n[:memory]
        vb.cpus   = n[:cpus]
        vb.linked_clone = true   # економить місце на диску
      end

      node.vm.provision "shell", path: "scripts/hosts.sh"
      node.vm.provision "shell", path: n[:script]
    end
  end
end
