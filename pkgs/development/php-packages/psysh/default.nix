{
  fetchFromGitHub,
  fetchurl,
  lib,
  php,
}:

let
  pname = "psysh";
  version = "0.12.3";

  src = fetchFromGitHub {
    owner = "bobthecow";
    repo = "psysh";
    rev = "v${version}";
    hash = "sha256-v2UAhxnfnVwA05sxcqMU5vmQcwlBcc901PYJqYf+pCw=";
  };

  composerLock = fetchurl {
    name = "composer.lock";
    url = "https://github.com/bobthecow/psysh/releases/download/v${version}/composer-v${version}.lock";
    hash = "sha256-ur6mzla3uXeFL6aEHAPdpxGdvcgzOgTLW/CKPbNqeCg=";
  };
in
php.buildComposerProject2 (finalAttrs: {
  inherit
    pname
    version
    composerLock
    src
    ;

  composerRepository = php.mkComposerRepository2 {
    inherit
      src
      version
      pname
      composerLock
      ;

    preBuild = ''
      export COMPOSER_ROOT_VERSION="${version}"
      composer config platform.php 7.4
      composer require --no-update symfony/polyfill-iconv symfony/polyfill-mbstring
      composer require --no-update --dev roave/security-advisories:dev-latest
      composer update --lock --no-install
    '';

    vendorHash = "sha256-DNsHGNQvUgo9T3IX9PZMyQCWT2/2P68WDzSxAGfXDPg=";
  };

  meta = {
    changelog = "https://github.com/bobthecow/psysh/releases/tag/v${finalAttrs.version}";
    description = "PsySH is a runtime developer console, interactive debugger and REPL for PHP.";
    mainProgram = "psysh";
    license = lib.licenses.mit;
    homepage = "https://psysh.org/";
    maintainers = lib.teams.php.members;
  };
})
