# $Header: /net/yquem/devel/caml/repository/bigbro/spec,v 1.6 2004/05/05 09:44:46 fpottier Exp $

Summary: www link checker
Name: bigbro
Version: 2.0.4
Release: 1
Copyright: Public domain
Group: Networking/Utilities
URL: http://pauillac.inria.fr/~fpottier/
Packager: Francois Pottier <Francois.Pottier@inria.fr>
Source: bigbro-2.0.4.tar.gz
Prefix: /usr

%description
Big Brother (friends call him bigbro) is a fast & robust tool to
check links between HTML documents, online or offline.

%prep
%setup

%build

%install
install -m 755 -o 0 -g 0 bigbro /usr/bin/bigbro
install -m 644 -o 0 -g 0 bigbro.1 /usr/man/man1/bigbro.1

%files
%doc README doc.ps doc.pdf html

/usr/bin/bigbro
/usr/man/man1/bigbro.1

%define __check_files %{nil}

