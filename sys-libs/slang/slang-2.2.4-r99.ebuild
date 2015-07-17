# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/slang-2.2.4-r1.ebuild,v 1.12 2015/03/03 10:08:14 dlan Exp $

EAPI=5
inherit eutils multilib-minimal

DESCRIPTION="A multi-platform programmer's library designed to allow a developer to create robust software"
HOMEPAGE="http://www.jedsoft.org/slang/"
SRC_URI="mirror://slang/v${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm ~mips ppc x86"
IUSE="cjk pcre png readline static-libs zlib"

# ncurses for ncurses5-config to get terminfo directory
RDEPEND="sys-libs/ncurses
	pcre? ( >=dev-libs/libpcre-8.33-r1[${MULTILIB_USEDEP}] )
	png? ( >=media-libs/libpng-1.6.10:0[${MULTILIB_USEDEP}] )
	cjk? ( >=dev-libs/oniguruma-5.9.5[${MULTILIB_USEDEP}] )
	readline? ( >=sys-libs/readline-6.2_p5-r1:0[${MULTILIB_USEDEP}] )
	zlib? ( >=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}] )
	abi_x86_32? (
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
		!<=app-emulation/emul-linux-x86-baselibs-20140406-r1
	)"
DEPEND="${RDEPEND}"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.2.3-slsh-libs.patch
	epatch "${FILESDIR}"/${PN}-2.2.4-memset.patch
	epatch "${FILESDIR}"/${PN}-2.2.4-rename-posix_close.patch

	# avoid linking to -ltermcap race with some systems
	sed -i -e '/^TERMCAP=/s:=.*:=:' configure || die
	# we use the GNU linker also on Solaris
	sed -i -e 's/-G -fPIC/-shared -fPIC/g' \
		-e 's/-Wl,-h,/-Wl,-soname,/g' configure || die

	# slang does not support configuration from another dir
	multilib_copy_sources
}

multilib_src_configure() {
	local myconf=slang
	use readline && myconf=gnu

	econf \
		--with-readline=${myconf} \
		$(use_with pcre) \
		$(use_with cjk onig) \
		$(use_with png) \
		$(use_with zlib z)
}

multilib_src_compile() {
	emake elf $(use static-libs && echo static)

	pushd slsh >/dev/null
	emake slsh
	popd
}

multilib_src_install() {
	emake DESTDIR="${D}" install $(use static-libs && echo install-static)
}

multilib_src_install_all() {
	rm -rf "${ED}"/usr/share/doc/{slang,slsh}
	dodoc NEWS README *.txt doc/{,internal,text}/*.txt
	dohtml doc/slangdoc.html slsh/doc/html/*.html
}