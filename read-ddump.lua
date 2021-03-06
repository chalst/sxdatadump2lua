-- Filename:	sxddump.lua
-- Copyright: 	Charles Stewart (C) 2011 August, and later
-- Some functions that can be used when reading in the Lua rep'n of SX data dumps
-- as output by sxdatadump2lua

-- -- Some general-purpose definitions
nl = "\n"
q = function (string) return "\"" .. tostring(string) .. "\"" end

function map (f, table)
	local r = {}
	for key,val in ipairs (table) do
	    	r[key] = f(val)
	end
	return r
end    

function log (...) print ("log:", ...) end
-- function log (...) end


-- -- Initialise main data-carrying variables

site = {title="data dump"}
users = {type="users"}
posts = {type="posts"}; questions = {}
comments = {type="comments"}

unsxquotations = {
	-- Used in unquote_sx()
	["&amp;"] = "&",
	["&lt;"] = "<", ["&gt;"] = ">", 
	["&quot;"] = "\"" }

function unquote_sx (qtext)
	-- Referenced in type_trans_fwd: fn which makes strings legible.
	-- The SX data dumps makes characters like <, &, and < safe by mapping
	-- to their HTML character entities.  This fn maps them back.
	return (string.gsub (qtext, "&%a+;", unsxquotations))
end

function follow_index_fn (tlt)
	return	function (index_rep) 
			local i=tonumber(index_rep)
			if not(type(tlt[i]) == "table")
			  then tlt[i] = {}
			end
	       		return tlt[i] 
		end
end
follow_post_index = follow_index_fn (posts)

type_trans_fwd = {
	-- Parameter passed to transform_table().
	-- Currently only such parameter, would need alternatives if we
	-- treated alternative tlts differently
	Id=tonumber, 
	Views=tonumber, 
	Votes=tonumber, UpVotes=tonumber, DownVotes=tonumber,
	ParentId = follow_post_index, -- Used only by answers
	AcceptedAnswerId = follow_post_index, -- Used only by questions
	PostId = follow_post_index, -- Used by comments, posthistory, and votes
	UserId = follow_index_fn (users), -- Used by badges and posthistory
	Body=unquote_sx, -- Title=unquote_sx, 
	AboutMe=unquote_sx,
	Text=unquote_sx }

function transform_table (trans, x)
	local res = {}
	for key, val in pairs(x) do
		if trans[key] 
		  then res[key] = trans[key] (x[key]) 
		  else res[key] = x[key]
		end
	end
	return res
end

function add_row (tlt, trans, row)
	-- tlt: top-level table
	local i=tonumber(row.Id)
	tlt[i] = transform_table (trans, row)
	return tlt[i]
end

-- -- Now come the semantics of the Lua-ised data dump.

function user (row)
	add_row (users, type_trans_fwd, row)
end

function question (row)
	row.isquestion = true
	this = add_row (posts, type_trans_fwd, row)
	this.children = {}
	questions[1+#questions] = this
end
	 
function answer (row)
	row.isquestion = false
	this = add_row (posts, type_trans_fwd, row)
	local siblings = this.ParentId.children
	siblings[1+#siblings] = this
end

function comment (row)
	 add_row (comments, type_trans_fwd, row)
end

