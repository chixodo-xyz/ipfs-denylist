# ipfs-denylist

>This code is still a prototype! 
>1. Wrote quite fast
>2. not every possible thing is testet nor audited
>3. Scheduled update of Denylist must be implemented

## Implementation

>Follow this information to implement ipfs-denylist.

1. Clone Repo to /usr/share/ipfs-denylist

```bash
cd /usr/share
git clone https://github.com/chixodo-xyz/ipfs-denylist.git
cd ipfs-denylist
```

2. include nginx.conf to nginx virtual host (section server)

```bash
nano /etc/nginx/sites-available/[ipfs-host-config].conf
#ADD to every server section:>
  include /usr/share/ipfs-denylist/nginx.conf;
```

3. install lua filter and add sha2 library

```bash
apt install libnginx-mod-http-lua jq luarocks
luarocks install luasocket
echo "load_module modules/ngx_http_lua_module.so;"  > /etc/nginx/modules-enabled/50-mod-http-lua.conf
mkdir /usr/share/lua/
mkdir /usr/share/lua/5.1/
cp /usr/share/ipfs-denylist/lib/*.lua /usr/share/lua/5.1/
```

4. Generate denylist by dwebops 

```bash
./update-denylist.sh
#for Testing: 
./deny-cidv0.sh QmcniBv7UQ4gGPQQW2BwbD4ZZHzN3o3tPuNLZCbBchd1zh
./update-denylist.sh
```

>Remember to remove customdeny after testing: `rm customdeny.txt ; ./update-denylist.sh`

5. Activate change

```bash
nginx -t
service nginx restart
```

6. Setup Cron to Update denylist
```bash
crontab -e
ADD:>
*/10 * * * * cd /usr/share/ipfs-denylist && ./update-denylist.sh
```

## Testing

- allowed:
  + https://ipfs-gamma.chixodo.xyz/ipfs/QmTYKvmQPRtqLjaEYhjfBR8GSqZK6g7SE5ty3FerVGBdx1
  + https://ipfs-delta.chixodo.xyz/ipfs/QmTYKvmQPRtqLjaEYhjfBR8GSqZK6g7SE5ty3FerVGBdx1
  + https://bafybeicnjavpgjgqljrrr5kt3ole56ufgqpahzdtkcu5wjp6qmwre7o5iy.ipfs.chixodo.xyz/
  + SHA256: 04b3d0eb7e61f5e12d2ed4033544eab48fa608454f41ed75b910f99d37164691

- blocked:
  + https://ipfs-gamma.chixodo.xyz/ipfs/QmcniBv7UQ4gGPQQW2BwbD4ZZHzN3o3tPuNLZCbBchd1zh
  + https://ipfs-delta.chixodo.xyz/ipfs/QmcniBv7UQ4gGPQQW2BwbD4ZZHzN3o3tPuNLZCbBchd1zh
  + https://bafybeigwwctpv37xdcwacqxvekr6e4kaemqsrv34em6glkbiceo3fcy4si.ipfs.chixodo.xyz/
  + SHA256: 520baafdcc3c7e79ac74c9c8e9f820cbb7b35cec61dbf18a21582f1bbc2dcd86

- Check blocked accesses: `cat /var/log/nginx/access.log | grep " 403 "`

## Credits:

- CID/Multicode/Multihash Implementation: https://github.com/filecoin-project/lua-filecoin
- SHA2 Implementation: https://github.com/Egor-Skriptunoff/pure_lua_SHA

