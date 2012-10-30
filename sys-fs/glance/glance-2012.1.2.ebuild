# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
PYTHON_DEPENDS="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit eutils distutils systemd

PV_BASE="2012.1"

DESCRIPTION="OpenStack: Glance, Virtual Machine Image Store."
HOMEPAGE="https://launchpad.net/glance"
SRC_URI="http://launchpad.net/${PN}/essex/${PV}/+download/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/setuptools"
RDEPEND="${DEPEND}
		 dev-python/webob
		 dev-python/httplib2
		 dev-python/routes
		 dev-python/paste
		 dev-python/pastedeploy
		 dev-python/pyxattr
		 dev-python/iso8601
		 dev-python/mysql-python
		 dev-python/pycrypto
		 dev-python/sqlalchemy
		 dev-python/sqlalchemy-migrate
		 dev-python/kombu
		 "

pkg_setup() {
	python_pkg_setup

	enewgroup glance
	enewuser glance -1 -1 -1 glance
}

src_install() {
	distutils_src_install

	# config files
	diropts -m 0750
	dodir /etc/glance
	fowners root:glance /etc/glance

	local CONFIG_FILES="
		glance-api-paste.ini
		glance-api.conf
		glance-cache-paste.ini
		glance-cache.conf
		glance-registry-paste.ini
		glance-registry.conf
		glance-scrubber-paste.ini
		glance-scrubber.conf
		policy.json
	"

	insinto /etc/glance
	for filename in ${CONFIG_FILES}; do
		doins ${FILESDIR}/${PV_BASE}/${filename}
		fperms 0640 /etc/glance/${filename}
		fowners root:glance /etc/glance/${filename}
	done

	# runtime dirs
	diropts -m 0700
	dodir /var/{lib,run,lock,log}/glance
	keepdir /var/{lib,run,lock,log}/glance
	fowners glance:glance /var/{lib,run,lock,log}/glance

	dodir /var/lib/glance/{images,scrubber}
	keepdir /var/lib/glance/{images,scrubber}
	fowners glance:glance /var/lib/glance/{images,scrubber}

	# OpenRC SysV files
	newconfd "${FILESDIR}/glance.confd" glance
	newinitd "${FILESDIR}/glance.initd" glance

	for function in api registry scrubber; do
		dosym /etc/init.d/glance /etc/init.d/glance-${function}
	done

	# systemd files
	systemd_dounit "${FILESDIR}/systemd/glance-api.service"
	systemd_dounit "${FILESDIR}/systemd/glance-registry.service"
	systemd_dounit "${FILESDIR}/systemd/glance-scrubber.service"
	systemd_dotmpfilesd "${FILESDIR}/tmpfiles.d/glance.conf"
}
