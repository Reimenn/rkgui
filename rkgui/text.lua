local text = {}

--- @param text string
--- @param width integer
--- @return string
function text.center(text, width)
    local space = width - #text
    local res = text
    if space > 0 then
        local left = space / 2
        res = string.rep(' ', left) .. text .. string.rep(' ', space - left)
    end
    if #res < width then
        res = res .. ' '
    end
    return res
end

--- @param text string
--- @param width integer
--- @return string
function text.right(text, width)
    local space = width - #text
    if space <= 0 then return text end
    return string.rep(' ', space) .. text
end

--- @param text string
--- @param width integer
--- @return string
function text.left(text, width)
    local space = width - #text
    if space <= 0 then return text end
    return text .. string.rep(' ', space)
end

--- @param source string
--- @param width integer
--- @return string[]
function text.wrap(source, width)
    return require('cc.strings').wrap(source, width)
end

--- @param source string
--- @param delimiter string
--- @return string[]
function text.split(source, delimiter)
    return require('cc.strings').split(source, delimiter)
end

--- @param source string
--- @return string
function text.trim(source)
    return source:match("^%s*(.-)%s*$")
end

--- @param source string
--- @param value string
--- @param pos integer
--- @return string
function text.insert(source, value, pos)
    source = source:sub(1, pos - 2) .. value .. source:sub(pos - 1)
    return source
end

--- @param source string
--- @param pos integer
--- @return string
function text.removeAt(source, pos)
    source = source:sub(1, pos - 1) .. source:sub(pos + 1)
    return source
end

return text
