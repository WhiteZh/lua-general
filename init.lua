---@alias notnil (boolean|number|string|table|function|thread|userdata|lightuserdata)


---@overload fun(stop: integer): fun(): integer|nil
---@overload fun(start: integer, stop: integer): fun(): integer|nil
---@param start integer
---@param stop integer
---@param step integer
---@return fun(): integer|nil
function _G.range(start, stop, step)
	if start == nil then
		error("missing 'stop'")
	elseif stop == nil then
		start, stop, step = 1, start, 1
	elseif step == nil then
		step = start < stop and 1 or -1
	end

	if start % 1 ~= 0 then
		error('start is not a whole number')
	end
	if stop % 1 ~= 0 then
		error('stop is not a whole number')
	end
	if step % 1 ~= 0 then
		error('step is not a whole number')
	end

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

---@param list table list
---@return fun(): notnil|nil
function _G.each(list)
	if not list then error("_G.each: missing 'list'") end
	local index = 0
	return function()
		index = index + 1
		return list[index]
	end
end

function os.clear()
	os.execute('clear')
end

function os.cls()
	os.execute('cls')
end

---@param table1 table table to be merged
---@param table2 table table merges into
---@param soft? boolean soft merge (not to overwrite existed); default: false
---@return table merged table
function table.merge(table1, table2, soft)
	for k,v in pairs(table2) do
		if table1[k] == nil or not soft then
			table1[k] = v
		end
	end
	return table1
end

---@param _table table clone source
---@return table clone
function table.clone(_table)
	return table.merge({}, _table)
end


List = {}
setmetatable(List, List)
---@class List
List.prototype = {}
---@return List
function List.new()
	local self = setmetatable({}, List.prototype)

	return self
end
---@param iterFunction function iterator
---@param modifyFunction function conditioner/modifier
---@return List
function List.create(iterFunction, modifyFunction)
	local self = List.new()

	modifyFunction = modifyFunction or function(value) return value end
	local value = iterFunction()
	while value ~= nil do
		self:join(modifyFunction(value))
		value = iterFunction()
	end

	return self
end
---@param list table
---@return List
function List.from(list)
	local self = List.new()
	if not list then error("'list' not provided") end
	for i,v in ipairs(list) do
		self[i] = v
	end
	return self
end
---@return List
function List:__call(...)
	local argc = select('#', ...)
	local ls = {}
	for i = 1, argc do
		ls[i] = select(i, ...)
	end
	return List.from(ls)
end

List.prototype.__index = List.prototype
---@param value table
---@return List
function List.prototype:__add(value)
	if type(value) ~= 'table' then
		error("'table' is not table type")
	end
	local result = self:clone()
	result:join(value)
	return result
end
---@param times integer
---@return List
function List.prototype:__mul(times)
	if type(times) ~= 'number' then
		error('must be a number!')
	end
	if times <= 0 or times % 1 ~= 0 then
		error('whole number onlyl!')
	end
	local result = List.new()
	for _ in range(times) do
		result:join(self)
	end
	return result
end
---@return string
function List.prototype:__tostring()
	return self:show()
end

---@return List
function List.prototype:clone()
	if not self then error("List: missing 'self', call using ':'") end
	local result = List.new()
	for v in each(self) do
		result:append(v)
	end
	return result
end
---@return string
function List.prototype:show()
	if not self then error("List: missing 'self', call using ':'") end
	local result = '[ '
	for v in each(self) do
		result = result..string.format('%s , ',tostring(v))
	end
	result = string.sub(result,1,string.len(result)-3)..' ]'
	return result
end
---@param list table
---@param index? number
---@return List
function List.prototype:join(list, index)
	if not self then error("List: missing 'self', call using ':'") end
	if not list then error("List: missing 'value'") end
	index = index or #self + 1
	if type(list) ~= 'table' then
		error("'value' is not table type")
	end
	for i,v in ipairs(list) do
		table.insert(self, index+i-1, v)
	end
	return self
end
---@param index? integer
---@param length? integer
---@return List
function List.prototype:remove(index, length)
	if not self then error("List: missing 'self', call using ':'") end
	index = index or #self
	length = length or 1
	for i in range(length) do
		table.remove(self, index)
	end
	return self
end
---@param value notnil
---@param index? integer
---@return List
function List.prototype:append(value, index)
	return self:join({value}, index)
end
---@param start? integer
---@param stop? integer
---@param step? integer
---@return List
function List.prototype:inter(start, stop, step)
	if not self then error("List: missing 'self', call using ':'") end
	local start = start or 1
	local stop = stop or #self
	local step = step or 1
	return List.create(range(start, stop, step), function(v) return self[v] end)
end
---@param comp function
---@return List
function List.prototype:sort(comp)
	if not self then error("List: missing 'self', call using ':'") end
	if not comp then error("List: missing 'comp'") end
	table.sort(self, comp)
	return self
end



Set = {}
setmetatable(Set, Set)
---@class Set
---@field data table
Set.prototype = {}
---@return Set
function Set.new()
	local self = setmetatable({}, Set.prototype)

	self.data = {}

	return self
end
---@param items table
---@return Set
function Set.from(items)
	local self = Set.new()

	for item in each(items) do
		self:insert(item)
	end

	return self
end
---@return Set
function Set:__call(...)
	local items = {}
	for i = 1, select('#', ...) do
		items[i] = select(i, ...)
	end
	return Set.from(items)
end

Set.prototype.__index = Set.prototype
---@return string
function Set.prototype:__tostring()
	return self:show()
end
---@param item notnil
---@return Set
function Set.prototype:insert(item)
	if not self then error("Set: missing 'self', call using ':'") end
	self.data[item] = true
	return self
end
---@param item notnil
---@return Set
function Set.prototype:remove(item)
	if not self then error("Set: missing 'self', call using ':'") end
	self.data[item] = nil
	return self
end
---@param item notnil
---@return boolean
function Set.prototype:contains(item)
	if not self then error("Set: missing 'self', call using ':'") end
	if self.data[item] then
		return true
	else
		return false
	end
end
---@return fun(): notnil|nil
function Set.prototype:items()
	if not self then error("Set: missing 'self', call using ':'") end
	return coroutine.wrap(function()
		local k = next(self.data, nil)
		while k do
			coroutine.yield(k)
			k = next(self.data, k)
		end
	end)
end
---@return string
function Set.prototype:show()
	if not self then error("Set: missing 'self', call using ':'") end
	local result = '{ '
	for v in self:items() do
		result = result..string.format('%s , ',tostring(v))
	end
	result = string.sub(result,1,string.len(result)-3)..' }'
	return result
end
