--- @type fun(text:string, width:number):string[]
local text_wrap = require('cc.strings').wrap

local model = {}

--- @param text string
--- @param width number
--- @return string
function model.center(text, width)
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
--- @param width number
--- @return string
function model.right(text, width)
    local space = width - #text
    if space <= 0 then
        return text
    end
    return string.rep(' ', space) .. text
end

--- @param text string
--- @param width number
--- @return string
function model.left(text, width)
    local space = width - #text
    if space <= 0 then
        return text
    end
    return text .. string.rep(' ', space)
end

--- @param source string
--- @param width number
--- @return string[]
function model.wrap(source, width)
    return text_wrap(source, width)
end

--- @param source string
--- @param value string
--- @param pos number
--- @return string
function model.insert(source, value, pos)
    source = source:sub(1, pos - 2) .. value .. source:sub(pos - 1)
    return source
end

--- @param source string
--- @param pos number
--- @return string
function model.removeAt(source, pos)
    source = source:sub(1, pos - 1) .. source:sub(pos + 1)
    return source
end

--- @param source string
--- @param limiter string
--- @return table
function model.split(source, limiter)
    local res = {}
    local buf = ""
    for i = 1, #source do
        if source:sub(i, i) == limiter then
            if #buf > 0 then
                table.insert(res, buf)
                buf = ""
            end
        else
            buf = buf .. source:sub(i, i)
        end
    end
    if #buf > 0 then
        table.insert(res, buf)
    end
    return res
end

return model
