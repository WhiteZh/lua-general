
range = function(...)
	local paramCount = select('#', ...)
	local start, stop, step

	if paramCount == 0 then
		return
	elseif paramCount == 1 then
		start = 1
		stop = select('1', ...)
		step = 1
	elseif paramCount == 2 then
		start = select('1', ...)
		stop = select('2', ...)
		step = start < stop and 1 or -1
	else
		start = select('1', ...)
		stop = select('2', ...)
		step = select('3', ...)
	end

	start = math.floor(start)
	stop = math.floor(stop)
	step = math.floor(step)

	local iter = start - step
	local up = step > 0
	return function()
		iter = iter + step
		if up then
			if iter > stop then return nil end
			return iter
		else
			if iter < stop then return nil end
			return iter
		end
	end
end

eachs = function(list)
	local index = 0
	return function()
		index = index + 1
		return list[index]
	end
end

rerequire = function(name)
	package.loaded[name] = nil
	return require(name)
end

os.clear = function()
	os.execute('clear')
end

os.cls = function()
	os.execute('cls')
end

table.merge = function(table1, table2, soft)
	if soft then
		for k,v in pairs(table2) do
			if table1[k] == nil then
				table1[k] = v
			end
		end
	else
		for k,v in pairs(table2) do
			table1[k] = v
		end
	end
	return table1
end

addmetatable = function(_table, metatable, overwrite)
	return setmetatable(_table, table.merge(getmetatable(_table) or {}, metatable, not overwrite))
end


addmetatable(table, {__tostring = function() return 'Package: table' end}, true)
addmetatable(debug, {__tostring = function() return 'Package: debug' end}, true)
addmetatable(os, {__tostring = function() return 'Package: os' end}, true)
addmetatable(io, {__tostring = function() return 'Package: io' end}, true)
addmetatable(math, {__tostring = function() return 'Package: math' end}, true)
addmetatable(string, {__tostring = function() return 'Package: string' end}, true)
addmetatable(package, {__tostring = function() return 'Package: package' end}, true)
addmetatable(coroutine, {__tostring = function() return 'Package: coroutine' end}, true)


Object = {
	__className = 'Object',
	__index = Object,
	new = function(self, o)
		if not self then return end
		o = o or {}
		o.__uniqueID = o.__uniqueID or string.sub(tostring(o), 8)
		return addmetatable(o, self, true)
	end,
	__tostring = function(self)
		return self.__className..': '..self.__uniqueID
	end,
} Object.__index = Object; setmetatable(Object, {__tostring = function() return 'Class: Object' end});

List = {
	__className = 'List',
	new = function(self, o)
		if not self then return end
		o = o or {}
		if type(o) ~= 'table' then o = { o } end
		o = Object:new(o)
		return addmetatable(o, self, true)
	end,
	create = function(self, iterFunction, modifyFunction)
		if not self then return end
		modifyFunction = modifyFunction or function(value) return value end
		local result = self:new()
		local value = iterFunction()
		while value ~= nil do
			result:append(modifyFunction(value))
			value = iterFunction()
		end
		return result
	end,
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
	__tostring = function(self)
		return self.__className..': '..tostring(self:show())
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
	sort = function(self, comp)
		table.sort(self, comp)
		return self
	end
} List.__index = List; setmetatable(List, {__tostring = function() return 'Class: List' end})