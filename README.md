# StatusSync

StatusSync is a modern, cloud-native status page application designed to communicate real-time service health, active incidents, and maintenance windows to your users. 

Built on a stateless Django backend and optimized for Kubernetes, StatusSync is designed for high availability and resilient infrastructure scaling. It relies on PostgreSQL for persistent data storage and utilizes an NGINX Ingress Controller for efficient Layer 7 routing.

## ✨ Features
* **Real-Time Incident Management:** Easily publish and update active incidents or scheduled maintenance.
* **Stateless Architecture:** Fully containerized and ready to be replicated across multiple Kubernetes pods without data inconsistency.
* **Cloud-Native Ready:** Pre-configured for deployment via standard Kubernetes manifests.
* **Zero-Trust Configuration:** Built to accept all sensitive configurations via environment variables and Kubernetes Secrets.

---

## ⚙️ Configuration

StatusSync requires specific environment variables to be passed to the container at runtime. Never hardcode these values in your deployment files.

### Required Environment Variables
| Variable | Description | Example |
| :--- | :--- | :--- |
| `SECRET_KEY` | Django cryptographic key for session hashing. | `your-random-secret-key-string` |
| `DEBUG` | Enable or disable debug mode (Must be `False` in production). | `False` |
| `ALLOWED_HOSTS` | Comma-separated list of valid domains for the application. | `status.yourdomain.com,localhost` |
| `DB_NAME` | Name of the PostgreSQL database. | `status_db` |
| `DB_USER` | PostgreSQL username. | `db_admin` |
| `DB_PASSWORD` | PostgreSQL password. | `super_secret_password` |
| `DB_HOST` | Hostname or IP of the PostgreSQL server. | `db.yourdomain.internal` |
| `DB_PORT` | PostgreSQL connection port. | `5432` |

### How to Pass Variables to the Container
In a Kubernetes environment, you should define these variables in a `Secret` file (for passwords/keys) and reference them in your `deployment.yaml` using the `env` or `envFrom` specifications. 

*Example snippet for your deployment.yaml:*
```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: statussync-secrets
        key: db-password
```

---

## 🚀 Deployment

StatusSync is distributed as a Docker image and is intended to be deployed to a Kubernetes cluster. All necessary template files are located in the `kubernetes/` directory of this repository.

### Prerequisites
* A running Kubernetes cluster (v1.24+)
* `kubectl` configured to communicate with your cluster
* A reachable PostgreSQL instance (v13+)

### 1. Getting Started
First, clone the repository and navigate to the infrastructure directory:
```bash
git clone https://github.com/your-org/statussync.git
cd statussync/kubernetes
```
*(Note: Ensure you have populated `secrets.yaml` with your actual base64-encoded environment variables before proceeding).*

### 2. Database Migrations
Before handling traffic, the database schema must be initialized. You can run migrations directly via a temporary pod:
```bash
kubectl run statussync-migrate --image=your-registry/statussync:latest --restart=Never --env="DATABASE_URL=postgres://user:pass@host:5432/db" --command -- python manage.py migrate
```

### 3. Deploying the Application
Apply your Kubernetes manifests to create the Deployment, Service, and Ingress routing:
```bash
kubectl apply -f secrets.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

### 4. Creating the Superuser
To access the admin panel, create an initial admin account by executing a command inside one of your running pods:
```bash
# Find your pod name
kubectl get pods

# Create the superuser
kubectl exec -it <YOUR_STATUSSYNC_POD_NAME> -- python manage.py createsuperuser
```

---

## 💻 How to Use It

Once deployed and configured, StatusSync operates in two main views:

### The Public Dashboard (`/`)
This is the front-facing page your users will see. It automatically displays the current operational status of all your tracked services, along with a historical timeline of recent incidents and their resolution status.

### The Admin Panel (`/admin`)
Navigate to the `/admin` path of your deployed domain to access the management backend. Log in with the superuser credentials created during deployment. 

From here, you can:
1. **Manage Services:** Add, rename, or categorize the internal systems or APIs you want to display on the public page.
2. **Update Statuses:** Change the health indicator of a service (e.g., *Operational*, *Degraded Performance*, *Partial Outage*, *Major Outage*).
3. **Post Incidents:** Create detailed incident reports. As you investigate and resolve the issue, you can post timestamped updates that immediately reflect on the public dashboard.
