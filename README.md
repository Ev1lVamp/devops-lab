# DevOps Lab на VirtualBox

Навчальна лабораторія з 4 віртуальних машин. Машини піднімає **Vagrant**, а налаштовує **Ansible**.

| VM | IP | Роль |
|---|---|---|
| `control` | 192.168.56.10 | Ansible, Git: звідси керуємо рештою машин |
| `web1` | 192.168.56.11 | Nginx + Docker |
| `web2` | 192.168.56.12 | Nginx + Docker |
| `db` | 192.168.56.13 | PostgreSQL 14 |

Сумарно лабораторія займає близько **4 ГБ RAM** і **~10 ГБ диска**.

```
devops-lab/
├── Vagrantfile            # опис VM (інфраструктура як код)
├── scripts/               # первинна провізія (shell)
│   ├── hosts.sh           #   /etc/hosts для всіх машин
│   ├── control.sh         #   Ansible + SSH-ключ
│   └── node.sh            #   довіра до ключа control
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini      # список серверів
│   ├── site.yml           # головний playbook
│   ├── group_vars/        # змінні (all, database)
│   └── roles/             # common, nginx, docker, postgres
└── LEARNING_PLAN.md       # план навчання
```

---

## 1. Що встановити на Windows

1. **VirtualBox 7.x**: https://www.virtualbox.org/wiki/Downloads
2. **Vagrant**: https://developer.hashicorp.com/vagrant/install
3. **Git for Windows**: https://git-scm.com/download/win

Перевірте, що все встановилось:
```bash
VBoxManage --version
vagrant --version
```

### ⚠️ Віртуалізація і Hyper-V
- У BIOS/UEFI має бути увімкнена віртуалізація (**Intel VT-x** / **AMD-V / SVM**). Перевірити можна в Диспетчері завдань → Продуктивність → ЦП → «Віртуалізація: Увімкнуто».
- Якщо увімкнені WSL2, Docker Desktop або Hyper-V, VirtualBox працюватиме, але повільніше (значок 🐢 у вікні VM). Для максимальної швидкості Hyper-V можна вимкнути. Команду запускайте в PowerShell від імені адміністратора, після неї потрібне перезавантаження:
  ```bash
  bcdedit /set hypervisorlaunchtype off
  ```
  Повернути: `bcdedit /set hypervisorlaunchtype auto`. Увага: без Hyper-V не працюватимуть WSL2 і Docker Desktop.

---

## 2. Запуск

Відкрийте термінал (PowerShell або Git Bash) у папці `devops-lab`:

```bash
vagrant up
```

Перший запуск триває 10–20 хвилин: Vagrant завантажить образ Ubuntu 22.04 і створить 4 VM. Машина `control` піднімається першою, бо інші беруть її SSH-ключ.

Перевірте статус:
```bash
vagrant status
```

## 3. Налаштування серверів через Ansible

Зайдіть на керуючу машину:
```bash
vagrant ssh control
```

Ви одразу опинитесь у `/vagrant/ansible`. Ця папка спільна з Windows, тож файли можна редагувати у VS Code на своєму ПК, а запускати тут.

Перевірте, що Ansible бачить усі сервери:
```bash
ansible all -m ping
```
Очікуваний результат: `web1 | SUCCESS`, `web2 | SUCCESS`, `db | SUCCESS`.

Запустіть налаштування всієї інфраструктури:
```bash
ansible-playbook site.yml
```

Запустіть цю команду **вдруге**: у підсумку має бути `changed=0`. Це і є **ідемпотентність**, одна з ключових ідей Ansible.

## 4. Перевірка

- У браузері на Windows відкрийте http://192.168.56.11 і http://192.168.56.12. Кожна сторінка показує своє ім'я сервера.
- Docker на web1:
  ```bash
  vagrant ssh web1 -c "docker run --rm hello-world"
  ```
- PostgreSQL. Підключіться з control до db (пароль `ChangeMe123`):
  ```bash
  sudo apt install -y postgresql-client
  psql -h db -U appuser -d appdb -c "select version();"
  ```

---

## Корисні команди Vagrant

| Команда | Що робить |
|---|---|
| `vagrant up` | Створити або запустити всі VM |
| `vagrant up web1` | Запустити лише одну |
| `vagrant ssh web1` | Зайти по SSH |
| `vagrant halt` | Вимкнути всі VM (дані зберігаються) |
| `vagrant reload --provision` | Перезапустити і повторити провізію |
| `vagrant snapshot save web1 clean` | Зберегти знімок стану |
| `vagrant snapshot restore web1 clean` | Повернутись до знімка |
| `vagrant destroy -f` | Видалити всі VM повністю |

**Порада:** після першого успішного `ansible-playbook site.yml` зробіть знімок кожної машини (`vagrant snapshot save <vm> base`). Тоді будь-яку зламану машину можна відновити за хвилину.

## Типові проблеми

| Симптом | Рішення |
|---|---|
| `VT-x is not available` | Увімкніть віртуалізацію в BIOS |
| `не знайдено /vagrant/.keys/control.pub` | Запустіть `vagrant up control`, потім `vagrant up` |
| `\r: command not found` у скриптах | Git перетворив рядки на CRLF. Файл `.gitattributes` це виправляє; перевірте `git config core.autocrlf` |
| Ansible пише `world writable directory` | Перезапустіть control: `vagrant reload control` |
| `UNREACHABLE` в `ansible all -m ping` | На проблемній VM виконайте `vagrant provision <vm>` |
| Конфлікт IP 192.168.56.x | VirtualBox → Файл → Інструменти → Менеджер мережі хоста |

## Далі

Відкрийте [LEARNING_PLAN.md](LEARNING_PLAN.md). Там покроковий план на 16 тижнів із завданнями для цієї лабораторії.
