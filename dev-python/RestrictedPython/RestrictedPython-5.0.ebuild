# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7} )

inherit distutils-r1

DESCRIPTION="RestrictedPython is a defined subset of the Python language which allows to provide a program input into a trusted environment"
HOMEPAGE="https://github.com/zopefoundation/RestrictedPython"
SRC_URI="https://github.com/zopefoundation/RestrictedPython/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~mips ~x86"

RDEPEND="${PYTHON_DEPS}"
