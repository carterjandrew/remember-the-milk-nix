{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeShellWrapper,
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
  libGL,
  libsecret,
  libxkbcommon,
  libgbm,
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
  systemd,
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
    makeShellWrapper
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
    libxkbcommon
    libgbm
    nspr
    nss
    pango
    (lib.getLib stdenv.cc.cc)
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxshmfence
  ];

  # These libraries are loaded dynamically by the Electron executable and
  # therefore do not appear in its ELF dependencies for autoPatchelf to find.
  runtimeDependencies = map lib.getLib [
    libsecret
    systemd
  ];

  # Electron's bundled EGL library loads libGL dynamically. Unlike
  # runtimeDependencies, appendRunpaths also applies to shared libraries.
  appendRunpaths = [ "${lib.getLib libGL}/lib" ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt" "$out/bin" "$out/share"
    cp -r opt/RememberTheMilk "$out/opt/"
    cp -r usr/share/applications usr/share/icons usr/share/pixmaps "$out/share/"

    install -Dm644 -t "$out/share/licenses/${finalAttrs.pname}/" \
      opt/RememberTheMilk/LICENSE.electron.txt \
      opt/RememberTheMilk/LICENSES.chromium.html

    # The upstream package's 0x0 icon is a dangling symlink to a directory
    # that is not included in the Debian archive. Install the bundled 512x512
    # icon in the standard hicolor location instead.
    rm -rf "$out/share/icons/hicolor/0x0"
    install -Dm644 usr/share/pixmaps/rememberthemilk.png \
      "$out/share/icons/hicolor/512x512/apps/rememberthemilk.png"

    substituteInPlace "$out/share/applications/rememberthemilk.desktop" \
      --replace-fail "/opt/RememberTheMilk/rememberthemilk" "rememberthemilk"

    makeShellWrapper "$out/opt/RememberTheMilk/rememberthemilk" "$out/bin/rememberthemilk" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}

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
