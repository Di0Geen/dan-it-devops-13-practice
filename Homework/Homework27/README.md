# Homework 27 — Моніторинг Docker-контейнерів

У домашній роботі за допомогою Docker Compose розгорнуто стек моніторингу:

- Prometheus — збір та зберігання метрик;
- Grafana — візуалізація метрик;
- Alertmanager — обробка та надсилання алертів;
- Node Exporter — системні метрики CPU, RAM, дисків і мережі;
- cAdvisor — метрики Docker-контейнерів.

## Структура проєкту

```text
Homework27/
├── Screens/
│   ├── alert-target-down.png
│   ├── cadvisor-dashboard.png
│   ├── node-exporter-dashboard.png
│   ├── prometheus-alert-firing_1.png
│   ├── prometheus-alert-firing_2.png
│   ├── prometheus-container-memory.png
│   ├── prometheus-cpu-metric.png
│   └── prometheus-targets.png
└── Src/
    ├── alertmanager/
    │   ├── alertmanager.yml
    │   └── secrets/
    │       └── telegram_bot_token.example
    ├── grafana/
    │   ├── adapt_dashboard.py
    │   ├── dashboards/
    │   │   ├── cadvisor-community.json
    │   │   └── cadvisor-macos.json
    │   └── provisioning/
    │       └── datasources/
    │           └── prometheus.yml
    ├── prometheus/
    │   ├── alerts.yml
    │   └── prometheus.yml
    ├── .gitignore
    ├── docker-compose.yml
    └── README.md
```

## Запуск

Перед запуском потрібно створити локальний файл із токеном Telegram-бота:

```bash
cp alertmanager/secrets/telegram_bot_token.example \
  alertmanager/secrets/telegram_bot_token
```

У файл `telegram_bot_token` потрібно вставити токен, отриманий від BotFather. Файл із реальним токеном доданий до `.gitignore` і не завантажується до GitHub.

Запуск усіх контейнерів:

```bash
docker compose up -d
```

Перевірка стану контейнерів:

```bash
docker compose ps
```

Зупинка стеку:

```bash
docker compose down
```

## Адреси сервісів

| Сервіс | Адреса |
|---|---|
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| Alertmanager | http://localhost:9093 |
| Node Exporter | http://localhost:9100/metrics |
| cAdvisor | http://localhost:8080 |

Дані для локального входу в Grafana:

```text
Username: admin
Password: admin
```

## Моніторинг

Prometheus збирає метрики з таких targets:

- `prometheus:9090`;
- `alertmanager:9093`;
- `node-exporter:9100`;
- `cadvisor:8080`.

Node Exporter використовується для системних метрик:

- завантаженість CPU;
- використання оперативної пам’яті;
- вільне місце на файлових системах;
- мережевий трафік.

cAdvisor використовується для метрик контейнерів:

- використання CPU;
- використання пам’яті;
- кеш пам’яті;
- дискові операції;
- мережевий трафік.

На Docker Desktop для macOS cAdvisor віддає контейнери через cgroup-мітку `id`. Тому community dashboard для cAdvisor було адаптовано скриптом `grafana/adapt_dashboard.py`.

## Grafana dashboards

Підключено готові дашборди зі спільноти Grafana:

1. **Node Exporter Full** — dashboard ID `1860`.
2. **cAdvisor exporter — Docker containers Overview** — dashboard ID `21743`.

Для сумісності з Docker Desktop dashboard `21743` адаптований до мітки `id`. Готовий файл для імпорту:

```text
grafana/dashboards/cadvisor-macos.json
```

## Алерти

У файлі `prometheus/alerts.yml` налаштовано три правила:

| Алерт | Умова | Рівень |
|---|---|---|
| `LowDiskSpace` | вільного місця менше 15% | warning |
| `HighCPUUsage` | завантаженість CPU перевищує 80% | critical |
| `TargetDown` | хоча б один target недоступний | critical |

Усі алерти мають витримувати умову протягом однієї хвилини. Alertmanager надсилає повідомлення про початок проблеми та її завершення до Telegram.

Для перевірки `TargetDown` було зупинено `node-exporter`:

```bash
docker compose stop node-exporter
```

Після переходу алерту в стан `FIRING` надійшло повідомлення до Telegram.

Після повторного запуску exporter:

```bash
docker compose start node-exporter
```

Alertmanager надіслав повідомлення `RESOLVED`.

## Перевірка конфігурації

Перевірка Docker Compose:

```bash
docker compose config
```

Перевірка конфігурації Prometheus і правил алертів:

```bash
docker compose run --rm --no-deps \
  --entrypoint /bin/promtool prometheus \
  check config /etc/prometheus/prometheus.yml
```

Перевірка конфігурації Alertmanager:

```bash
docker compose run --rm --no-deps \
  --entrypoint /bin/amtool alertmanager \
  check-config /etc/alertmanager/alertmanager.yml
```

## Скріншоти

У папці `Screens` розміщено:

1. `prometheus-targets.png` — Prometheus targets у стані `UP`.
2. `prometheus-cpu-metric.png` — графік системної метрики CPU.
3. `prometheus-container-memory.png` — використання пам’яті Docker-контейнерами.
4. `node-exporter-dashboard.png` — готовий dashboard Node Exporter Full із системними метриками.
5. `cadvisor-dashboard.png` — адаптований dashboard cAdvisor із метриками контейнерів.
6. `prometheus-alert-firing_1.png` — правила `LowDiskSpace`, `HighCPUUsage` і початок алерту `TargetDown`.
7. `prometheus-alert-firing_2.png` — алерт `TargetDown` у стані `FIRING`.
8. `alert-target-down.png` — повідомлення `ALERT` і `RESOLVED` від Alertmanager у Telegram.

## Висновок

Стек моніторингу успішно збирає системні метрики та метрики Docker-контейнерів. Готові Grafana dashboards відображають CPU, оперативну пам’ять, диски, мережу та використання ресурсів контейнерами.

Налаштовані правила контролюють завантаженість CPU, кількість вільного місця та доступність Prometheus targets. Alertmanager успішно надсилає до Telegram повідомлення про недоступність targets та їх відновлення.