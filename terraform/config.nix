{
  config,
  lib,
  pkgs,
  ...
}: let
  endpoint = "https://hotel.lan:8006/";
  vm_id = 300;
  ipv4_address = "172.16.1.2";
  node_name = "hotel";
in {
  variable = {
    api_token.type = "string";
  };

  terraform.required_providers = {
    proxmox = {
      source = "bpg/proxmox";
      version = "0.60.0";
    };
  };

  provider.proxmox = {
    inherit endpoint;
    api_token = lib.tfRef "var.api_token";
    insecure = true;
    ssh = {
      agent = true;
      username = "root";
    };
  };

  resource.proxmox_virtual_environment_download_file.release_20240507_debian_12_bookworm_qcow2_img = {
    content_type = "iso";
    datastore_id = "local";
    file_name = "debian-12-generic-amd64-20240507-1740.img";
    node_name = "hotel";
    url = "https://cdimage.debian.org/images/cloud/bookworm/20240507-1740/debian-12-generic-amd64-20240507-1740.qcow2";
    checksum = "f7ac3fb9d45cdee99b25ce41c3a0322c0555d4f82d967b57b3167fce878bde09590515052c5193a1c6d69978c9fe1683338b4d93e070b5b3d04e99be00018f25";
    checksum_algorithm = "sha512";
  };

  resource.proxmox_virtual_environment_vm.bravo_vm = {
    inherit vm_id;
    inherit node_name;
    name = "otf-bravo";
    description = "Managed by Terraform(http://juliet.lan/gitea/infra/tf-config)";
    tags = ["terraform" "debian"];
    protection = false;

    stop_on_destroy = true;
    started = true;
    on_boot = true;

    agent = {
      enabled = true;
      trim = true;
    };

    cpu.cores = 4;
    cpu.sockets = 1;

    memory.dedicated = 8 * 1024;

    # boot disk
    disk = {
      datastore_id = "local-lvm";
      file_id = lib.tfRef "proxmox_virtual_environment_download_file.release_20240507_debian_12_bookworm_qcow2_img.id";
      interface = "virtio0";
      size = 128;
    };

    initialization = {
      ip_config = {
        ipv4 = {
          address = "${ipv4_address}/16";
          gateway = "172.16.0.1";
        };
      };

      user_account = {
        keys = [
          "ssh-ed25519 PASTE_IT"
        ];
        # username = "debian";
        # password = "debian";
      };

      vendor_data_file_id = lib.tfRef "proxmox_virtual_environment_file.cloud_vendor_config.id";
    };

    network_device.bridge = "vmbr0";
    operating_system.type = "l26";

    tpm_state.version = "v2.0";

    serial_device = {};

    tablet_device = false;
  };

  resource.proxmox_virtual_environment_file.cloud_vendor_config = {
    content_type = "snippets";
    datastore_id = "local";
    node_name = "hotel";
    source_raw = {
      file_name = "vm-${toString vm_id}-ci-vendor.yml";
      data = ''
        #cloud-config
        timezone: Asia/Tokyo
        packages:
          - qemu-guest-agent
          - wireless-regdb
        runcmd:
          - systemctl start qemu-guest-agent
      '';
    };
  };

  module.deploy = {
    source = "github.com/nix-community/nixos-anywhere/terraform/all-in-one";
    nixos_system_attr = ".#nixosConfigurations.bravo.config.system.build.toplevel";
    nixos_partitioner_attr = ".#nixosConfigurations.bravo.config.system.build.diskoScript";
    target_host = ipv4_address;
    instance_id = ipv4_address;
    install_user = "debian";

    depends_on = [
      "proxmox_virtual_environment_vm.bravo_vm"
    ];
  };
}
