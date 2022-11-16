# ipfs-denylist

>This code is not properly working yet! 
>1. Wrote quite fast and scratch
>2. Only CIDv0 is supportet
>2. Performance might be bad
>3. not properly testet

## Implementation

Trying to implement denylist in IPFS. Information so far:

```bash
#1. make sure to run nginx with the same user as ipfs
nano /etc/nginx/nginx.conf
user ipfs-user;

#2. include ipfs-denylist.conf to nginx virtual host (section server)
nano /etc/nginx/sites-available/ipfs-host.conf
#Add 3x:>
#include /etc/nginx/snippets/ipfs-denylist/ipfs-denylist.conf;

#3. install lua filter and add sha2 library
apt install libnginx-mod-http-lua
mkdir /usr/share/lua/
mkdir /usr/share/lua/5.1/
cd /usr/share/lua/5.1/
wget https://raw.githubusercontent.com/Egor-Skriptunoff/pure_lua_SHA/master/sha2.lua

#4. download denylist by dwebops and add required nginx-config, lua-filter
mkdir /etc/nginx/snippets/ipfs-denylist
cd /etc/nginx/snippets/ipfs-denylist
wget  https://badbits.dwebops.pub/denylist.json

nano ipfs-denylist.conf
#Add:>
	set $cid "test";
	set $denylist "/etc/nginx/snippets/ipfs-denylist/denylist.json";

	if ($host ~* "(.+)\.(?:ipfs|ipns)\.chixodo\.xyz$" ) {
	  set $cid "$1";
	}

	if ($request_uri ~* "([^/]+$)" ) {
	  set $cid "$1";
	}

	set_by_lua_file $deny /etc/nginx/snippets/ipfs-denylist/ipfs-denylist-filter.lua;

	if ($deny = "true") {
	  return 403 "Forbidden";
	}

nano ipfs-denylist-filter.lua
#Add:>
	local sha = require("sha2")

	function string.starts(String,Start)
	   return string.sub(String,1,string.len(Start))==Start
	end

	-- see if the file exists
	function file_exists(file)
	  local f = io.open(file, "rb")
	  if f then f:close() end
	  return f ~= nil
	end

	-- get all lines from a file, returns an empty 
	-- list/table if the file does not exist
	function lines_from(file)
	  if not file_exists(file) then return {} end
	  local lines = {}
	  for line in io.lines(file) do
	    lines[#lines + 1] = line
	  end
	  return lines
	end

	function firstline(file)
	  local f = io.open(file)
	  local l = f:read()
	  f:close()
	  return l
	end

	local denylist = ngx.var.denylist
	local CIDv0 = ""

	if string.starts(ngx.var.cid, "Qm") then
	  CIDv0 = ngx.var.cid
	else
	-- CIDv1 is not supported yet...
	end

	local lines = lines_from(denylist)

	-- print all line numbers and their contents
	for k,v in pairs(lines) do
	  if string.find(v, sha.sha256(CIDv0)) then
	    return "true"
	  end
	end

	return "false"
```

## Stuff

- Convert cid: `ipfs cid format -v 0 bafybeigwwctpv37xdcwacqxvekr6e4kaemqsrv34em6glkbiceo3fcy4si`
