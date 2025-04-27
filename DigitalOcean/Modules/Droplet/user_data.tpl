#cloud-config
ssh_pwauth: false
users:
- name: splunk
gecos: Splunk User
groups: users,admin,wheel
sudo: ALL=(ALL) NOPASSWD:ALL
shell: /bin/bash
home: /opt/splunk
lock_passwd: true
runcmd:

%{ if tailscale_auth_key != null }

    - echo "install tailscale"
    - curl -fsSL https://tailscale.com/install.sh | sh
    - sed -i '/^ExecStopPost=/ s|--cleanup|logout --cleanup|' /usr/lib/systemd/system/tailscaled.service
    - systemctl daemon-reload
    - ['sh', '-c', "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf && echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf && sudo sysctl -p /etc/sysctl.d/99-tailscale.conf" ]
    - tailscale up --ssh --accept-routes --authkey=${tailscale_auth_key}
    - tailscaled -state=mem
%{ endif }

    - echo "install splunk"
    - export PATH=$PATH:/usr/bin
    - setenforce 0
    - yum install wget -y
    - umount /mnt/${server_name}-volume-1/
    - mkdir -p /opt/splunk
    - mount -o discard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_${server_name}-volume-1 /opt/splunk/
    - echo '/dev/disk/by-id/scsi-0DO_Volume_${server_name}-volume-1 /opt/splunk ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab
    - wget -O splunk-9.4.1-e3bdab203ac8-linux-amd64.tgz 'https://download.splunk.com/products/splunk/releases/9.4.1/linux/splunk-9.4.1-e3bdab203ac8-linux-amd64.tgz'
    - echo "about to run tar xzvf splunk-9.4.1-e3bdab203ac8-linux-amd64.tgz -C /opt/"
    - tar xzvf splunk-9.4.1-e3bdab203ac8-linux-amd64.tgz -C /opt/
    - |
cat <<EOF > /etc/polkit-1/rules.d/10-Splunkd.rules
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.systemd1.manage-units" &&
        action.lookup("unit") == "Splunkd.service" &&
        subject.user == "splunk")
    {
        return polkit.Result.YES;
    }
});
EOF
    - chmod 644 /etc/polkit-1/rules.d/10-Splunkd.rules
    - chown root:root /etc/polkit-1/rules.d/10-Splunkd.rules
    - echo "about to run /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${splunk_admin_password}"
    - /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${splunk_admin_password}
    - systemctl stop Splunkd
    - /opt/splunk/bin/splunk enable boot-start --answer-yes -systemd-managed 1 -user splunk
    - /opt/splunk/bin/splunk start