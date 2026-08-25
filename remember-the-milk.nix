{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libsecret,
  libxkbcommon,
  mesa,
  nspr,
  nss,
  pango,
  xdg-utils,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
  libxshmfence,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "remember-the-milk";
  version = "1.3.11";

  src = fetchurl {
    url = "https://www.rememberthemilk.com/download/linux/debian/pool/main/r/rememberthemilk/rememberthemilk_${finalAttrs.version}_amd64.deb";
    hash = "sha256-31xx1csNPwXWS2VNIWbKqgtDXtzJdBLUWA6VZ5nxHds=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libsecret
    libxkbcommon
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxshmfence
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --extract "$src" .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt" "$out/bin" "$out/share"
    cp -r opt/RememberTheMilk "$out/opt/"
    cp -r usr/share/applications usr/share/icons usr/share/pixmaps "$out/share/"

    # The upstream package's 0x0 icon is a dangling symlink to a directory
    # that is not included in the Debian archive. Install the bundled 512x512
    # icon in the standard hicolor location instead.
    rm -rf "$out/share/icons/hicolor/0x0"
    install -Dm644 usr/share/pixmaps/rememberthemilk.png \
      "$out/share/icons/hicolor/512x512/apps/rememberthemilk.png"

    substituteInPlace "$out/share/applications/rememberthemilk.desktop" \
      --replace-fail "/opt/RememberTheMilk/rememberthemilk" "rememberthemilk"

    makeWrapper "$out/opt/RememberTheMilk/rememberthemilk" "$out/bin/rememberthemilk" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libsecret ]}

    runHook postInstall
  '';

  meta = {
    description = "Smart to-do app for busy people";
    homepage = "https://www.rememberthemilk.com";
    license = lib.licenses.unfree;
    mainProgram = "rememberthemilk";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
