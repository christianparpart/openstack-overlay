# EBUILD STATUS

- OK sys-auth/keystone
- OK dev-python/python-keystoneclient

- OK sys-fs/glance
- ?? dev-python/glance-client

- -- sys-cluster/nova-common
  - /etc/nova/nova.conf
  - /var/run/nova
  - /usr/lib/systemd/tmpfiles.d/nova.conf
- -- sys-cluster/nova-network
- -- sys-cluster/nova-scheduler
- -- sys-cluster/nova-volume
- -- sys-cluster/nova-consoleauth
- -- sys-cluster/nova-{novnc,xvpvnc}proxy
- -- sys-cluster/nova-compute
- -- sys-cluster/nova-client

- -- www-apps/horizon

- -- dev-python/python-nova
- -- dev-python/amqplib

# later

- -- sys-misc/quantum
- -- sys-fs/swift

# TODO

- verify ebuilds via truely very clean stage3 install
- keystone/glance/nova: add logrotate USE-flag and install logrotate files
