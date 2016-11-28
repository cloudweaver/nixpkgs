{ stdenv, fetchurl, cmake, qt4, qmake4Hook, libupnp, gpgme, gnome3, glib, libssh, pkgconfig, protobuf, bzip2
, libXScrnSaver, speex, curl, libxml2, libxslt }:

stdenv.mkDerivation {
  name = "retroshare-0.6.1";

  src = fetchurl {
    url = "https://github.com/RetroShare/RetroShare/archive/0.6.1.tar.gz";
    sha256 = "0hpygh410za8q4flz39y59rb0f5cbrf1aakwcq7hvy1q2p3bdysg";
  };

  NIX_CFLAGS_COMPILE = [ "-I${glib.dev}/include/glib-2.0" "-I${glib.dev}/lib/glib-2.0/include" "-I${libxml2.dev}/include/libxml2" ];

  patchPhase = ''
    sed -i 's/UpnpString_get_String(es_event->PublisherUrl)/es_event->PublisherUrl/' \
      libretroshare/src/upnp/UPnPBase.cpp
    # Extensions get installed 
    sed -i "s,/usr/lib/retroshare/extensions/,$out/share/retroshare," \
      libretroshare/src/rsserver/rsinit.cc
    # For bdboot.txt
    sed -i "s,/usr/share/RetroShare,$out/share/retroshare," \
      libretroshare/src/rsserver/rsinit.cc
  '';

  buildInputs = [ speex qt4 qmake4Hook libupnp gpgme gnome3.libgnome_keyring glib libssh pkgconfig
                  protobuf bzip2 libXScrnSaver curl libxml2 libxslt ];

  sourceRoot = "RetroShare-0.6.1";

  preConfigure = ''
    qmakeFlags="$qmakeFlags DESTDIR=$out"
  '';

  postInstall = ''
    mkdir -p $out/bin
    mv $out/retroshare-nogui $out/bin
    mv $out/RetroShare $out/bin

    # plugins
    mkdir -p $out/share/retroshare
    mv $out/lib* $out/share/retroshare

    # BT DHT bootstrap
    cp libbitdht/src/bitdht/bdboot.txt $out/share/retroshare
  '';

  meta = with stdenv.lib; {
    description = "A decentralized friend-to-friend network client";
    homepage = http://retroshare.net/;
    license = licenses.gpl2Plus;
    platforms = with platforms; linux ++ darwin;
    maintainers = [ maintainers.domenkozar ];
  };
}
