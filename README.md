# Learning Basics of Ansible

## 1. Objectives

### 1.1 Create basics of Ansible Playbooks and Commands

### 1.2 Understand and explain the Ansible playbooks and Commands

## 2. Architecture

<img src="./Ansible Architecture.png" width="500"> 

## 3. Docker Container Explanation

### 3.1 posgres-dockerfile

Create Posgres DB named "Employer" and user "myuser". Also run init.sql at initialization.

```docker
FROM postgres:latest

ENV POSTGRES_USER=myuser
ENV POSTGRES_DB=Employees

COPY init.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
```

### 3.2 posgres-compose

Create container with image from posgres-dockerfile named employee_db.

```docker
services:
  postgres:
    build:
      context: .
      dockerfile: posgres-dockerfile
    environment:
      - POSTGRES_USER=myuser
      - POSTGRES_DB=Employees
      - POSTGRES_PASSWORD=mypassword
    ports:
      - "5432:5432"
    volumes:
      - db-data:/var/lib/postgresql/data
    container_name: employee_db

volumes:
  db-data:
```

## 4. Ansible inventory explanation

Ansible inventory is configurable, and target machine inventory can be sourced dynamically or from cloud-based sources in different formats (YAML, INI).

In this example, I have machines danialmirxatarget1 (192.168.0.22) and danialmirxatarget2 (192.168.0.23)

```ini
[host1]
192.168.0.22 ansible_user=danialmirxatarget1 ansible_password=danialmirxa1 ansible_connection=ssh ansible_become_pass=danialmirxa1
 
[host2]
192.168.0.23 ansible_user=danialmirxatarget2 ansible_password=danialmirxa2 ansible_connection=ssh ansible_become_pass=danialmirxa2

```

1. ansible_user: username of the target machine
2. ansible_password: password of the username of the target machine
3. ansible_connection: type of connection
4. ansible_become_pass: sudo password of the target machine

## 4. Ansible Command/ Playbook explanation

### 4.1 Simple Ping Command

This command uses module ping to host2 in inventory/hosts file.

```bash
ansible -i inventory/hosts host2 -m ping
```

### 4.2 Apt Update Playbook

Update packages in all host if the host based on Debian.

```ansible
- name: Upgrade packages
  hosts: "*"
  tasks:
    - name: Update packages if OS is Debian
      become: true
      apt:
        update_cache: yes
        upgrade: yes
      when: ansible_os_family == "Debian"

```

### 4.3 Install Packages Playbook

Create a variable "packages" consist a list of packages: nginx, htop, docker, docker-compose-v2, python3, python3-pip. Then install the packages in the variable to host1.

```ansible
- name: Install packages
  hosts: host1
  become: true
  vars: 
    packages:
    - name: nginx
      required: True
    - name: htop
      required: False
    - name: docker
      required: True
    - name: docker-compose-v2
      required: True
    - name: python3
      required: True
    - name: python3-pip
      required: True
    
  tasks:
  - name: Install "{{ item.name }}" on host
    apt:
      name: "{{ item.name }}"
      state: present
    loop: "{{ packages }}"
```

### 4.3 Install Flatpak Playbook

Install Flatpak, add Flatpak repository and use Flatpak to install DBeaver to host1.

```ansible
- name: Setup Flatpak
  hosts: host1
  become: true
  tasks:
    - name: Ensure the system is updated 
      apt: 
        update_cache: yes 
    - name: Install Flatpak 
      apt: 
        name: flatpak 
        state: present 
    - name: Add the Flathub repository
      command: flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    - name: Install DBeaver
      flatpak:
        name: io.dbeaver.DBeaverCommunity
        method: system
        state: present
```

### 4.4 Enable Docker Playbook

This is equivalent to `sudo systemctl enable docker`

```ansible
- name: Enable Docker
  hosts: host1
  become: true
  tasks: 
  - name: Ensure Docker is enabled and started 
    systemd:
      name: docker 
      enabled: yes 
      state: started
```

### 4.5 Enable Docker Playbook

These are the steps done in this playbook

1. Check if docker is installed.
2. Check if docker-compose-v2 is installed.
3. Install python package "docker" and "docker-compose-v2".
4. Run `sudo chmod 666 /var/run/docker.sock` (This is not safe, but this is the only way it works for me).
5. Copy all contents in docker/ folder to tmp/ in host1.
6. Run equivalent to `docker compose -f tmp/posgres-compose.yaml up -d`.
7. Print out the stdout from the docker compose command.

```ansible
---
- name: Deploy PostgreSQL with Docker Compose
  hosts: host1
  become: true
  vars:
    directory: "~/Learning_Ansible/docker"
  tasks:
    - name: Ensure Docker is installed
      apt:
        name: docker
        state: present
      when: ansible_os_family == "Debian"

    - name: Ensure Docker Compose is installed
      apt:
        name: docker-compose-v2
        state: present
      when: ansible_os_family == "Debian"

    - name: Install Docker Python library
      pip:
        name: docker
        state: present

    - name: Install Docker-Compose Python library
      pip:
        name: docker-compose
        state: present

    - name: Give permission to docker.sock
      command: sudo chmod 666 /var/run/docker.sock

    - name: Copy Docker Compose file
      copy:
        src: "{{ directory }}/posgres-compose.yaml"
        dest: /tmp/posgres-compose.yaml

    - name: Copy Dockerfile
      copy:
        src: "{{ directory }}/posgres-dockerfile"
        dest: /tmp/posgres-dockerfile

    - name: Copy init.sql
      copy:
        src: "{{ directory }}/init.sql"
        dest: /tmp/init.sql

    - name: Run Docker Compose
      community.docker.docker_compose_v2:
        project_src: /tmp
        files:
          - /tmp/posgres-compose.yaml
        state: present
      register: docker_compose_output

    - name: Display Docker Compose output
      debug:
        var: docker_compose_output
```