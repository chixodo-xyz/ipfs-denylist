measure start
local socket = require("socket")
local starttime = socket.gettime()

-- libraries
local sha = require("sha2")
local json = require('cjson')

-- functioins
function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

function table.contains(table, hash)
  for _, value in pairs(table) do
    if value["anchor"] == hash then
      return 403
    end
  end
  return 200
end

-- preparation
local denylist = readAll(ngx.var.denylist)
local denytable = json.decode(denylist)
local CID = ""

if string.starts(ngx.var.cid, "Qm") then
  CID = ngx.var.cid
else
  -- CIDv1 is not supported yet...
end

-- check conntain 
local check = table.contains(denytable, sha.sha256(CID))

-- performance measure end
local duration = (socket.gettime() - starttime) * 1000

-- return 200 if valid file or 403 if blocked
return check .. "|" .. duration
