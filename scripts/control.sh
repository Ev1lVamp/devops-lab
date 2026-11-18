#!/usr/bin/env bash
# Провізія машини control: Ansible, Git і SSH-ключ для доступу до інших VM.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo ">>> Встановлюю Ansible і Git"
apt-get update -qq
apt-get install -y -qq software-properties-common git tree
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install -y -qq ansible

echo ">>> Генерую SSH-ключ для користувача vagrant"
sudo -u vagrant bash -c 'test -f ~/.ssh/id_ed25519 || ssh-keygen -t ed25519 -N "" -q -f ~/.ssh/id_ed25519'

# Публічний ключ кладемо у спільну папку: звідти його заберуть web1, web2, db.
mkdir -p /vagrant/.keys
cp /home/vagrant/.ssh/id_ed25519.pub /vagrant/.keys/control.pub

# Після `vagrant ssh control` одразу опиняємось у папці з Ansible.
grep -q 'cd /vagrant/ansible' /home/vagrant/.bashrc || echo 'cd /vagrant/ansible' >> /home/vagrant/.bashrc

echo ">>> control готовий: $(ansible --version | head -n1)"
