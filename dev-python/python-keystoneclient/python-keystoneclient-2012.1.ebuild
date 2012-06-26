# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
PYTHON_DEPEND="2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit distutils

DESCRIPTION="OpenStack Keystone Client (command line interface and Python bindings)"
HOMEPAGE="https://launchpad.net/keystone"
SRC_URI="https://launchpad.net/keystone/essex/${PV}/+download/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-python/setuptools
		dev-python/argparse
		dev-python/coverage
		dev-python/httplib2
		dev-python/mock
		dev-python/mox
		dev-python/nose
		dev-python/pep8
		dev-python/simplejson"

#dev-python/prettytable

RDEPEND="${DEPEND}"
