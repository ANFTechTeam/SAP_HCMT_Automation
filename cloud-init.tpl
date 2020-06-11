#cloud_config

package_update: true
packages:
  - iftop
runcmd:
  - mkdir -p /hana/data
  - mkdir -p /hana/log
  - mkdir -p /hana/hcmt
  - chmod 777 /hana/data
  - chmod 777 /hana/log
  - chmod 777 /hana/hcmt
  - sudo mount -t nfs -o rw,hard,nointr,rsize=262144,wsize=262144,sec=sys,vers=4.1,tcp,bg,nconnect=8 ${data_mount_ip_address}:/hanadata /hana/data
  - sudo mount -t nfs -o rw,hard,nointr,rsize=262144,wsize=262144,sec=sys,vers=4.1,tcp,bg,nconnect=8 ${log_mount_ip_address}:/hanalog /hana/log
  - wget https://github.com/mchad1/saphana-certification/archive/master.zip -O /hana/hcmt/hcmt.zip
  - sudo unzip /hana/hcmt/hcmt.zip -d /hana/hcmt
  - sudo unzip /hana/hcmt/saphana-certification-master/hcmtsetup-50beta.exe -d /hana/hcmt
  - cp /hana/hcmt/saphana-certification-master/*.json /hana/hcmt/
  - chmod +x /hana/hcmt/hcmt
  - sysctl -p
write_files:
  - path: /etc/sysctl.conf
    content: |
      net.core.rmem_max = 16777216
      net.core.wmem_max = 16777216
      net.core.rmem_default = 16777216
      net.core.wmem_default = 16777216
      net.core.optmem_max = 16777216
      net.ipv4.tcp_rmem = 65536 16777216 16777216
      net.ipv4.tcp_wmem = 65536 16777216 16777216
      net.core.netdev_max_backlog = 300000
      net.ipv4.tcp_slow_start_after_idle=0
      net.ipv4.tcp_no_metrics_save = 1
      net.ipv4.tcp_moderate_rcvbuf = 1
      net.ipv4.tcp_window_scaling = 1
      net.ipv4.tcp_timestamps = 1
      net.ipv4.tcp_sack = 1
