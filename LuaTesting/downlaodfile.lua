require "socket"
require "string"
require "scratch"

function filedownload(host, file)
	c = assert(socket.connect(host, 80))
	c:send("GET " .. file .. " HTTP/1.0\r\n\r\n")
	count = 0
	while true do
	  local s, status = c:receive(2^10)
	  print(s)
	  if status == "closed" then break end
	end
	print(status)
	c:close()
end


--[[
host = "www.w3.org"
file = "/TR/REC-html32.html"
filedownload(host,file)
]]--