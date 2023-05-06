Object = { className = 'Object',

    new = function(self, o)
        if not self then return end
        local metatable = {
            __index = self,
        }
        return setmetatable(o or {}, metatable)
    end,
}
