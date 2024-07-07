
---@param start number|nil from (inclusive); whole number only (otherwise be floored); default: 1
---@param stop number to (inclusive); whole number only (otherwise be floored)
---@param step number|nil increase/decrease per iteration; whole number only (otherwise be floored); default: 1
---@return function iterator
function _G.range(...)
	local paramCount = select('#', ...)
	local start, stop, step

	if paramCount == 0 then
		error("missing 'stop'")
	elseif paramCount == 1 then
		start = 1
		stop = select(1, ...)
		step = 1
	elseif paramCount == 2 then
		start = select(1, ...)
		stop = select(2, ...)
		step = start < stop and 1 or -1
	else
		start = select(1, ...)
		stop = select(2, ...)
		step = select(3, ...)
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
---@return function iterator
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
---@param soft boolean|nil soft merge (not to overwrite existed); default: false
---@return table merged table
function table.merge(table1, table2, soft)
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

---@param _table table clone source
---@return table clone
function table.clone(_table)
	return table.merge({}, _table)
end


---@class List
List = {}
List.__index = List;
---@return List
function List.new()
	local self = setmetatable({}, List)

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
---@param list table|nil
---@return List
function List.from(list)
	local self = List.new()
	if list then
		for i,v in ipairs(list) do
			self[i] = v
		end
	end
	return self
end
setmetatable(List, { __call = List.from })

---@param value table
---@return List
function List:__add(value)
	if type(value) ~= 'table' then
		error("'table' is not table type")
	end
	local result = self:clone()
	result:join(value)
	return result
end
---@param times number
---@return List
function List:__mul(times)
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
function List:__tostring()
	return self:show()
end

---@return List
function List:clone()
	if not self then error("List: missing 'self', call using ':'") end
	local result = List.new()
	for v in each(self) do
		result:append(v)
	end
	return result
end
---@return string
function List:show()
	if not self then error("List: missing 'self', call using ':'") end
	local result = '[ '
	for v in each(self) do
		result = result..string.format('%s , ',tostring(v))
	end
	result = string.sub(result,1,string.len(result)-3)..' ]'
	return result
end
---@param value table
---@param index number|nil
---@return List
function List:join(value, index)
	if not self then error("List: missing 'self', call using ':'") end
	if not value then error("List: missing 'value'") end
	index = index or #self + 1
	if type(value) ~= 'table' then
		error("'value' is not table type")
	end
	for i,v in ipairs(value) do
		table.insert(self, index+i-1, v)
	end
	return self
end
---@param index number|nil
---@param length number|nil
---@return List
function List:remove(index, length)
	if not self then error("List: missing 'self', call using ':'") end
	index = index or #self
	length = length or 1
	for i in range(length) do
		table.remove(self, index)
	end
	return self
end
---@param value any
---@param index number|nil
---@return List
function List:append(value, index)
	return self:join({value}, index)
end
---@param start number|nil
---@param stop number|nil
---@param step number|nil
---@return List
function List:inter(start, stop, step)
	if not self then error("List: missing 'self', call using ':'") end
	local start = start or 1
	local stop = stop or #self
	local step = step or 1
	return List.create(range(start, stop, step), function(v) return self[v] end)
end
---@param comp function
---@return List
function List:sort(comp)
	if not self then error("List: missing 'self', call using ':'") end
	if not comp then error("List: missing 'comp'") end
	table.sort(self, comp)
	return self
end
