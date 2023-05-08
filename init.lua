
---
--- @param start number from (inclusive); whole number only (otherwise be floored); default: 1
--- @param stop number to (inclusive); whole number only (otherwise be floored)
--- @param step number increase/decrease per iteration; whole number only (otherwise be floored); default: 1
--- @return function iterator
range = function(...)
	local paramCount = select('#', ...)
	local start, stop, step

	if paramCount == 0 then
		error("range: missing 'stop'")
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

---
--- @param list table list
--- @return function iterator
eachs = function(list)
	if not list then error("eachs: missing 'list'") end
	local index = 0
	return function()
		index = index + 1
		return list[index]
	end
end

---
--- @param name table package
--- @return table package
rerequire = function(name)
	if not name then error("rerequire: missing 'name'") end
	package.loaded[name] = nil
	return require(name)
end

---
os.clear = function()
	os.execute('clear')
end

---
os.cls = function()
	os.execute('cls')
end

---
--- @param table1 table table to be merged
--- @param table2 table table merges into
--- @param soft boolean soft merge (not to overwrite existed); default: false
--- @return table merged table
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

---
--- @param _table table table
--- @param metatable table metatable
--- @param overwrite boolean overwriting existed; default: false
--- @return table table
addmetatable = function(_table, metatable, overwrite)
	return setmetatable(_table, table.merge(getmetatable(_table) or {}, metatable, not overwrite))
end

--[[indexlocator = function(sources)
	if type(sources) ~= 'table' then return end
	return function(self, key)
		local count = 0
		for each in eachs(sources) do
			count = count + 1
			print('count: '..tostring(count))
			print('each: '..tostring(each))
			local ret
			if type(each) == 'function' then print('its function'); ret = each(self, key) end
			if type(each) == 'table' then print('its table'); ret = each[key] end
			if ret then return ret end
		end
	end
end]]

---
--- @param name string name
--- @param attribute table attribute
--- @return table attribute
createattribute = function(name, attribute)
	name = name or attribute.__attributeName
	return addmetatable(attribute, {__tostring = function() return 'Attribute: '..name end}, true)
end

---
--- @param name string name
--- @param package table package
--- @return table package
createpackage = function(name, package)
	name = name or package.__attributeName
	return addmetatable(package, { __tostring = function() return 'Package: '..name end}, true)
end

createpackage('table', table)
createpackage('debug', debug)
createpackage('os', os)
createpackage('io', io)
createpackage('math', math)
createpackage('string', string)
createpackage('package', package)
createpackage('coroutine', coroutine)


addmetatable(table, {__tostring = function() return 'Package: table' end}, true)
addmetatable(debug, {__tostring = function() return 'Package: debug' end}, true)
addmetatable(os, {__tostring = function() return 'Package: os' end}, true)
addmetatable(io, {__tostring = function() return 'Package: io' end}, true)
addmetatable(math, {__tostring = function() return 'Package: math' end}, true)
addmetatable(string, {__tostring = function() return 'Package: string' end}, true)
addmetatable(package, {__tostring = function() return 'Package: package' end}, true)
addmetatable(coroutine, {__tostring = function() return 'Package: coroutine' end}, true)


---
Object = createattribute('Object', {})
---
--- @param o table Object: Any
--- @return table Object: Object+Any
Object.assign = function(o)
	o = o or {}
	o.__uniqueID = o.__uniqueID or string.sub(tostring(o), 8)
	o.getUniqueID = function(self)
		return self.__uniqueID
	end
	addmetatable(o, {
		__tostring = function(self)
			return 'Object: '..self.__uniqueID
		end,
	}, true)
	return o
end

--[[Object = {
	__attributeName = 'Object',
	assign = function(self, o)
		if not self then return end
		o = o or {}
		o.__uniqueID = o.__uniqueID or string.sub(tostring(o), 8)
		return addmetatable(o, self, true)
	end,
	getUniqueID = function(self)
		return self.__uniqueID
	end,
	__tostring = function(self)
		return 'Object: '..self.__uniqueID
	end,
} Object.__index = indexlocator({Object}); assignattributename(Object);]]

---
List = createattribute('List', {})
---
--- @param o table Object: Any
--- @return table Object: List+Any
List.assign = function(o)
	o = o or {}
	o = Object.assign(o)
	o.clone = function(self)
		if not self then error("List: missing 'self', call using ':'") end
		local result = List.assign()
		for v in eachs(self) do
			result:append(v)
		end
		return result
	end
	o.show = function(self)
		if not self then error("List: missing 'self', call using ':'") end
		local result = '[ '
		for v in eachs(self) do
			result = result..string.format('%s , ',tostring(v))
		end
		result = string.sub(result,1,string.len(result)-3)..' ]'
		return result
	end
	o.append = function(self, value, index)
		if not self then error("List: missing 'self', call using ':'") end
		if not value then error("List: missing 'value'") end
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
		return self
	end
	o.remove = function(self, index, length)
		if not self then error("List: missing 'self', call using ':'") end
		index = index or #self
		length = length or 1
		for i in range(index, #self) do
			self[i] = self[i+length]
		end
		return self
	end
	o.inter = function(self, ...)
		if not self then error("List: missing 'self', call using ':'") end
		local start = select('1', ...) or 1
		local stop = select('2', ...) or #self
		local step = select('3', ...) or 1
		return List.create(range(start, stop, step), function(v) return self[v] end)
	end
	o.sort = function(self, comp)
		if not self then error("List: missing 'self', call using ':'") end
		table.sort(self, comp)
		return self
	end
	addmetatable(o, {
		__attributeName = 'List',
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
			local result = List.assign()
			for _ in range(times) do
				result = result + self
			end
			return result
		end,
		__tostring = function(self)
			return 'List: '..tostring(self:show())
		end,
	}, true)
	return o
end
---
--- @param iterFunction function iterator
--- @param modifyFunction function conditioner/modifier
--- @return table Object: List
List.create = function(iterFunction, modifyFunction)
	modifyFunction = modifyFunction or function(value) return value end
	local result = List.assign()
	local value = iterFunction()
	while value ~= nil do
		result:append(modifyFunction(value))
		value = iterFunction()
	end
	return result
end

--[[List = {
	__attributeName = 'List',
	assign = function(self, o)
		if not self then return end
		o = o or {}
		if type(o) ~= 'table' then o = { o } end
		o = Object:assign(o)
		return addmetatable(o, self, true)
	end,
	create = function(self, iterFunction, modifyFunction)
		if not self then return end
		modifyFunction = modifyFunction or function(value) return value end
		local result = self:assign()
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
		local result = List:assign()
		for _ in range(times) do
			result = result + self
		end
		return result
	end,
	__tostring = function(self)
		return self.__attributeName..': '..tostring(self:show())
	end,
	clone = function(self)
		if not self then return end
		local result = List:assign()
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
		return self
	end,
	remove = function(self, index, length)
		if not self then return end
		index = index or #self
		length = length or 1
		for i in range(index, #self) do
			self[i] = self[i+length]
		end
		return self
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
} List.__index = indexlocator({List, Object.__index}); assignattributename(List);]]
