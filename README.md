How do I create a NixOS image with nix that doesn't reference other store paths?
===

The flake in this repo defines a simple NixOS disk image
that can be build with:

```
$ nix build

$ tree result
result
├── nix-support
│   └── hydra-build-products
└── nixos.img.zst
```

I would like to `nix copy` the result to another system.

The reason for `nix copy` is that I'm building the image on
https://nixbuild.net and I would like to get the image to my local machine /
GitHub runner so I'll need to use the method described in:
https://docs.nixbuild.net/remote-builds/#retrieving-build-output-from-remote-stores

However when copying I see that a lot of other /nix/store paths are
copied as well which means this image has run-time dependencies on
these other paths. Indeed:

```
$ nix-store -q --references result
/nix/store/045cq354ckg28php9gf0267sa4qgywj9-X-Restart-Triggers-systemd-timesyncd
/nix/store/0597v01rkmjdqn52idddi5x2vp08l847-perl5.40.0-List-Compare-0.55
/nix/store/0i7mzq93m8p7253bxnh7ydahmjsjrabk-gzip-1.14-man
/nix/store/0ip389clsbrbjmhmrysgfghqnhx8qlfd-glibc-locales-2.40-66
/nix/store/15k9rkd7sqzwliiax8zqmbk9sxbliqmd-X-Restart-Triggers-systemd-journald-
/nix/store/184bcjcc97x3klsz63fy29ghznrzkipg-zstd-1.5.7-man
/nix/store/cg9s562sa33k78m63njfn1rw47dp9z0i-glibc-2.40-66
...
/nix/store/x4a9ksmwqbhirjxn82cddvnhqlxfgw8l-linux-headers-static-6.12.7
/nix/store/x4b392vjjza0kz7wxbhpji3fi8v9hr86-gtest-1.16.0
/nix/store/xv0pc5nc41v5vi0lac1i2d353s3rqlkm-libxml2-2.13.8
/store/y180fqjr06vrg3fn09bx7dsxz7vvnzqk-etc
/nix/store/y7y1v7l88mxkljbijs7nwzm1gcg9yrjw-extra-utils
/nix/store/za3c1slqlz1gpm6ygzwnh3hd2f0lg31z-libblake3-1.8.2
/nix/store/lxdb1wc09p0494x4gslhk0hxn1q9l83s-nixos-disk-image
```

Nix probably tracks these as run-time dependencies since some, but not
all, /nix/store paths are contained in the zstandard compressed
result:

```
$ strings result/nixos.img.zst  | grep /nix/store
/nix/store/y7y1v7l88mxkljbijs7nwzm1gcg9yrjw-utils/bin
/nix/store/m4qaar099vcj0dgq4xdvhlbc8z4v9m22-getty/bin/
C<lto: /nix/store/hs4jhx1lslrykpbkwh7wag2jjd7mwj0n-perl5.40.0-XML--1.12/lib//site_perl/>LINKTYPE: dynamicVERSION: 1.12EXE_: >
export _ARCHIVE=/nix/store/0ip389clsbrbjmhmrysgfghqnhx8qlfd-2.40-66/lib/-archive60da146zpfdi0iplbg4hzpirb30vb5g7-perl5.40.0-XML-SAX-Base-1.09/site_perl//XML/SAX/.pm
/nix/store/1q9lw4r2mbap8rsr8cja46nap6wvrw2p-bash-active-5.2p37sh
libdir='/nix/store/2bjcjfzxnwk3zjhkrxi3m762p8dv6f1s-libcap-ng-0.8.5/lib'unix.so likeauth nullok try_first_pass # unix (order 11600)
prefix="/nix/store/za3c1slqlz1gpm6ygzwnh3hd2f0lg31z--1.8.2"
/nix/store/al9x8cr5xifp3qd2f5cdzh6z603kb5ps-perl-5.40.0/lib/perl5/x86_64-linux--multi/autCOREIPC
/nix/store/vxmnihhgnkyd2yh1y6gsyrw7lzqyh0sn-perl5.40.0-File-Slurp-9999.32/lib//site_perl///.pm
#!/nix/store/xy4jjgw87sbgwylm5kn047d9gkbhsr9x-bash-5.2p37/bin/sh
```

Since the `nixos.img.zst` is a standalone image, i.e. it contains its
own /nix/store, it shouldn't need to depend on anything in my
/nix/store.

**Is there a way to "erase" these dependenies such that a `nix copy` only
has to copy the final image and not all those dependencies?**
