# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit eutils distutils systemd

PV_BASE="2012.1"

DESCRIPTION="OpenStack Keystone"
HOMEPAGE="https://launchpad.net/keystone"
SRC_URI="https://launchpad.net/${PN}/essex/${PV}/+download/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="ldap"

DEPEND="dev-python/setuptools
		dev-python/pep8
		dev-python/lxml
		dev-python/python-daemon"

RDEPEND="${DEPEND}
		 ldap? ( dev-python/python-ldap )"

# TODO verify whether given deps are needed
#dev-python/passlib

pkg_setup() {
	python_pkg_setup

	enewgroup keystone
	enewuser keystone -1 -1 -1 keystone
}

src_install() {
	distutils_src_install

	# config files
	diropts -m 0750
	dodir /etc/keystone
	fowners root:keystone /etc/keystone
	keepdir /etc/keystone

	local CONF_FILES=" \
		/etc/keystone/keystone.conf \
		/etc/keystone/logging.conf.sample \
		/etc/keystone/policy.json \
		/etc/keystone/default_catalog.templates \
		/etc/keystone/logging.conf \
	"

	insinto /etc/keystone
	doins etc/*
	doins "${FILESDIR}/${PV_BASE}/logging.conf"
	fperms 0640 ${CONF_FILES}
	fowners root:keystone ${CONF_FILES}

	sed -i -e \
		"s,^#\\(bind_host =\\).*,\1 0.0.0.0," \
		"${ED}/etc/keystone/keystone.conf" || die

	sed -i -e \
		"s,^#\\(log_config =\\).*,\1 /etc/keystone/logging.conf," \
		"${ED}/etc/keystone/keystone.conf" || die

	sed -i -e \
		"s,^\\(connection =\\).*,\1 sqlite:////var/lib/keystone/keystone.db," \
		"${ED}/etc/keystone/keystone.conf" || die

	sed -i -e \
		"s,^\\(template_file =\\).*,\1 /etc/keystone/default_catalog.templates," \
		"${ED}/etc/keystone/keystone.conf" || die

	# run & log dirs
	diropts -m 0700
	dodir /var/{run,log}/keystone
	fowners keystone:keystone /var/{run,log}/keystone
	keepdir /var/{run,log}/keystone

	# OpenRC SysV files
	newconfd "${FILESDIR}/openrc/keystone.confd" keystone
	newinitd "${FILESDIR}/openrc/keystone.initd" keystone

	# systemd files
	systemd_dounit "${FILESDIR}/systemd/keystone.service"
	systemd_dotmpfilesd "${FILESDIR}/tmpfiles.d/keystone.conf"
}

pkg_postinst() {
	echo
	einfo "Make sure you *carefully* read the documentation:"
	einfo "    http://keystone.openstack.org/configuration.html"
	echo
}
