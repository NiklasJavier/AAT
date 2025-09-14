# **AAT (Ansible Automation Tools)**

---

**clonen**
```yaml
rm -rf "/opt/AAT" &&
git clone https://github.com/NiklasJavier/AAT.git /opt/AAT
cd /opt
```
```yaml
echo "alias aat='bash /opt/AAT/scripts/tools/auto_update_repo.sh && cd /opt/AAT/scripts/'" >> ~/.bashrc && 
source ~/.bashrc
```

## **Einleitung und Zielsetzung**

### **1.1 Hintergrund**
In modernen IT-Umgebungen müssen komplexe Systeme effizient bereitgestellt, konfiguriert und verwaltet werden. Automatisierung ist der Schlüssel, um Skalierbarkeit, Konsistenz und Zuverlässigkeit sicherzustellen. Ansible ist ein leistungsstarkes Open-Source-Automatisierungstool, das diese Anforderungen erfüllt. Es ermöglicht die zentrale Verwaltung von Infrastruktur, Anwendungen und Netzwerken über deklarative YAML-basierte Playbooks.

---

### **1.2 Zielsetzung**
Das Ziel ist der Aufbau einer hochdynamischen und flexiblen Ansible-Architektur, die sich für vielfältige Anwendungsfälle eignet, darunter:

1. **Infrastrukturautomatisierung**:
   - Installation, Konfiguration und Verwaltung von Servern (on-premise, Cloud, Hybrid).
2. **Applikationsbereitstellung**:
   - Deployment von Anwendungen und Services.
3. **Netzwerkmanagement**:
   - Verwaltung und Konfiguration von Netzwerkgeräten.
4. **Sicherheitsrichtlinien**:
   - Durchsetzung und Automatisierung von Compliance-Anforderungen.

Das Konzept ermöglicht es Unternehmen, Ansible in einer modularen, skalierbaren und wiederverwendbaren Struktur zu nutzen, die dynamisch an verschiedene Umgebungen angepasst werden kann.

---

## **Anforderungen**

### **2.1 Funktionale Anforderungen**
1. **Zentrale Verwaltung**:
   - Alle Automatisierungsaufgaben werden zentral gesteuert und orchestriert.
2. **Modularisierung**:
   - Playbooks, Rollen und Aufgaben werden modular aufgebaut, um Wiederverwendbarkeit zu gewährleisten.
3. **Dynamik und Flexibilität**:
   - Nutzung von Variablen, Templates und dynamischen Inventaren zur Anpassung an unterschiedliche Umgebungen.
4. **Plattformunabhängigkeit**:
   - Unterstützung für heterogene Systeme (Linux, Windows, Netzwerkgeräte, Cloud-Plattformen).

### **2.2 Nicht-funktionale Anforderungen**
1. **Skalierbarkeit**:
   - Unterstützung von großen Infrastrukturen mit tausenden von Hosts.
2. **Sicherheit**:
   - Verschlüsselung sensibler Daten (z. B. Passwörter) mit Ansible Vault.
3. **Performance**:
   - Optimierung der Playbooks für parallele Ausführung und minimale Ausführungszeit.
4. **Wartbarkeit**:
   - Klare Strukturierung von Rollen, Playbooks und Inventaren.

---

## **Architektur und Struktur**

Ansible wird in einem hierarchischen und modularen Ansatz implementiert. Die Struktur ermöglicht die Wiederverwendung von Code und die Anpassung an verschiedene Umgebungen.

### **3.1 Verzeichnisstruktur**

```plaintext
ansible/
├── ansible.cfg                  # Globale Konfiguration
├── inventory/
│   ├── dev/                     # Entwicklungsumgebung
│   │   └── hosts.yaml           # Dynamisches Inventory für Dev
│   ├── staging/                 # Staging-Umgebung
│   │   └── hosts.yaml           # Dynamisches Inventory für Staging
│   └── production/              # Produktionsumgebung
│       └── hosts.yaml           # Dynamisches Inventory für Produktion
├── playbooks/
│   ├── site.yml                 # Haupt-Playbook für das gesamte Setup
│   ├── setup-server.yml         # Playbook: Server-Bereitstellung
│   ├── deploy-app.yml           # Playbook: Anwendungsauslieferung
│   └── configure-network.yml    # Playbook: Netzwerkgeräte konfigurieren
├── roles/
│   ├── common/                  # Rolle: Allgemeine Konfiguration
│   │   ├── tasks/               # Aufgaben (YAML-Dateien)
│   │   ├── templates/           # Jinja2-Templates
│   │   └── vars/                # Standardvariablen
│   ├── webserver/               # Rolle: Webserver-Konfiguration
│   └── database/                # Rolle: Datenbank-Setup
├── group_vars/
│   ├── all.yml                  # Variablen für alle Hosts
│   ├── webservers.yml           # Variablen für Webserver-Gruppe
│   └── databases.yml            # Variablen für Datenbank-Gruppe
├── host_vars/
│   ├── host1.yml                # Host-spezifische Variablen
│   └── host2.yml                # Host-spezifische Variablen
├── files/                       # Statische Dateien
│   └── ssl-cert.pem             # Beispiel: SSL-Zertifikat
└── vault/                       # Ansible Vault für verschlüsselte Daten
    └── secrets.yml              # Verschlüsselte Geheimnisse
```

