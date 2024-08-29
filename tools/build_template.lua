__BUILDED_MODULE__ = {
    MODULE = {},
    CACHE = {},
    --- @param name string
    REQUIRE = function(name)
        if __BUILDED_MODULE__.CACHE[name] == nil then
            local module_func = __BUILDED_MODULE__.MODULE[name]
            if module_func == nil then
                error("not found module " .. name)
            end
            __BUILDED_MODULE__.CACHE[name] = module_func()
        end
        return __BUILDED_MODULE__.CACHE[name]
    end
}