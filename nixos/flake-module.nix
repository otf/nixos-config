{
  inputs,
  self,
  ...
}: {
  flake = {
    # Available through 'nixos-rebuild --flake .#host'
    nixosConfigurations =
      inputs.nixpkgs.lib.genAttrs
      ["bravo" "juliet" "kilo"]
      (host:
        self.nixos-unified.lib.mkLinuxSystem {
          home-manager = true;
        } {
          nixos-unified.sshTarget = "otf@${host}";
          nixpkgs.hostPlatform = "x86_64-linux";
          nixpkgs.config.allowUnfreePredicate = pkg:
            builtins.elem (inputs.nixpkgs.lib.getName pkg) [
              # for VirtualBox
              "Oracle_VM_VirtualBox_Extension_Pack"

              # for ollama
              "cuda-merged"
              "cuda_cuobjdump"
              "cuda_gdb"
              "cuda_nvcc"
              "cuda_nvdisasm"
              "cuda_nvprune"
              "cuda_cccl"
              "cuda_cudart"
              "cuda_cupti"
              "cuda_cuxxfilt"
              "cuda_nvml_dev"
              "cuda_nvrtc"
              "cuda_nvtx"
              "cuda_profiler_api"
              "cuda_sanitizer_api"
              "libcublas"
              "libcufft"
              "libcurand"
              "libcusolver"
              "libnvjitlink"
              "libcusparse"
              "libnpp"
              "nvidia-x11"

              "vscode"
            ];
          imports = [
            ./${host}/configuration.nix
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.default
            inputs.proxmox-nixos.nixosModules.proxmox-ve
          ];
        });
  };
}
