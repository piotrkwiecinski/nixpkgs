{
  lib,
  stdenv,
  buildPecl,
  cargo,
  rustc,
  fetchFromGitHub,
  rustPlatform,
  curl,
  pcre2,
  libiconv,
  darwin,
  php,
}:

buildPecl rec {
  pname = "ddtrace";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "DataDog";
    repo = "dd-trace-php";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-ajfqQZV/xnLiwwC7rpBcBYuw78ThYTvxo72z0Y8nAS4=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-xJ/Mjr5oxpd5VU9ypgkMdZCEoj/ce1r/ZhEAsqG5S74=";
  };

  env.NIX_CFLAGS_COMPILE = "-O2";

  nativeBuildInputs =
    [
      cargo
      rustc
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      rustPlatform.bindgenHook
      rustPlatform.cargoSetupHook
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk_11_0.rustPlatform.bindgenHook
      darwin.apple_sdk_11_0.rustPlatform.cargoSetupHook
    ];

  buildInputs =
    [
      curl
      pcre2
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.Security
      libiconv
    ];

  meta = {
    changelog = "https://github.com/DataDog/dd-trace-php/blob/${src.rev}/CHANGELOG.md";
    description = "Datadog Tracing PHP Client";
    homepage = "https://github.com/DataDog/dd-trace-php";
    license = with lib.licenses; [
      asl20
      bsd3
    ];
    maintainers = lib.teams.php.members;
    broken = lib.versionAtLeast php.version "8.4";
  };
}
