{
  stdenvNoCC,
  lib,
  php,
}:

let
  buildComposerProjectOverride =
    finalAttrs: previousAttrs:

    let
      phpDrv = finalAttrs.php or php;
      composer = finalAttrs.composer or phpDrv.packages.composer;
    in
    {
      composerLock = previousAttrs.composerLock or null;
      composerNoDev = previousAttrs.composerNoDev or true;
      composerNoPlugins = previousAttrs.composerNoPlugins or true;
      composerNoScripts = previousAttrs.composerNoScripts or true;
      composerStrictValidation = previousAttrs.composerStrictValidation or true;

      nativeBuildInputs = (previousAttrs.nativeBuildInputs or [ ]) ++ [
        composer
        phpDrv
        phpDrv.composerHooks2.composerInstallHook
      ];

      buildInputs = (previousAttrs.buildInputs or [ ]) ++ [ phpDrv ];

      patches = previousAttrs.patches or [ ];
      strictDeps = previousAttrs.strictDeps or true;

      # Should we keep these empty phases?
      configurePhase =
        previousAttrs.configurePhase or ''
          runHook preConfigure

          runHook postConfigure
        '';

      buildPhase =
        previousAttrs.buildPhase or ''
          runHook preBuild

          runHook postBuild
        '';

      doCheck = previousAttrs.doCheck or true;
      checkPhase =
        previousAttrs.checkPhase or ''
          runHook preCheck

          runHook postCheck
        '';

      installPhase =
        previousAttrs.installPhase or ''
          runHook preInstall

          runHook postInstall
        '';

      doInstallCheck = previousAttrs.doInstallCheck or false;
      installCheckPhase =
        previousAttrs.installCheckPhase or ''
          runHook preInstallCheck

          runHook postInstallCheck
        '';

      composerRepository =
        previousAttrs.composerRepository or (phpDrv.mkComposerRepository2 {
          inherit composer;
          inherit (finalAttrs)
            patches
            pname
            src
            vendorHash
            version
            ;

          composerLock = previousAttrs.composerLock or null;
          composerNoDev = previousAttrs.composerNoDev or true;
          composerNoPlugins = previousAttrs.composerNoPlugins or true;
          composerNoScripts = previousAttrs.composerNoScripts or true;
          composerStrictValidation = previousAttrs.composerStrictValidation or true;
        });

      env = {
        COMPOSER_CACHE_DIR = "/dev/null";
        COMPOSER_DISABLE_NETWORK = "1";
        COMPOSER_MIRROR_PATH_REPOS = "1";
      };

      meta = previousAttrs.meta or { } // {
        platforms = lib.platforms.all;
      };
    };
in
args: (stdenvNoCC.mkDerivation args).overrideAttrs buildComposerProjectOverride
