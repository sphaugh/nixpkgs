{ stdenv, stdenv49, gccStdenv, llvmPackages
, lib, fetchurl, fetchpatch, fetchFromGitHub

, cmake, ninja, which, findutils, m4, gawk
, python, python3, openjdk, mono, libressl, boost
}@args:

let
  vsmakeBuild = import ./vsmake.nix args;
  cmakeBuild = import ./cmake.nix (args // {
    gccStdenv    = gccStdenv;
    llvmPackages = llvmPackages;
  });

  python3-six-patch = fetchpatch {
    name   = "update-python-six.patch";
    url    = "https://github.com/apple/foundationdb/commit/4bd9efc4fc74917bc04b07a84eb065070ea7edb2.patch";
    sha256 = "030679lmc86f1wzqqyvxnwjyfrhh54pdql20ab3iifqpp9i5mi85";
  };

  python3-print-patch = fetchpatch {
    name   = "import-for-python-print.patch";
    url    = "https://github.com/apple/foundationdb/commit/ded17c6cd667f39699cf663c0e87fe01e996c153.patch";
    sha256 = "11y434w68cpk7shs2r22hyrpcrqi8vx02cw7v5x79qxvnmdxv2an";
  };

in with builtins; {

  # Older versions use the bespoke 'vsmake' build system
  # ------------------------------------------------------

  foundationdb51 = vsmakeBuild {
    version = "5.1.7";
    branch  = "release-5.1";
    sha256  = "1rc472ih24f9s5g3xmnlp3v62w206ny0pvvw02bzpix2sdrpbp06";

    patches = [
      ./patches/ldflags-5.1.patch
      ./patches/fix-scm-version.patch
      python3-six-patch
      python3-print-patch
    ];
  };

  foundationdb52 = vsmakeBuild {
    version = "5.2.8";
    branch  = "release-5.2";
    sha256  = "1kbmmhk2m9486r4kyjlc7bb3wd50204i0p6dxcmvl6pbp1bs0wlb";

    patches = [
      ./patches/ldflags-5.2.patch
      ./patches/fix-scm-version.patch
      python3-six-patch
      python3-print-patch
    ];
  };

  foundationdb60 = vsmakeBuild {
    version = "6.0.18";
    branch  = "release-6.0";
    sha256  = "0q1mscailad0z7zf1nypv4g7gx3damfp45nf8nzyq47nsw5gz69p";

    patches = [
      ./patches/ldflags-6.0.patch
    ];
  };

  # 6.1 and later versions should always use CMake
  # ------------------------------------------------------

  foundationdb61 = cmakeBuild {
    version = "6.1.12";
    branch  = "release-6.1";
    sha256  = "1yh5hx6rim41m0dwhnb2pcwz67wlnk0zwvyw845d36b29gwy58ab";

    patches = [
      ./patches/clang-libcxx.patch
      ./patches/suppress-clang-warnings.patch
    ];
  };

}
