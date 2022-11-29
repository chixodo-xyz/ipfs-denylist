-- performance measure start
local socket = require("socket")
local starttime = socket.gettime()

-- libraries
local sha = require("sha2")
local cidlib = require("cid")

-- functions
function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

function readAll(file)
  local f = io.open(file, "r")
  if f~=nil then
    local content = f:read("*all")
    f:close()
    return content
  else
    return ""
  end
end

function string.contains(string, hash)
  if string.find(string, hash) then
    return 403
  else
    return 200
  end
end

function getHostname()
    local f = io.popen ("/bin/hostname")
    local hostname = f:read("*a") or ""
    f:close()
    hostname =string.gsub(hostname, "\n$", "")
    return hostname
end

-- write pre-debuging header
if ngx.var.debug == "true" then
  ngx.header['X-debug-OriginalCID'] = ngx.var.cid
end

-- preparation
if string.starts(ngx.var.cid, "Qm") then
  -- CIDv0
  CID = ngx.var.cid
else
  if pcall(cidlib.decode(ngx.var.cid)) then
    -- CIDv1
    local CIDtemp = cidlib.decode(ngx.var.cid)
    CIDtemp.version = 0
    CIDtemp.multibase = "base58btc"
    CIDtemp.multicodec = "dag-pb"
    CIDtemp.multihash = "sha2-256"
    CID = cidlib.encode(CIDtemp)
  else
    -- nonCIDv0
    CID = ngx.var.cid
  end
end

local cidhash = sha.sha256(CID)
local denylistfile = ngx.var.denyfolder .. "/" .. cidhash:sub(0,2) .. "/" .. cidhash:sub(0,4)

-- check contain 
local check = string.contains(readAll(denylistfile), cidhash)

-- performance measure end
local duration = (socket.gettime() - starttime) * 1000

-- write debuging header
if ngx.var.debug == "true" then
  ngx.header['X-debug-Time'] = duration
  ngx.header['X-debug-ProcessedCID'] = CID
  ngx.header['X-debug-HashOfCID'] = cidhash
  ngx.header['X-debug-DenyListFile'] = denylistfile
  ngx.header['X-debug-Hostname'] = getHostname()
end

-- return 200 if valid file or 403 if blocked
return check
