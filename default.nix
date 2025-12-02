{
  stdenv
  , lib
  , fetchurl
  , writeShellApplication
  , autoPatchelfHook
  , makeWrapper
  , makeDesktopItem
  , copyDesktopItems
  , alsa-lib
  , libXext
  , libXi
  , libXrender
  , libXtst
  , libXxf86vm
  , libX11
  , xorg
  , libGL
  , gtk3
  , glib
  , openjfx21
  , jdk
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "MCreator";
  version = "2025.3.45720";

  desktopItems = [(
    makeDesktopItem {
      desktopName = "MCreator";
      name = finalAttrs.pname;
      exec = "${placeholder "out"}/bin/${finalAttrs.pname}/MCreator";
      icon = finalAttrs.pname;
      categories = [ "Development" "Game" ];
    }
  )];

  # Although build from source is encouraged on NixOS, MCreator uses Gradle build, which renders it
  # impractical to build MCreator on NixOS with the current state of documentation around Gradle on NixOS.
  # Therefore I decided to use release package for this derivation.
  # If anyone desires to hop into this matter and implement it from source rather than tar.gz you are welcome.
  src = fetchurl {
    url = "https://github.com/MCreator/MCreator/releases/download/2025.3.45720/MCreator.2025.3.Linux.64bit.tar.gz";
    sha256 = "sha256:aada93da59b631df3dc6848e5f75207a8fb44fbdcbd93734916af56349b1c834";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    ];

  buildInputs = [
    alsa-lib
    libXext
    libXi
    libXrender
    libXtst
    libX11
    libXxf86vm
    xorg.libXcursor
    xorg.libXrandr
    libGL
    gtk3
    glib
    openjfx21
    ];

  unpackPhase = ''
    runHook preUnpack

    mkdir -p ${finalAttrs.pname}
    tar -xvzf ${finalAttrs.src} -C ${finalAttrs.pname} --strip-components=1

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r ${finalAttrs.pname} $out/bin
    makeWrapper ${jdk}/bin/java $out/bin/${finalAttrs.pname}/MCreator \
      --add-flags "--add-opens=java.base/java.lang=ALL-UNNAMED" \
      --add-flags "-cp ./lib/mcreator.jar:./lib/*" \
      --add-flags "net.mcreator.Launcher" \
      --run "cd '$out/bin/MCreator'" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}"
    mkdir -p $out/share/pixmaps
    cp ${finalAttrs.pname}/icon.png $out/share/pixmaps/MCreator.png

    runHook postInstall
 '';


  meta = with lib; {
    description = "MCreator is an open-source software used to make Minecraft mods, Add-Ons, ressource packs, and data packs.";
    longDescription = "MCreator is an open-source software used to make Minecraft Java Edition mods, Minecraft Bedrock Edition Add-Ons, resource packs, and data packs using an intuitive easy-to-learn interface or with an integrated code editor. It is used worldwide by Minecraft players, aspiring mod developers, for education, online classes, and STEM workshops.";
    homepage = "https://mcreator.net/";
    downloadPage = "https://mcreator.net/download";
    changelog = "https://mcreator.net/news/120031/mcreator-20253-new-features-and-new-minecraft-version";
    #license = licenses.gpl3Only licenses.gpl3Plus;
    maintainers = with maintainers; [ DioKyrie-Git ];
    mainProgram = "MCreator";
    platforms = platforms.linux;
    sourceProvenance = with sourceTypes; [ binaryNativeCode binatyBytecode];
  };
})

# To build derivation run this command in the same folder as default.nix
# nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'

/*
    gpl3Only = {
      spdxId = "GPL-3.0-only";
      fullName = "GNU General Public License v3.0 only";
    };

    gpl3Plus = {
      spdxId = "GPL-3.0-or-later";
      fullName = "GNU General Public License v3.0 or later";
    };
*/
