# Übersicht der Ansible-Artefakte

Diese Dokumentation bietet einen kompakten Überblick über alle in diesem Repository vorhandenen Playbooks, Inventories, Variablendateien und unterstützenden Ressourcen. Sie dient als Einstiegspunkt für neue Nutzerinnen und Nutzer und als Nachschlagewerk für die tägliche Arbeit.

## Playbooks (`playbooks/`)

| Playbook | Zweck | Ziel-Hosts | Bemerkungen |
| --- | --- | --- | --- |
| `site.yml` | Orchestriert das vollständige Setup, indem zentrale Rollen für alle Hosts ausgeführt werden. | `all` | Typischer Einstiegspunkt für Deployments oder vollständige System-Setups. |
| `setup-server.yml` | Führt serverseitige Grundkonfigurationen aus (z. B. Paket-Updates, Installation grundlegender Services). | `webservers` | Ideal für die Erstbereitstellung oder das Aktualisieren von Webserver-Knoten. |
| `deploy-app.yml` | Verantwortlich für das Ausrollen von Anwendungen oder Services. | anwendungsspezifische Hostgruppen | Ergänzend zu `setup-server.yml`, um nach der Basis-Konfiguration Anwendungen bereitzustellen. |
| `configure-network.yml` | Kümmert sich um die Konfiguration von Netzwerkgeräten oder netzwerkspezifische Einstellungen. | `network` oder spezialisierte Netzwerk-Gruppen | Kann mit individuellen Variablen pro Standort oder Gerät kombiniert werden. |

> **Hinweis:** Die YAML-Dateien dienen als Struktur-Blueprints. Passen Sie Aufgaben, Rollen und Variablen entsprechend Ihren Anforderungen an.

## Inventories (`inventory/`)

| Umgebung | Datei/Verzeichnis | Beschreibung |
| --- | --- | --- |
| Entwicklung | `inventory/dev/hosts.yaml` | Enthält Hosts und Gruppen für Test- und Entwicklungszwecke. |
| Staging | `inventory/staging/hosts.yaml` | Spiegelt die produktive Umgebung für Vorab-Tests wider. |
| Produktion | `inventory/production/hosts.yaml` | Definiert die produktiven Systeme. Standard-Inventar gemäß `ansible.cfg`. |

## Variablen

### Gruppenspezifische Variablen (`group_vars/`)

| Datei | Zweck |
| --- | --- |
| `all.yml` | Globale Variablen, die auf alle Hosts angewendet werden sollen. |
| `webservers.yml` | Einstellungen, die nur für die Webserver-Gruppe gelten (z. B. Ports, Service-Namen). |
| `databases.yml` | Datenbankspezifische Konfigurationsparameter (z. B. Benutzer, Passwörter, Pfade). |

### Host-spezifische Variablen (`host_vars/`)

| Datei | Zweck |
| --- | --- |
| `host1.yml` | Individuelle Parameter für den Host `host1` (z. B. dedizierte IPs, Ressourcen-Limits). |
| `host2.yml` | Individuelle Parameter für den Host `host2`. |

## Weitere Ressourcen

| Pfad | Inhalt | Verwendung |
| --- | --- | --- |
| `ansible.cfg` | Globale Ansible-Konfiguration (z. B. Standard-Inventar, SSH-Optionen). | Legt Verhaltensweisen und Default-Werte für alle Playbook-Ausführungen fest. |
| `files/` | Statische Dateien wie Zertifikate oder Konfigurationsschnipsel. | Werden über Module wie `copy` oder `template` verteilt. |
| `scripts/` | Hilfsskripte, z. B. zur Automatisierung von Repo-Updates (`tools/auto_update_repo.sh`). | Unterstützen wiederkehrende Wartungsaufgaben. |
| `data/` | Platz für zusätzliche Datenquellen, Templates oder Dateien, die von Playbooks benötigt werden. | Kann zur Ablage von Seed-Daten oder Konfigurationsvorlagen genutzt werden. |
| `vault/` | Verschlüsselte Secrets mittels Ansible Vault. | Für Passwörter, API-Keys oder andere sensible Informationen. |
| `runner.sh` | Wrapper-Skript zur Ausführung wiederkehrender Ansible-Befehle. | Erleichtert den standardisierten Aufruf von Playbooks. |

## Nächste Schritte

1. **Variablen befüllen:** Ergänzen Sie `group_vars/` und `host_vars/` mit den notwendigen Werten für Ihre Infrastruktur.
2. **Rollen und Aufgaben hinzufügen:** Hinterlegen Sie konkrete Aufgaben in den Playbooks und strukturieren Sie Rollen nach Best Practices.
3. **Secrets schützen:** Nutzen Sie `ansible-vault`, um vertrauliche Informationen zu verschlüsseln (`ansible-vault create vault/secrets.yml`).
4. **Tests durchführen:** Verwenden Sie die Entwicklungs- oder Staging-Inventories, um Änderungen gefahrlos zu testen (`ansible-playbook -i inventory/dev/hosts.yaml playbooks/site.yml --check`).

Diese Übersicht wird fortlaufend aktualisiert, sobald neue Playbooks, Rollen oder Artefakte hinzukommen. Beiträge und Erweiterungen sind jederzeit willkommen.
