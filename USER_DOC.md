# USER_DOC.md - User & Administrator Documentation

This documentation explains how to operate, access, and verify the Inception infrastructure services.

---

## 1. Services Provided by the Stack
The infrastructure deploys a secure web hosting stack containing the following dedicated services:
* **NGINX**: The single entry point of the infrastructure, handling secure HTTPS traffic (Port 443) using TLSv1.2 or TLSv1.3 protocols.
* **WordPress + PHP-FPM**: The content management system (CMS) website powered by a fast PHP processing daemon.
* **MariaDB**: The relational database management system storing all WordPress data.

---

## 2. How to Start and Stop the Project
All infrastructure life-cycle operations are handled from the root directory using the `Makefile`.

* **To build and start all services:**
```bash
make
```

* **To stop all running services cleanly:**
```bash
make down
```

* **To stop services:**
```bash
make clean
```

* **To stop services and completely purge all data (including volumes):**
```bash
make fclean
```

---

## 3. How to Access the Website and Administration Panel

### Prerequisites

Before accessing the services, ensure your local host machine maps the domain name to the local loopback IP address. Add the following line to your `/etc/hosts` file:

```text
127.0.0.1    mchemari.42.fr
```

### Access URLs

* **Public Website:** Open your browser and navigate to:
`https://mchemari.42.fr`
* **WordPress Administration Dashboard:** Access the backend panel at:
`https://mchemari.42.fr/wp-admin`

*Note: Since the SSL/TLS certificate is self-signed, your browser will display a security warning. You can safely bypass it (click "Advanced" -> "Proceed to mchemari.42.fr").*

---

## 4. How to Locate and Manage Credentials

For strict security compliance, no passwords or credentials are hardcoded into the source code or versioned on Git.

* **Environment Variables:** General non-confidential settings are stored in the local file:
`srcs/.env`
* **Secret Variables (Passwords):** Secure credentials (database root password, database user password, WordPress admin and user password) are managed locally inside the root-level folder:
`secrets/`

To modify credentials, stop the infrastructure (`make down`), edit the text files inside the `secrets/` directory or the variables in `srcs/.env`, and then restart the containers (`make`).

---

## 5. How to Check that Services are Running Correctly

You can verify the health and status of the stack using standard Docker commands:

* **Check Container Status:**
```bash
docker ps
```

*All three containers (`nginx`, `wordpress`, `mariadb`) must display a status of `Up`.*
* **Check Network Connectivity:**
```bash
docker network ls
```

*You should see the dedicated network (`inception_net`) ensuring isolated communication between containers.*
* **Check Storage Volume Persistence:**
```bash
docker volume ls
```

*You should see the named volumes (`mariadb_data` and `wordpress_data`) responsible for persisting database records and website files.*
