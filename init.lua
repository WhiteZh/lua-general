
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
--- @param _table table clone source
--- @return table clone
table.clone = function(_table)
	return table.merge({}, _table)
end

---
--- @param _table table table
--- @param metatable table metatable
--- @param overwrite boolean overwriting existed; default: false
--- @return table table
addmetatable = function(_table, metatable, overwrite)
	return setmetatable(_table, table.merge(getmetatable(_table) or {}, metatable, not overwrite))
end

---
--- @param name string name
--- @param attribute table attribute
--- @return table attribute
createattribute = function(name, attribute)
	name = name or attribute.__attributeName
	attribute.__uniqueID = string.sub(tostring(attribute), 8)
	attribute.__attributeName = name
	return addmetatable(attribute, {__tostring = function() return 'Attribute: '..name end}, true)
end

---
--- @param name string name
--- @param package table package
--- @return table package
createpackage = function(name, package)
	name = name or package.__packageName
	package.__uniqueID = string.sub(tostring(package), 8)
	package.__packageName = name
	return addmetatable(package, { __tostring = function() return 'Package: '..name end}, true)
end

---
--- @param methods table __methods
--- @param self table the object
--- @return table concealed methods
concealmethods = function(methods, self)
	local ret = {}
	for k,v in pairs(methods) do
		ret[k] = function(...) return v(self, ...)  end
	end
	return ret
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
Object.__meta = {
	__tostring = function(self)
		return self.__attributeName..': '..self.__uniqueID
	end,
}
---
Object.__methods = {
	getUniqueID = function(self)
		return self.__uniqueID
	end,
	hasAttribute = function(self, attribute)
		return self.__attributes[attribute.__uniqueID] and true or false
	end,
	as = function(self, attribute)
		if not Object.__methods.hasAttribute(self, attribute) then
			error("Object.as: 'self' does not contain '"..tostring(attribute).."'") end
		return attribute.__up(self)
	end,
}
---
Object.__up = function(self)
	local __uniqueID, __attributes = self.__uniqueID, self.__attributes
	for i,v in pairs(self) do self[i] = nil end
	self.__uniqueID, self.__attributes, self.__attributeName = __uniqueID, __attributes, Object.__attributeName

	setmetatable(self, self.__attributes[Object.__uniqueID].__meta)
	for i,v in pairs(self.__attributes[Object.__uniqueID].__methods) do self[i] = v end
end
---
Object.new = function()
	local o = {}
	o.__attributes = {}
	o.__uniqueID = string.sub(tostring(o), 8)

	o.__attributes[Object.__uniqueID] = {
		__methods = concealmethods(Object.__methods, o),
		__meta = table.merge({}, Object.__meta),
	}

	Object.__up(o)

	return o
end


---
List = createattribute('List', {})
---
List.__meta = {
	__index = function(self, key)
		if type(key) ~= 'number' then return end
		return self.__attributes[List.__uniqueID].values[key]
	end,
	__newindex = function(self, key, value)
		if type(key) ~= 'number' then return end
		self.__attributes[List.__uniqueID].values[key] = value
	end,
	__len = function(self)
		return #self.__attributes[List.__uniqueID].values
	end,
	__add = function(self, value)
		if type(value) ~= 'table' then
			value = { value }
		end
		local result = self.__attributes[List.__uniqueID].__methods.clone()
		for i=1,#value do
			result.append(value[i])
		end
		return result
	end,
	__mul = function(self, times)
		if type(times) ~= 'number' then
			error('List.__meta.__mul: must be a number!')
		end
		if times <= 0 or times % 1 ~= 0 then
			error('List.__meta.__mul: whole number onlyl!')
		end
		local result = List.new()
		for _ in range(times) do
			result.append(self.__attributes[List.__uniqueID].values)
		end
		return result
	end,
	__tostring = function(self)
		return self.__attributeName..': '..tostring(self.__attributes[List.__uniqueID].__methods.show())
	end,
}
---
List.__methods = {
	clone = function(self)
		if not self then error("List: missing 'self', call using ':'") end
		local result = List.new()
		for v in eachs(self.__attributes[List.__uniqueID].values) do
			result.append(v)
		end
		return result
	end,
	show = function(self)
		if not self then error("List: missing 'self', call using ':'") end
		local result = '[ '
		for v in eachs(self.__attributes[List.__uniqueID].values) do
			result = result..string.format('%s , ',tostring(v))
		end
		result = string.sub(result,1,string.len(result)-3)..' ]'
		return result
	end,
	append = function(self, value, index)
		if not self then error("List: missing 'self', call using ':'") end
		if not value then error("List: missing 'value'") end
		local this = self.__attributes[List.__uniqueID].values
		index = index or #this + 1
		if type(value) ~= 'table' then
			value = {value}
		else
			value = List.from(value)
		end
		for i,v in ipairs(value) do
			table.insert(this, index+i-1, v)
		end
		return self
	end,
	remove = function(self, index, length)
		if not self then error("List: missing 'self', call using ':'") end
		local this = self.__attributes[List.__uniqueID].values
		index = index or #this
		length = length or 1
		for i in range(length) do
			table.remove(this, index)
		end
		return self
	end,
	inter = function(self, ...)
		if not self then error("List: missing 'self', call using ':'") end
		local this = self.__attributes[List.__uniqueID].values
		local start = select('1', ...) or 1
		local stop = select('2', ...) or #this
		local step = select('3', ...) or 1
		return List.create(range(start, stop, step), function(v) return this[v] end)
	end,
	sort = function(self, comp)
		if not self then error("List: missing 'self', call using ':'") end
		table.sort(self.__attributes[List.__uniqueID].values, comp)
		return self
	end,
}
---
List.__up = function(self)
	Object.__up(self)

	self.__attributeName = List.__attributeName

	for i,v in pairs(self.__attributes[List.__uniqueID].__methods) do
		self[i] = v
	end

	addmetatable(self, self.__attributes[List.__uniqueID].__meta, true)
end
---
List.new = function()
	local o = Object.new()

	o.__attributeName = List.__attributeName

	o.__attributes[List.__uniqueID] = {
		__methods = concealmethods(List.__methods, o),
		__meta = table.merge({}, List.__meta),
		values = {},
	}

	List.__up(o)

	return o
end
---
--- @param iterFunction function iterator
--- @param modifyFunction function conditioner/modifier
--- @return table Object: List
List.create = function(iterFunction, modifyFunction)
	modifyFunction = modifyFunction or function(value) return value end
	local result = List.new()
	local value = iterFunction()
	while value ~= nil do
		result.append(modifyFunction(value))
		value = iterFunction()
	end
	return result
end
---
--- @param list table list
--- @return table List
List.from = function(list)
	local ret = List.new()
	for i,v in ipairs(list) do
		ret[i] = v
	end
	return ret
end