---

### **3.2 Ansible-Konfigurationsdatei (`ansible.cfg`)**

Die zentrale Konfigurationsdatei legt globale Einstellungen für Ansible fest.

```ini
[defaults]
inventory = inventory/production/hosts.yaml
remote_user = ansible
ask_pass = false
private_key_file = ~/.ssh/id_rsa
host_key_checking = false
timeout = 30
stdout_callback = yaml

[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false

[ssh_connection]
pipelining = true
control_path = ~/.ansible/cp/%h-%p-%r
```

---

## **Dynamische Komponenten**

### **4.1 Dynamisches Inventory**
Ein dynamisches Inventory ermöglicht die flexible Definition von Hosts und Gruppen. Es kann auf Skripten, APIs oder Dateien basieren.

**Beispiel: `inventory/production/hosts.yaml`**

```yaml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
          ansible_host: 192.168.1.10
          ansible_user: ubuntu
    databases:
      hosts:
        db1.example.com:
          ansible_host: 192.168.1.20
          ansible_user: postgres
```

---

### **4.2 Playbooks**
Playbooks sind YAML-Dateien, die die Aufgaben und Schritte für die Automatisierung definieren.

**Beispiel: `playbooks/site.yml`**

```yaml
- name: Setup und Deployment
  hosts: all
  roles:
    - common
    - webserver
    - database
```

**Beispiel: `playbooks/setup-server.yml`**

```yaml
- name: Setup eines Servers
  hosts: webservers
  tasks:
    - name: Update Paket-Manager
      apt:
        update_cache: yes

    - name: Installiere NGINX
      apt:
        name: nginx
        state: present
```

---

### **4.3 Rollen**
Rollen strukturieren Aufgaben und Dateien in logischen Einheiten.

**Beispiel: Rolle `webserver`**

- `roles/webserver/tasks/main.yml`
```yaml
- name: Installiere NGINX
  apt:
    name: nginx
    state: present

- name: Kopiere NGINX-Konfiguration
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify:
    - Restart NGINX
```

- `roles/webserver/templates/nginx.conf.j2`
```jinja2
server {
    listen 80;
    server_name {{ inventory_hostname }};
    root /var/www/{{ inventory_hostname }};
}
```

---

### **Sicherheitsmanagement**

#### **5.1 Ansible Vault**
Ansible Vault wird verwendet, um sensible Daten wie Passwörter und API-Schlüssel zu verschlüsseln.

**Verschlüsselte Datei erstellen:**
```bash
ansible-vault create vault/secrets.yml
```

**Datei entschlüsseln:**
```bash
ansible-vault decrypt vault/secrets.yml
```

**Beispiel `vault/secrets.yml`**
```yaml
db_password: super_secure_password
api_key: "12345-abcdef-67890"
```

---

## **Best Practices**

1. **Modularisierung**:
   - Trenne Rollen und Playbooks für bessere Wartbarkeit und Wiederverwendbarkeit.

2. **Variablenmanagement**:
   - Nutze `group_vars` und `host_vars`, um spezifische Konfigurationen zu definieren.

3. **Idempotenz**:
   - Stelle sicher, dass alle Aufgaben idempotent sind (wiederholbar ohne Seiteneffekte).

4. **Dynamisches Inventory**:
   - Verwende dynamische Inventare, um Ressourcen in Cloud-Umgebungen (z. B. AWS, Azure) automatisch zu verwalten.

5. **Logging und Debugging**:
   - Aktiviere erweiterte Logs mit `-vvv` für detaillierte Ausgaben:
     ```bash
     ansible-playbook -i inventory/production/hosts.yaml playbooks/site.yml -vvv
     ```

6. **Versionskontrolle**:
   - Nutze Git, um Änderungen nachzuverfolgen:
     ```bash
     git init
     git add .
     git commit -m "Initial Ansible Setup"
     ```

7. **Testumgebung**:
   - Führe Playbooks zuerst in einer Testumgebung aus:
     ```bash
     ansible-playbook -i inventory/dev/hosts.yaml playbooks/site.yml --check
     ```