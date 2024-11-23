## Usage

### Activate NixOS Configuration
```bash
$ nix run .#activate
```

### Activate Home Manager
```bash
$ nix run .#activate $USER@$HOST
```

### Terraform

```bash
$ nix run .#terraform -- apply
$ nixos-anywhere --flake .#bravo debian@bravo
```

## Machine List

| Machine Name | Description                            |
|--------------|----------------------------------------|
| bravo        | proxmox.nix server(imcomplete)         |
| hotel        | Proxmox VE server                      |
| juliet       | NixOS server in Proxmox VE server      |
| kilo         | NixOS desktop                          |
| mbp          | MacBook Pro                            |
