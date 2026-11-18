# План навчання DevOps (16 тижнів)

Розрахунок: **8–10 годин на тиждень**, приблизно 1 година в будні і 2–3 години у вихідні.
Кожен етап має чіткий критерій «готово», і все робиться в цій лабораторії.

> **Головне правило:** усе, що робите, комітьте в Git і пушите на GitHub. Через 4 місяці у вас буде портфоліо, яке можна показати на співбесіді.

---

## Етап 0. Підготовка (кілька днів)
- [ ] Встановити VirtualBox, Vagrant, Git, **VS Code** (з розширеннями: Ansible, YAML, Docker, Remote-SSH)
- [ ] Підняти лабораторію за [README.md](README.md)
- [ ] Створити репозиторій на GitHub і запушити туди `devops-lab`
- [ ] Налаштувати SSH-ключ для GitHub

**Готово, коли:** `ansible-playbook site.yml` проходить, а сторінки web1 і web2 відкриваються в браузері.

---

## Етап 1. Linux і мережі (тижні 1–3)

Це фундамент: 70% проблем у DevOps зводяться до Linux і мереж.

### Тиждень 1. Linux-основи
- Файлова система, права (`chmod`, `chown`), користувачі і групи
- Процеси: `ps`, `top`/`htop`, `kill`, `systemctl`, `journalctl`
- Пакети: `apt`, репозиторії
- **Практика на web1:**
  - [ ] Створити користувача `deploy` з sudo без пароля, увійти по SSH-ключу
  - [ ] Написати власний systemd-сервіс, який кожні 10 с пише час у лог
  - [ ] Знайти в `journalctl` логи свого сервісу

### Тиждень 2. Bash-скрипти
- Змінні, умови, цикли, функції, коди виходу, `set -euo pipefail`
- `grep`, `sed`, `awk`, `cut`, `sort`, `uniq`, конвеєри
- `cron`
- **Практика:**
  - [ ] Скрипт бекапу PostgreSQL на `db` (`pg_dump` → архів з датою), запуск через cron щоночі
  - [ ] Скрипт, що видаляє бекапи, старші за 7 днів
  - [ ] Скрипт-аналізатор логів Nginx: топ-10 IP і кількість 404

### Тиждень 3. Мережі
- Модель TCP/IP, IP-адреси, маски, порти, DNS, HTTP/HTTPS
- Інструменти: `ip`, `ss`, `ping`, `traceroute`, `dig`, `curl -v`, `tcpdump`
- Фаєрвол: `ufw`, основи `iptables`
- **Практика:**
  - [ ] Перевірити з web1, що порт 5432 на db відкритий (`nc -zv db 5432`), а з Windows закритий
  - [ ] Подивитися через `tcpdump` HTTP-запит до web1
  - [ ] Пояснити словами, що відбувається, коли ви вводите URL у браузері

**Готово, коли:** можете без Google знайти, який процес слухає порт, чому сервіс не стартує і куди він пише логи.

---

## Етап 2. Git і Ansible (тижні 4–6)

### Тиждень 4. Git
- `commit`, `branch`, `merge`, `rebase`, `revert`, `.gitignore`
- Pull Request, code review, GitFlow vs trunk-based
- **Практика:**
  - [ ] Кожна зміна в лабораторії робиться в окремій гілці через Pull Request
  - [ ] Навмисно створити конфлікт злиття і розв'язати його

### Тижні 5–6. Ansible поглиблено
- Inventory, змінні, факти, шаблони Jinja2, handlers, теги, `--check --diff`
- Ролі, Ansible Galaxy, **ansible-vault**
- **Практика:**
  - [ ] Перенести пароль БД у `ansible-vault` (`ansible-vault encrypt_string`)
  - [ ] **Балансувальник:** додати 5-ту VM `lb` (у `Vagrantfile`) з Nginx, що розподіляє трафік між web1 і web2 (`upstream`). Оновлення сторінки має показувати різні сервери
  - [ ] Роль `users`: створює список користувачів з SSH-ключами зі змінних
  - [ ] Роль `hardening`: вимкнути вхід root по SSH і вхід за паролем, встановити `fail2ban`
  - [ ] Прогнати `ansible-lint` і виправити всі зауваження

**Готово, коли:** `vagrant destroy -f && vagrant up && ansible-playbook site.yml` повністю відтворює робочу інфраструктуру з балансувальником.

---

## Етап 3. Docker (тижні 7–8)

### Тиждень 7. Основи контейнерів
- Образи, контейнери, шари, `Dockerfile`, томи, мережі
- Різниця між контейнером і VM
- **Практика на web1:**
  - [ ] Написати простий застосунок (Python Flask або Node.js), що читає дані з PostgreSQL на `db`
  - [ ] Написати для нього `Dockerfile` з **multi-stage build**, запуском не від root і мінімальним образом
  - [ ] Зменшити образ до < 150 МБ

### Тиждень 8. Docker Compose і registry
- **Практика:**
  - [ ] `docker-compose.yml`: застосунок + Redis + Nginx
  - [ ] Підняти приватний registry (`registry:2`) на control і пушити туди образи
  - [ ] Ansible-роль, яка деплоїть застосунок у Docker на web1 і web2

**Готово, коли:** застосунок працює в контейнерах на обох веб-серверах і доступний через балансувальник.

---

## Етап 4. CI/CD (тижні 9–10)

