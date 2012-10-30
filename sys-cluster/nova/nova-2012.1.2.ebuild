# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit eutils distutils systemd

DESCRIPTION="OpenStack: Nova"
HOMEPAGE="https://launchpad.net/nova"
SRC_URI="http://launchpad.net/nova/essex/${PV}/+download/nova-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc controller +python_targets_python2_7"

		#dev-python/nosexcover
		#dev-python/wsgiref
DEPEND="dev-python/setuptools
		dev-python/python-gflags[python_targets_python2_7]
		dev-python/lockfile
		dev-python/netaddr
		dev-python/eventlet
		~dev-python/sqlalchemy-0.7.4
		dev-python/pylint
		dev-python/mox
		dev-python/pep8
		dev-python/cheetah
		dev-python/lxml
		dev-python/python-daemon
		dev-python/suds
		dev-python/paramiko
		dev-python/carrot
		doc? ( dev-python/sphinx )
		dev-python/feedparser
		app-emulation/libvirt"

RDEPEND="${DEPEND}
		 dev-python/m2crypto
		 dev-python/boto
		 dev-python/iso8601
		 dev-python/kombu
		 dev-python/prettytable
		 dev-python/mysql-python
		 dev-python/python-novaclient
		 >=sys-fs/glance-${PV}
		 net-firewall/iptables
		 net-misc/bridge-utils
		 controller? ( net-misc/rabbitmq-server )"
		 #dev-python/nova-adminclient

pkg_setup() {
	python_pkg_setup

	enewgroup nova
	enewuser nova -1 -1 -1 nova libvirt
}

src_install() {
	distutils_src_install

	# config dirs
	diropts -m 0750
	dodir /etc/nova
	fowners root:nova /etc/nova

	local CONFIG_FILES="
		api-paste.ini
		logging_sample.conf
		nova.conf.sample
		policy.json
	"

	insinto /etc/nova
	for filename in ${CONFIG_FILES}; do
		doins etc/nova/${filename}
		fperms 0640 /etc/nova/${filename}
		fowners root:nova /etc/nova/${filename}
	done

	# runtime dirs
	diropts -m 0700
	dodir /var/{lib,run,lock,log}/nova
	keepdir /var/{lib,run,lock,log}/nova
	fowners nova:nova /var/{lib,run,lock,log}/nova

	dodir /var/lib/nova/instances
	fowners nova:nova /var/lib/nova/instances

	dodir /var/lib/nova/instances/_base
	fowners nova:nova /var/lib/nova/instances/_base

	# OpenRC SysV files
	newconfd "${FILESDIR}/nova.confd" nova
	newinitd "${FILESDIR}/nova.initd" nova

	for function in api cert compute consoleauth network objectstore scheduler volume xvpvncproxy; do
		dosym /etc/init.d/nova /etc/init.d/nova-${function}
	done

	# sudo nova-rootwrap
	dodir /etc/sudoers.d
	insinto /etc/sudoers.d
	doins "${FILESDIR}/nova_sudoers"
	fperms 0440 /etc/sudoers.d/nova_sudoers
	fowners root.root /etc/sudoers.d/nova_sudoers

	# systemd files

	# common
	systemd_dotmpfilesd "${FILESDIR}/tmpfiles.d/nova.conf" # nova-common

	# nova-controller
	systemd_dounit "${FILESDIR}/systemd/nova-api.service"
	systemd_dounit "${FILESDIR}/systemd/nova-scheduler.service"
	systemd_dounit "${FILESDIR}/systemd/nova-cert.service"
	systemd_dounit "${FILESDIR}/systemd/nova-consoleauth.service"
	#systemd_dounit "${FILESDIR}/systemd/nova-xpvncproxy.service"
	#systemd_dounit "${FILESDIR}/systemd/nova-novncproxy.service"
	systemd_dounit "${FILESDIR}/systemd/nova-objectstore.service"

	# nova-volume
	systemd_dounit "${FILESDIR}/systemd/nova-volume.service"

	# nova-network
	systemd_dounit "${FILESDIR}/systemd/nova-network.service"

	# compute
	systemd_dounit "${FILESDIR}/systemd/nova-compute.service"
}
