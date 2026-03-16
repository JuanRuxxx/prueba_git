Vagrant.configure("2") do |config|

  config.vm.define "ubu1" do |ubu1|  
    ubu1.vm.hostname = "ubu1"
    ubu1.vm.box = "generic/ubuntu2204"
    ubu1.vm.network "private_network", ip: "192.168.50.10"
    ubu1.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 1
    end

    ubu1.vm.provision "shell", inline: <<-SHELL
      echo "vagrant:josan1234" | chpasswd
      sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      systemctl restart ssh

      useradd -m -s /bin/bash josan
      echo "josan:josan1234" | chpasswd
      usermod -aG sudo josan

      apt-get update -y
      apt-get install -y nginx

      rm -f /etc/nginx/sites-enabled/default

      printf 'server {\n    listen 80;\n    location / {\n        proxy_pass http://192.168.50.20:8000;\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n    }\n}\n' > /etc/nginx/sites-available/reverse-proxy

      ln -sf /etc/nginx/sites-available/reverse-proxy /etc/nginx/sites-enabled/
      nginx -t && systemctl enable nginx && systemctl restart nginx
    SHELL
  end

  config.vm.define "ubu2" do |ubu2|
    ubu2.vm.hostname = "ubu2"
    ubu2.vm.box = "generic/ubuntu2204"
    ubu2.vm.network "private_network", ip: "192.168.50.20"
    ubu2.vm.provider :libvirt do |v|
      v.memory = 1024
      v.cpus = 1
    end

    ubu2.vm.provision "shell", inline: <<-SHELL
      echo "vagrant:josan1234" | chpasswd
      sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      systemctl restart ssh

      useradd -m -s /bin/bash josan
      echo "josan:josan1234" | chpasswd
      usermod -aG sudo josan

      mkdir -p /var/www/html
      echo "<h1>Hola desde ubu2!</h1>" > /var/www/html/index.html

      printf '[Unit]\nDescription=Python HTTP Server\nAfter=network.target\n\n[Service]\nWorkingDirectory=/var/www/html\nExecStart=/usr/bin/python3 -m http.server 8000\nRestart=always\nUser=www-data\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/pyserver.service

      systemctl daemon-reload
      systemctl enable pyserver
      systemctl start pyserver
    SHELL
  end
end
