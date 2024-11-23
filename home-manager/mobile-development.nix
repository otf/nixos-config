{
  config,
  lib,
  pkgs,
  flake,
  ...
}: {
  imports = [
    flake.inputs.android-nixpkgs.hmModule
  ];

  config = lib.mkIf (pkgs.stdenv.isLinux
    || pkgs.stdenv.isDarwin) {
    # android-sdk.enable = true;
    # android-sdk.packages = sdk:
    #   with sdk; [
    #     # 参考: https://github.com/tauri-apps/wry/blob/dev/MOBILE.md
    #     # build-tools-30-0-3
    #     build-tools-33-0-1
    #     build-tools-34-0-0
    #     build-tools-35-0-0
    #     cmdline-tools-latest
    #     emulator
    #     platform-tools
    #     platforms-android-34
    #     # platforms-android-33
    #     # platforms-android-24

    #     # sources-android-34
    #     system-images-android-34-google-apis-x86-64
    #     # system-images-android-35-google-apis-x86-64
    #     system-images-android-34-google-apis-playstore-x86-64

    #     ndk-25-0-8775105
    #     # ndk-23-1-7779620
    #     # ndk-25-2-9519653
    #     # ndk-25-1-8937393
    #     # ndk-28-0-12433566
    #     # ndk-26-3-11579264

    #     cmake-3-22-1
    #   ];
    # android-sdk.path = "${config.home.homeDirectory}/.android/sdk";
    # home.packages = with pkgs; [
    #   android-studio
    #   # jdk
    #   jdk17
    #   clang_18
    # ];
  };
}
