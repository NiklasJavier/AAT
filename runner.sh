#!/usr/bin/env bash

# runner.sh für AAT (Ansible Automation Tools)
# Dieses Skript stellt einen einfachen Einstiegspunkt für häufige Ansible-Aktionen bereit.
# Unterstützte Subcommands:
#   list                 - zeigt verfügbare Playbooks, Rollen und Inventories an
#   run <playbook> [...] - führt ein Playbook mit optionalen zusätzlichen Parametern aus
#   help                 - zeigt diese Hilfe an

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_DIR="$REPO_ROOT/playbooks"
ROLE_DIR="$REPO_ROOT/roles"
INVENTORY_DIR="$REPO_ROOT/inventory"
ANSIBLE_CFG="$REPO_ROOT/ansible.cfg"
DEFAULT_VAULT_ID_FILE="$REPO_ROOT/vault/secrets.yml"
DEFAULT_VAULT_PASSWORD_FILE="$REPO_ROOT/vault/.vault_pass"

usage() {
  cat <<USAGE
Usage: ./runner.sh <subcommand> [options]

Subcommands:
  list                        Listet Playbooks, Rollen und Inventories auf
  run <playbook> [ansible-args]  Führt ein Playbook aus (z.B. run site --check)
  help                        Zeigt diese Hilfe an

Environment-Variablen:
  ANSIBLE_INVENTORY          Pfad zum Inventory (überschreibt Defaults)
  ANSIBLE_VAULT_ID           Wert für --vault-id (z.B. default@prompt)
  ANSIBLE_VAULT_PASSWORD_FILE Pfad zu einer Vault-Passwort-Datei
USAGE
}

ensure_ansible_available() {
  if ! command -v ansible-playbook >/dev/null 2>&1; then
    echo "Error: ansible-playbook wurde nicht gefunden. Bitte Ansible installieren." >&2
    exit 1
  fi
}

resolve_inventory() {
  if [[ -n "${ANSIBLE_INVENTORY:-}" ]]; then
    echo "$ANSIBLE_INVENTORY"
    return
  fi

  if [[ -f "$ANSIBLE_CFG" ]]; then
    local cfg_inventory
    cfg_inventory=$(awk -F'=' '
      /^[[:space:]]*inventory[[:space:]]*=/{
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2);
        print $2;
        exit;
      }
    ' "$ANSIBLE_CFG")
    if [[ -n "$cfg_inventory" ]]; then
      if [[ "$cfg_inventory" == /* ]]; then
        echo "$cfg_inventory"
      else
        echo "$REPO_ROOT/$cfg_inventory"
      fi
      return
    fi
  fi

  if [[ -f "$INVENTORY_DIR/production/hosts.yaml" ]]; then
    echo "$INVENTORY_DIR/production/hosts.yaml"
    return
  fi

  local first_inventory
  first_inventory=$(find "$INVENTORY_DIR" -type f -name 'hosts.y*ml' 2>/dev/null | head -n 1 || true)
  if [[ -n "$first_inventory" ]]; then
    echo "$first_inventory"
    return
  fi

  echo ""  # Kein Inventory gefunden
}

append_vault_arguments() {
  local -n _cmd_ref=$1

  if [[ -n "${ANSIBLE_VAULT_ID:-}" ]]; then
    _cmd_ref+=("--vault-id" "$ANSIBLE_VAULT_ID")
  elif [[ -n "${ANSIBLE_VAULT_PASSWORD_FILE:-}" ]]; then
    _cmd_ref+=("--vault-password-file" "$ANSIBLE_VAULT_PASSWORD_FILE")
  fi
}

list_items() {
  echo "Verfügbare Playbooks:"
  if [[ -d "$PLAYBOOK_DIR" ]]; then
    find "$PLAYBOOK_DIR" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) -print | sort || true
  else
    echo "  (Verzeichnis $PLAYBOOK_DIR nicht gefunden)"
  fi

  echo
  echo "Verfügbare Rollen:"
  local roles_listed=false
  if [[ -d "$ROLE_DIR" ]]; then
    find "$ROLE_DIR" -maxdepth 1 -mindepth 1 -type d | sort || true
    roles_listed=true
  fi
  local alt_roles_dir
  for alt_roles_dir in "$REPO_ROOT/ansible/roles" "$REPO_ROOT/playbooks/roles"; do
    if [[ -d "$alt_roles_dir" ]]; then
      find "$alt_roles_dir" -maxdepth 1 -mindepth 1 -type d | sort || true
      roles_listed=true
    fi
  done
  if [[ "$roles_listed" = false ]]; then
    echo "  (Keine Rollenverzeichnisse gefunden)"
  fi

  echo
  echo "Verfügbare Inventories:"
  if [[ -d "$INVENTORY_DIR" ]]; then
    find "$INVENTORY_DIR" -type f -name 'hosts.y*ml' | sort || true
  else
    echo "  (Verzeichnis $INVENTORY_DIR nicht gefunden)"
  fi
}

run_playbook() {
  if [[ $# -lt 1 ]]; then
    echo "Error: Playbook-Name erforderlich, z.B. 'run site'" >&2
    exit 1
  fi

  local playbook_input="$1"
  shift || true
  local playbook_file=""

  if [[ -f "$playbook_input" ]]; then
    playbook_file="$playbook_input"
  else
    case "$playbook_input" in
      *.yml|*.yaml)
        if [[ -f "$PLAYBOOK_DIR/$playbook_input" ]]; then
          playbook_file="$PLAYBOOK_DIR/$playbook_input"
        fi
        ;;
      *)
        if [[ -f "$PLAYBOOK_DIR/${playbook_input}.yml" ]]; then
          playbook_file="$PLAYBOOK_DIR/${playbook_input}.yml"
        elif [[ -f "$PLAYBOOK_DIR/${playbook_input}.yaml" ]]; then
          playbook_file="$PLAYBOOK_DIR/${playbook_input}.yaml"
        fi
        ;;
    esac
  fi

  if [[ -z "$playbook_file" ]]; then
    echo "Error: Playbook '$playbook_input' wurde nicht gefunden." >&2
    exit 1
  fi

  local inventory
  inventory=$(resolve_inventory)
  if [[ -z "$inventory" ]]; then
    echo "Error: Kein Inventory gefunden. Bitte ANSIBLE_INVENTORY setzen oder ansible.cfg konfigurieren." >&2
    exit 1
  fi

  ensure_ansible_available

  local cmd=("ansible-playbook" "-i" "$inventory" "$playbook_file")
  append_vault_arguments cmd
  if [[ $# -gt 0 ]]; then
    cmd+=("$@")
  fi

  echo "Executing: ${cmd[*]}"
  "${cmd[@]}"
}

main() {
  local subcommand="${1:-help}"
  if [[ $# -gt 0 ]]; then
    shift
  fi

  case "$subcommand" in
    list)
      list_items
      ;;
    run)
      run_playbook "$@"
      ;;
    help|--help|-h)
      usage
      ;;
    *)
      echo "Unbekannter Subcommand: $subcommand" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
