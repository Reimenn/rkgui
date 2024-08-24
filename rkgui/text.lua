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

return text
