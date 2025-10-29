#cloud-config
package_update: true
package_upgrade: true

packages:
  - docker.io
  - docker-compose
  - fail2ban
  - chrony
  - ufw
  - curl
  - wget
  - git

users:
  - name: deploy
    groups: docker
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${ssh_public_key}

runcmd:
  - usermod -aG docker deploy
  - ufw allow OpenSSH
  - ufw allow 80/tcp
  - ufw allow 443/tcp  
  - ufw allow 3000/tcp
  - ufw allow 9090/tcp
  - ufw allow 9100/tcp
  - ufw --force enable
  - systemctl enable fail2ban
  - systemctl start fail2ban
  - systemctl enable chrony
  - systemctl start chrony
  - systemctl enable docker
  - systemctl start docker

final_message: "RobinCore Server setup completed"
