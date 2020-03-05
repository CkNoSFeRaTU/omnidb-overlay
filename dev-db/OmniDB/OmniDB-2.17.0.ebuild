# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python3_{6..8} )
POSTGRES_COMPAT=( 9.{4..6} {10..12} )
EPYTHON="python3"

inherit eutils systemd postgres-multi python-single-r1

DESCRIPTION="Web tool for database management"
HOMEPAGE="https://omnidb.org/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/OmniDB/OmniDB"
else
	SRC_URI="https://github.com/OmniDB/OmniDB/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE="mssql mysql postgres server plugin"
REQUIRED_USE="
	plugin? ( postgres )
	|| ( server plugin )
"

PATCHES="${FILESDIR}/${P}-server-maxtries-reuse.patch
	${FILESDIR}/${P}-plugin-no-override.patch"

RDEPEND="${PYTHON_DEVS}
	>=dev-python/django-2.1.11
	>=dev-python/cherrypy-18.1.0-r1
	>=www-servers/tornado-5.1
	>=dev-python/click-7.0-r1
	>=dev-python/python-sqlparse-0.3.0
	>=dev-python/scrypt-0.8.13-r2
	>=dev-python/pyaes-1.6.1-r1
	>=dev-python/openpyxl-2.5.14
	>=dev-python/RestrictedPython-4.0
	>=dev-python/sshtunnel-0.1.4-r2
	>=dev-python/pexpect-4.6.0
	mssql? ( >=dev-python/pymssql-2.1.3 )
	mysql? ( >=dev-python/pymysql-0.9.3 )
	postgres? (
		>=dev-db/postgresql-10:*
		>=dev-python/psycopg-2.8.3
		>=dev-python/pgspecial-1.11.9
	)
	dev-lang/python[sqlite]
"

pkg_setup() {
	OMNIDB_NAME="omnidb"
	OMNIDB_HOME="/var/lib/${OMNIDB_NAME}"

	postgres-multi_pkg_setup
	python-single-r1_pkg_setup

	if use server; then
		ebegin "Creating ${OMNIDB_NAME} user and group"
		enewgroup ${OMNIDB_NAME}
		enewuser ${OMNIDB_NAME} -1 -1 "${OMNIDB_HOME}" ${OMNIDB_NAME}
		eend $?
	fi
}

src_prepare() {
	rm -r "${S}/OmniDB/deploy" || die
	rm "${S}/OmniDB/omnidb.db" || die
	find "${S}/OmniDB" -name '*.spec' -delete || die

	default

	postgres-multi_src_prepare
}

src_compile() {
	if use plugin; then
		postgres-multi_foreach emake -C omnidb_plugin
	fi

	if use server; then
		python_optimize "${S}/OmniDB"
	fi
}

src_install() {
	if use plugin; then
		postgres-multi_foreach emake DESTDIR="${D}" -C omnidb_plugin install
	fi

	if use server; then
		insinto /opt/${PN}
		doins -r OmniDB

		# install init script and config
		newinitd "${FILESDIR}"/omnidb-server.initd "omnidb-server"
		newconfd "${FILESDIR}"/omnidb-server.confd "omnidb-server"
	fi
}

pkg_postinst() {
	if use server; then
		elog
		elog "Installed into /opt/OmniDB/"
		elog
	fi
}
