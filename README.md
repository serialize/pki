# Serialize PKI

Some cfssö container orchestrated as multi issuer pki (trust-look-who) 

It uses cloudflare pki toolkit cfssl. 

__sub_ca__:  
a cfssl serve instance as intermediate to sign and issue certs mainly to other CAs. 

__sys_ca__:  
a multiroots cfssl instance. Mainly focuses core-os services 

__tik_ca__:  
a multiroots cfssl instance. Mainly focuses mikrotik services.


__hirarchy__:

    - root-ca (offline)
        |
        |- sub-ca
            |
            |- sys-ca --
            |           |- etcd-server-ca
            |           |- etcd-peer-ca
            |           |- etcd-client-ca
            |           |- docker
            |
            |- tik-ca --
            |           |- ovpn-ca
            |           |- capsman-ca
            |           |- cli-ca
            |
