{...}: {
  flake = {
    templates.rust = {
      path = ./rust;
      description = "Rust development environment";
    };
  };
}
