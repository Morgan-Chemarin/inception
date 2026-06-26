*This project has been created as part of the 42 curriculum by mchemari*

# Inception

## 1. Description
This project is a System Administration exercise designed to deepen knowledge of virtualization and infrastructure deployment using Docker. The main goal is to build a complete, secure, and isolated multi-container web hosting infrastructure from scratch using Docker Compose. 

The entire stack runs inside a dedicated Virtual Machine and orchestrates three core services, each living in its own dedicated, non-prebuilt container:
* **NGINX**: Serving as the only entry point via port 443 with TLSv1.2/TLSv1.3 protocols.
* **WordPress**: Configured alongside `php-fpm` to handle website assets and logic.
* **MariaDB**: Providing the relational database management system for WordPress.

---

## 2. Project Description & Technical Choices

### Docker Architecture
Every microservice runs inside an isolated container environment based on the old stable Debian Linux distribution. Rather than pulling ready-made images from public hubs, each image is built locally using custom `Dockerfiles` called directly by Docker Compose. Security is enforced by ensuring no credentials or passwords are hardcoded inside the code, utilizing environment variables and secure localized file inputs.

### Architectural Comparisons

#### Virtual Machines (VMs) vs Docker Containers
* **Virtual Machines**: Virtualize the **hardware**. Every VM runs a complete and heavy Guest Operating System (including its own kernel and device drivers) bundled with the application. This makes them resource-heavy and slow to boot.

* **Docker Containers**: Virtualize the **Operating System**. A container embeds *only* the application layer and its direct dependencies. It does not contain an OS kernel; instead, it directly shares the host machine's kernel, making it extremely lightweight and fast to boot.

#### Secrets vs Environment Variables
* **Environment Variables**: Excellent for storing non-sensitive, configuration-specific global parameters (e.g., domain names, application ports). However, they are highly insecure for sensitive data because their values are unencrypted and visible via `docker inspect` or system process listings.
* **Secrets**: Designed specifically for highly sensitive data like passwords or API keys. Docker mounts secrets as temporary, in-memory files directly into the container filesystem (`/run/secrets/`). They never persist on disk inside the container image, preventing accidental leaks via logs or source code tracking.

#### Docker Network vs Host Network
* **Host Network**: Removes network isolation between the container and the Docker host machine. The container shares the host's IP and port space directly (e.g., a service running on port 80 in the container binds directly to port 80 of the host). This compromises security and risks port collision.
* **Docker Network**: Creates an isolated, private virtual bridge network for the containers. Containers can communicate with one another securely using internal DNS resolution (container names), while completely blocking external access to unexposed ports (like keeping MariaDB's port 3306 private).

#### Docker Volumes vs Bind Mounts
* **Bind Mounts**: Directly map a raw file or folder path from the host machine into a container directory. This creates a hard dependency on the host's specific filesystem structure, bypassing Docker’s managed storage layer.
* **Docker Volumes**: Persistent storage mechanisms completely managed by the Docker daemon. They are decoupled from the host directory structure by default. In this project, we leverage **Docker Named Volumes** combined with local driver options (`driver_opts: o: bind`) to fulfill the dual constraint of keeping data managed by Docker while physically storing it inside `/home/login/data`.

---

## 3. Instructions

### Installation & Compilation
1. Set up your domain routing locally by appending this entry to your host's `/etc/hosts` file:
  ```text
   127.0.0.1    mchemari.42.fr
```

2. Allocate your sensitive credentials locally by creating a `secrets/` directory at the root and populating the required `.txt` password files.
3. Provide general variables in the `srcs/.env` file.

### Execution Commands

* **Build and Start the Infrastructure:**
```bash
make
```

* **Stop Running Services Safely:**
```bash
make down
```

* **Down Containers:**
```bash
make clean
```

* **Wipe Containers, Networks, and All Local Data Volumes:**
```bash
make clean
```

---

## 4. Resources & AI Usage

### References

* [Official Docker and Docker Compose Documentation](https://docs.docker.com/compose/).
* [Official Docker Image Nginx](https://hub.docker.com/_/nginx).
* [Github WP-CLI](https://github.com/wp-cli/wp-cli)

### AI Usage Declaration

In compliance with the 42 AI Guidelines, Artificial Intelligence (AI) was utilized during the development of this project to optimize productivity and enforce engineering best practices:

* **Tasks Assisted**: AI was used to draft initial boilerplate templates for documentation, validate the syntactic structure of complex local volume driver options inside the `docker-compose.yml` file, and troubleshoot network resolution between PHP-FPM and MariaDB.
* **Validation Checkpoint**: Every AI-generated concept, command suggestion, and configuration fragment was thoroughly analyzed, manually tested, and peer-reviewed to guarantee absolute understanding and operational integrity.
