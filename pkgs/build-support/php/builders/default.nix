{ callPackage, callPackages, ... }:
{
  v1 = {
    buildComposerProject = callPackage ./v1/build-composer-project.nix { };
    mkComposerRepository = callPackage ./v1/build-composer-repository.nix { };
    composerHooks = callPackages ./v1/hooks { };
  };

  v2 = {
    buildComposerProject = callPackage ./v2/build-composer-project.nix { };
    mkComposerRepository = callPackage ./v2/build-composer-repository.nix { };
    composerHooks = callPackages ./v2/hooks { };
  };
}
