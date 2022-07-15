string.split = function(s, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(s, "([^"..sep.."]+)") do
        table.insert(t, str) end
    return t
end