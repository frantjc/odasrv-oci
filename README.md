# odasrv-oci

Builds a container image to run [Odamex](https://github.com/odamex/odamex)'s `odasrv` for a great Doom 2 multiplayer dedicated server.

## use

See [Kubernetes example](k8s.yaml).

Docker example:

```sh
docker run --rm -it \
    --publish 10666:10666/udp \
    --volume `pwd`/odasrv.cfg:/usr/local/etc/odamex/odasrv.cfg \
    --volume `pwd`/wads:/usr/local/games/wads \
    ghcr.io/frantjc/odasrv:10.6.0 \
        -config /usr/local/etc/odamex/odasrv.cfg \
        -waddir /usr/local/games/wads \
        -iwad mywad.wad
```
