
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
	return addmetatable(attribute, {__tostring = function() return 'Attribute: '..name end}, true)
end

---
--- @param name string name
--- @param package table package
--- @return table package
createpackage = function(name, package)
	name = name or package.__packageName
	package.__uniqueID = string.sub(tostring(package), 8)
	return addmetatable(package, { __tostring = function() return 'Package: '..name end}, true)
end

---
--- @param times number times
--- @param value any value
--- @return any
dup = function(...)
	local times, value
	if select('#', ...) == 1 then
		times = 2
		value = select(1, ...)
	else
		times = select(1, ...)
		value = select(2, ...)
	end
	if times == 1 then return value end
	return value, dup(times - 1, value)
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
Object.table = {
	__up = function(this, self)
		setmetatable(self, {})
		for i,v in pairs(self) do
			if string.sub(tostring(i),1,2) ~= '__' then
				self[i] = nil
			end
		end

		for i,v in pairs(this) do
			if string.sub(tostring(i),1,2) ~= '__' then
				self[i] = v
			end
		end

		setmetatable(self, {
			__tostring = function(self)
				return 'Object: '..self.__uniqueID
			end,
		})
	end,

	getUniqueID = function(this, self)
		return self.__uniqueID
	end,
	hasAttribute = function(this, self, attribute)
		return self.__attributes[attribute.__uniqueID] and true or false
	end,
	as = function(this, self, attribute)
		if not this.hasAttribute(self, attribute) then error("Object.as: 'self' does not contain '"..tostring(attribute).."'") end
		return self.__attributes[attribute.__uniqueID]:__up(self)
	end,
}
---
Object.new = function(self)
	local o = {}
	o.__attributes = {}
	o.__uniqueID = string.sub(tostring(o), 8)
	local this
	this, o.__attributes[self.__uniqueID] = dup({})

	this.__up = self.table.__up

	for i,v in pairs(self.table) do
		if string.sub(tostring(i),1,2) ~= '__' then
			this[i] = function(...) return v(this, ...) end
		end
	end

	o.__attributes[self.__uniqueID]:__up(o)

	return o
end

---
List = createattribute('List', {})
---
List.table = {
	__up = function(this, self)
		self.__attributes[Object.__uniqueID].as(self, Object)

		for i,v in pairs(this) do
			if string.sub(tostring(i),1,2) ~= '__' then
				self[i] = v
			end
		end

		addmetatable(self, {
			__index = function(self, key)
				if type(key) ~= 'number' then return end
				return this[key]
			end,
			__newindex = function(self, key, value)
				if type(key) ~= 'number' then return end
				this[key] = value
			end,
			__add = function(self, value)
				if type(value) ~= 'table' then
					value = { value }
				end
				local result = this:clone()
				for i=1,#value do
					result:append(value[i])
				end
				return result
			end,
			__mul = function(self, times)
				if type(times) ~= 'number' then
					error('must be a number!')
				end
				if times <= 0 or times % 1 ~= 0 then
					error('whole number onlyl!')
				end
				local result = List:new()
				for _ in range(times) do
					result = result + this
				end
				return result
			end,
			__tostring = function(self)
				return 'List: '..tostring(this:show())
			end,
		}, true)
	end,

	clone = function(this, self)
		if not self then error("List: missing 'self', call using ':'") end
		local result = List:new()
		for v in eachs(this) do
			result:append(v)
		end
		return result
	end,
	show = function(this, self)
		if not self then error("List: missing 'self', call using ':'") end
		local result = '[ '
		for v in eachs(this) do
			result = result..string.format('%s , ',tostring(v))
		end
		result = string.sub(result,1,string.len(result)-3)..' ]'
		return result
	end,
	append = function(this, self, value, index)
		if not self then error("List: missing 'self', call using ':'") end
		if not value then error("List: missing 'value'") end
		index = index or #this + 1
		if type(value) ~= 'table' then
			value = {value}
		end
		for i in range(#this,index,-1) do
			this[i+#value] = this[i]
		end
		local vi = 1
		for i in range(index, index+#value - 1) do
			this[i] = value[vi]
			vi = vi + 1
		end
		return self
	end,
	remove = function(this, self, index, length)
		if not self then error("List: missing 'self', call using ':'") end
		index = index or #this
		length = length or 1
		for i in range(index, #this) do
			this[i] = this[i+length]
		end
		return self
	end,
	inter = function(this, self, ...)
		if not self then error("List: missing 'self', call using ':'") end
		local start = select('1', ...) or 1
		local stop = select('2', ...) or #this
		local step = select('3', ...) or 1
		return List.create(range(start, stop, step), function(v) return this[v] end)
	end,
	sort = function(this, self, comp)
		if not self then error("List: missing 'self', call using ':'") end
		table.sort(this, comp)
		return self
	end,
}
---
List.new = function(self)
	local o = {}
	o = Object:new()
	return self:assign(o)
end
---
--- @param o table Object: Any
--- @return table Object: List+Any
List.assign = function(self, o)
	local this
	this, o.__attributes[self.__uniqueID] = dup({})

	this.__up = self.table.__up

	for i,v in pairs(self.table) do
		if string.sub(tostring(i),1,2) ~= '__' then
			this[i] = function(...) return v(this, ...) end
		end
	end

	o.__attributes[self.__uniqueID]:__up(o)

	return o
end
---
--- @param iterFunction function iterator
--- @param modifyFunction function conditioner/modifier
--- @return table Object: List
List.create = function(self, iterFunction, modifyFunction)
	modifyFunction = modifyFunction or function(value) return value end
	local result = self:new()
	local value = iterFunction()
	while value ~= nil do
		result:append(modifyFunction(value))
		value = iterFunction()
	end
	return result
end
