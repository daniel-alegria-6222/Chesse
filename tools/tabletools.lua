local tableTools = {}

function tableTools.concat(t1, t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function tableTools.contains_elem(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function tableTools.contains_table(table1, subtable)
    for _, subtable1 in ipairs(table1) do
        if table.concat(subtable1) == table.concat(subtable) then
            return true
        end
    end
    return false
end

function tableTools.equals(table1, table2)
    if table.concat(table1) == table.concat(table2) then
        return true
    else
        return false
    end
end

function tableTools.deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = tableTools.deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

function tableTools.tostring(table1)
    local str = ""
    for _, subtable1 in ipairs(table1) do
        str = str.."\n"
    end
    return false
end

return tableTools