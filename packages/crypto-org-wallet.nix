{ lib, fetchurl, makeDesktopItem, appimageTools, imagemagick }:

let
  pname = "chain-desktop-wallet";
  version = "0.2.2";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/crypto-com/${pname}/releases/download/v${version}/${name}-x86_64.AppImage";
    sha256 = "0zv1f17qy1gslv5d0mj9pyqfljm1l2513964ld4dijgf5wqqxwys";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in appimageTools.wrapType2 rec {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
    ${imagemagick}/bin/convert ${appimageContents}/${pname}.png -resize 512x512 ${pname}_512.png
    install -m 444 -D ${pname}_512.png $out/share/icons/hicolor/512x512/apps/${pname}.png
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun --no-sandbox %U' "Exec=$out/bin/${pname}"
  '';

  meta = with lib; {
    description = "Crypto.org Chain desktop wallet (Beta)";
    homepage = "https://github.com/crypto-com/chain-desktop-wallet";
    license = licenses.asl20;
    maintainers = with maintainers; [ th0rgal ];
    platforms = [ "x86_64-linux" ];
  };
}