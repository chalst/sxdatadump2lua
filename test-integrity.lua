for i,v in ipairs (posts) do
	pid=v.ParentId
	heads = ""
	for key in pairs(v) do heads = heads .. key .. " " end
	if pid
	then print (i,pid.Id,heads)
	else print (i,v.isquestion,heads)
	end
end
