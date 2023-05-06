List = Object:new({
	new = function(self, o)
		if not self then return end
		local metatable = {
			__index = self,
			__add = function(self, value)
				if type(value) ~= 'table' then
					value = { value }
				end
				local result = self:clone()
				for i=1,#value do
					result:append(value[i])
				end
				return result
			end,
			__mul = function(self, times)
				if type(times) ~= 'number' then
					-- error('must be a number!')
					return
				end
				if times <= 0 or times % 1 ~= 0 then
					-- error('whole number onlyl!')
					return
				end
				local result = List:new()
				for _ in range(times) do
					result = result + self
				end
				return result
			end,
		}
		return setmetatable(o or {}, metatable)
	end,
	create = function(self, iterFunction, modifyFunction)
		modifyFunction = modifyFunction or function(value) return value end
		local result = self:new()
		local value = iterFunction()
		while value ~= nil do
			result:append(modifyFunction(value))
			value = iterFunction()
		end
		return result
	end,
	clone = function(self)
		if not self then return end
		local result = List:new()
		for v in eachs(self) do
			result:append(v)
		end
		return result
	end,
	show = function(self)
		if not self then return end
		local result = '[ '
		for v in eachs(self) do
			result = result..string.format('%s , ',tostring(v))
		end
		result = string.sub(result,1,string.len(result)-3)..' ]'
		return result
	end,
	append = function(self, value, index)
		if not self or value == nil then return end
		index = index or #self + 1
		if type(value) ~= 'table' then
			value = {value}
		end
		for i in range(#self,index,-1) do
			self[i+#value] = self[i]
		end
		local vi = 1
		for i in range(index, index+#value - 1) do
			self[i] = value[vi]
			vi = vi + 1
		end
	end,
	remove = function(self, index, length)
		if not self then return end
		index = index or #self
		length = length or 1
		for i in range(index, #self) do
			self[i] = self[i+length]
		end
	end,
	inter = function(self, ...)
		local start = select('1', ...) or 1
		local stop = select('2', ...) or #self
		local step = select('3', ...) or 1
		return List:create(range(start, stop, step), function(v) return self[v] end)
	end,
})