- Принципи: build → test → push → deploy, артефакти, секрети, середовища
- **Варіант А (рекомендовано для старту):** **GitHub Actions** + self-hosted runner на control
- **Варіант Б:** **Jenkins** у Docker на control (потрібно додати RAM: `memory: 2048`)
- **Практика:**
  - [ ] Пайплайн: на кожен push запускаються лінтер і тести
  - [ ] Збирати Docker-образ з тегом = короткий SHA коміту і пушити в registry
  - [ ] Автоматичний деплой на web1/web2 через Ansible після злиття в `main`
  - [ ] Rolling update: оновлювати сервери по одному, щоб сайт не падав (`serial: 1` в Ansible)
  - [ ] Відкат: деплой попередньої версії однією командою

**Готово, коли:** `git push` в `main` → через кілька хвилин нова версія на серверах без вашої участі.

---

## Етап 5. Моніторинг і логи (тижні 11–12)

- Метрики, логи, трейси; SLI/SLO; алертинг
- **Практика (додати VM `monitoring`, 2 ГБ RAM):**
  - [ ] **Prometheus** + **node_exporter** на всіх VM (через Ansible)
  - [ ] **Grafana** з дашбордом Node Exporter Full (ID 1860)
  - [ ] **postgres_exporter** і nginx-метрики
  - [ ] **Alertmanager:** алерт у Telegram, коли диск > 80% або сервер недоступний
  - [ ] **Loki + Promtail:** централізовані логи Nginx у Grafana
- **Хаос-тренування:**
  - [ ] Вимкнути web2 (`vagrant halt web2`): сайт має працювати, алерт має прийти
  - [ ] Заповнити диск на db (`fallocate -l 5G /tmp/big`): знайти проблему через дашборд
  - [ ] Зупинити PostgreSQL: знайти причину помилок застосунку через логи

**Готово, коли:** про будь-яку з цих поломок ви дізнаєтесь з алерту раніше, ніж відкриєте сайт.

---

## Етап 6. Kubernetes (тижні 13–15)

Для цього етапу краще створити окремий `Vagrantfile`: 3 VM по 2 ГБ (1 master + 2 workers).

### Тиждень 13. Перший кластер
- Архітектура: control plane, kubelet, etcd, Pod, Deployment, Service
- [ ] Підняти кластер **k3s** (найпростіший варіант)
- [ ] Задеплоїти свій застосунок: Deployment + Service + ConfigMap + Secret
- [ ] Масштабувати до 5 реплік, видалити Pod і подивитися на самовідновлення

### Тиждень 14. Поглиблено
- [ ] Ingress (Traefik у k3s), доступ до застосунку за доменом (`app.lab.local` через `hosts` у Windows)
- [ ] PersistentVolume для PostgreSQL у кластері
- [ ] Liveness/readiness probes, resource requests/limits
- [ ] Упакувати застосунок у **Helm-чарт**

### Тиждень 15. GitOps
- [ ] Встановити **Argo CD**: зміна в Git автоматично потрапляє в кластер
- [ ] Встановити kube-prometheus-stack через Helm
- [ ] (Складно, за бажанням) Підняти кластер через `kubeadm` вручну, щоб зрозуміти, що під капотом

**Готово, коли:** застосунок деплоїться в Kubernetes через Git (Argo CD) і моніториться.

---

## Етап 7. Terraform і хмара (тиждень 16+)

- Концепції IaC: state, plan/apply, модулі, remote backend
- [ ] Terraform з провайдером **Docker**: локально описати контейнери застосунку
- [ ] Зареєструватися в **AWS Free Tier** (або Oracle Cloud Always Free). Через Terraform створити VPC, EC2, Security Group і задеплоїти туди застосунок Ansible'ом
- [ ] Зберігати state в S3
- ⚠️ Обов'язково налаштуйте **Budget Alert** в AWS і робіть `terraform destroy` після кожного заняття

---

## Фінальний проєкт (для портфоліо)

Один репозиторій на GitHub, у якому:
1. **Terraform** створює інфраструктуру (хмара або локально)
2. **Ansible** її налаштовує
3. **Застосунок** у Docker збирається і деплоїться через **CI/CD**
4. Працює в **Kubernetes** з **Helm** і **Argo CD**
5. Має **моніторинг**, **алерти** і **логи**
6. Добре оформлений **README** зі схемою архітектури

---

## Ресурси

| Тема | Ресурс |
|---|---|
| Загальна карта | https://roadmap.sh/devops |
| Linux | книга *The Linux Command Line* (W. Shotts, безкоштовна), https://linuxjourney.com |
| Мережі | https://www.youtube.com/@PowerCertAnimatedVideos |
| Git | https://learngitbranching.js.org |
| Ansible | https://docs.ansible.com, книга *Ansible for DevOps* (Jeff Geerling) |
| Docker | https://docs.docker.com/get-started |
| Kubernetes | https://kubernetes.io/docs/tutorials, *Kubernetes the Hard Way* |
| Практика з задачами | https://killercoda.com, https://kodekloud.com |
| Terraform | https://developer.hashicorp.com/terraform/tutorials |

## Сертифікації (за бажанням, після плану)
1. **AWS Certified Cloud Practitioner** → **Solutions Architect Associate**
2. **CKA** (Certified Kubernetes Administrator)
3. **HashiCorp Terraform Associate**

---

## Трекер прогресу

| Етап | Тижні | Статус |
|---|---|---|
| 0. Підготовка | — | ⬜ |
| 1. Linux і мережі | 1–3 | ⬜ |
| 2. Git і Ansible | 4–6 | ⬜ |
| 3. Docker | 7–8 | ⬜ |
| 4. CI/CD | 9–10 | ⬜ |
| 5. Моніторинг | 11–12 | ⬜ |
| 6. Kubernetes | 13–15 | ⬜ |
| 7. Terraform і хмара | 16+ | ⬜ |
| Фінальний проєкт | — | ⬜ |

Позначайте: ⬜ не почато · 🟨 у процесі · ✅ готово
