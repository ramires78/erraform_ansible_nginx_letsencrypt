## Beschreibung

### Ansible. TLS (NGINX+Let's Encrypt)

#### Roles description

Rollen ermöglichen es Ihnen, aus kleineren Teilen für verschiedene Situationen und Lösungen ein Playbook für verschiedene Aufgaben zusammenzustellen. Und Sie müssen nicht von Anfang an Skripte schreiben.

#### Verwenden von Rollen auf Play Niveauen

```
---
- hosts: 
  - webservers
  become: true
  become_method: sudo
    
  roles:
    - nginx
    - vhosts

```

#### Zieldateien für Rolle

`./roles/{name of specific role}/{vars,tasks,handlers}/`

## Methoden der Erstellung

1. Bereitstellen einer virtuellen Maschine mit Hilfe von Terraform auf DO und A-Record auf Route 53 von AWS:

```shell
    $ terraform apply -var-file=terrafor.tfvars
    oder 
    $ terraform apply -var-file=variables.tf
```
2. Bereitstellen virtueller Hosts in der Cloud mit Hilfe von Ansible:

```shell
    $ ansible-playbook -i ./ansible/inventories/webservers/hosts.yml ./ansible/nginx.yml
```

## die Ergebnisse

1. Nach der Anwendung können Sie die Ergebnisse sehen

```shell
    $ cat outputs_result.csv
```
**P.S. Beachtung! Ändern Sie die Werte der Variablen in Ihre eigenen!**

## License

GNU
