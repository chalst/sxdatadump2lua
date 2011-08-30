-- archive-site.lua - read-ddump.lua application to build static pages
 
-- Copyright:	(C) Charles Stewart, August 2011 and later
-- License:	GPL3
-- Hosted:	https://github.com/chalst/sxdatadump2lua
-- Project:	http://www.advogato.org/proj/sxdatadump2lua/

-- This code should be run with the TLTs as defined in read-ddump.lua
-- already defined.  All generated content comes from them.

function tag_a (keyvals)
	 anchor = "<a "
	 if keyvals.link then anchor = anchor .. "href=\"" .. keyvals.link .. "\" " end
	 if keyvals.name then anchor = anchor .. "name=\"" .. keyvals.name .. "\" " end
	 return anchor .. ">" .. keyvals.text .. "</a>"
end

-- -- -- QUESTION LIST

io.output("questions.html")

io.write ("<html>")
io.write ( meta_section {} )
io.write ("<body>")
io.write ("<ul>")
for i,ival in ipairs (questions) do
	istr = tostring(ival.Id)
	io.write ("<li>" .. istr .. ". "
		.. tag_a {link="./qn-" .. istr .. ".html", text=ival.Title})
end
io.write ("</ul>")
io.write ("</body></html>")

-- -- -- QUESTION PAGES

function write_qn_page (n)
	io.output("qn-" .. tostring(n) .. ".html")
	io.write ("<html>")
	io.write ( meta_section {} )
	io.write ("<body>")

	