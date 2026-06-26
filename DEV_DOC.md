# DEV_DOC.md - Developer & System Administrator Documentation

This technical documentation details the architecture setup, deployment commands, container management, and data persistence layers of the Inception infrastructure.

---

## 1. Environment Setup from Scratch

### Prerequisites
The infrastructure is built to run inside a dedicated Virtual Machine (VM) running either **Debian**. Ensure the following packages are installed on the host:
* `make`
* `docker.io`
* `docker-compose`

### Configuration Files & Structure
The repository layout follows strict requirements:
```text
.
├── Makefile
├── secrets/
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── nginx/
        └── wordpress/
```

### Local Setup Instructions (Ignored by Git)

To secure production credentials, environment files and text secrets are explicitly excluded via `.gitignore`. To initialize the environment locally:

1. 
**Environment Variables:** Create `srcs/.env` and define non-sensitive keys:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
```

2. 
**Secrets Allocation:** Create the `secrets/` directory at the root and fill the respective `.txt` files with passwords.

---

## 2. Build and Launch using Makefile and Docker Compose

The orchestration relies on Docker Compose and is wrapped inside a root-level `Makefile` to automate execution.

### Core Automation Commands

* **Build Images and Run Containers:**
```bash
make
```

Execute `docker compose -f srcs/docker-compose.yml up --build -d`. This ensures Dockerfiles are compiled from scratch without using forbidden pre-built public images (except bare Debian/Alpine). 

* **Stop the Infrastructure:**
```bash
make down
```

*Execute `docker compose -f srcs/docker-compose.yml down` to halt and remove containers and network structures safely.*
* **Hard Reset & Purge:**
```bash
make clean
```

*Stops infrastructure.*

```bash
make fclean
```

*Stops infrastructure and removes all local data folders mapped on the VM host (`/home/mchemari/data/`).*

---

## 3. Relevant Commands to Manage Containers & Volumes

A set of developer-focused commands to inspect, debug, and monitor the isolated microservices stack:

### Monitoring and Logs

* **Real-time logs for a specific service:**
```bash
docker compose -f srcs/docker-compose.yml logs -f <nginx|wordpress|mariadb>
```

* **Inspect internal container processes:**
```bash
docker top <nginx|wordpress|mariadb>
```

### Debugging & Interactive Shell

* **Enter a container's shell securely:**
```bash
docker exec -it <container_name> sh
```
or
```bash
make shell-<nginx|wordpress|mariadb>
```

### Volume Management & Inspection

* **List all active named volumes:**
```bash
docker volume ls
```

* **Inspect volume properties and host paths:**
```bash
docker volume inspect mariadb_data
```

### Policy Testing (Simulation of Crash)

* **Verify `on-failure` restart policy:**
To simulate a clean failure, find the host process ID (PID) and kill it forcefully from the host machine rather than inside the namespace:
```bash
PID=$(docker inspect mariadb --format='{{.State.Pid}}')
sudo kill -9 $PID
docker ps
```

---
## 4. Project Data Storage and Persistence Layer

### Volume Architecture
The subject mandates the use of **Docker Named Volumes**, strictly prohibiting inline service-level direct bind mounts (`- /path:/path`). However, data must physically sit inside `/home/login/data` on the host machine.

To fulfill both requirements, we use the local volume driver configured with mount options:

```yaml
volumes:
  mariadb_data:
    name: mariadb_data
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/mchemari/data/mariadb

  wordpress_data:
    name: wordpress_data
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/mchemari/data/wordpress
```

### Persistence Mapping
When the containers are initiated, Docker manages the mount lifecycles, saving data permanently onto the host filesystem at:
- Database Storage: `/home/mchemari/data/mariadb` maps inside MariaDB container's `/var/lib/mysql`.
- Website Assets: `/home/mchemari/data/wordpress` maps inside WordPress container's `/var/www/html`.

Executing `make down` keeps all user data fully intact in these folders, guaranteeing persistent state across restarts. Only a manual `rm -rf` or `make clean` rule will wipe the underlying files.
