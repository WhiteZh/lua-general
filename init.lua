List = {
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
					error('must be a number!')
				end
				if times <= 0 or times % 1 ~= 0 then
					error('whole number onlyl!')
				end
				local result = self:new()
				for _ in range(times) do
					result = result + self
				end
				return result
			end,
		}
		return setmetatable(o or {}, metatable)
	end,
	create = function(self, iter)

	end,
	clone = function(self)
		if not self then return end
		local result = self:new()
		for i,v in ipairs(self) do
			result:append(v)
		end
		return result
	end,
	show = function(self)
		if not self then return end
		local result = '[ '
		for i,v in ipairs(self) do
			result = result..string.format('%s , ',tostring(v))
		end
		result = string.sub(result,1,string.len(result)-3)..' ]'
		return result
	end,
	append = function(self, value, time, index)
		if not self or not value then return end
		index = index or #self + 1
		time = time or 1
		for i=#self+time,#self+1,-1 do
			self[i] = self[i - time]
		end
		for i=index,index+time-1 do
			self[i] = value
		end
	end,
	remove = function(self, index, length)
		if not self then return end
		index = index or #self
		if length == nil then
			length, index = index, #self
			index = index - length + 1
		end
		for i=index,#self do
			self[i] = self[i+length]
		end
	end,
}

range = function(start, stop, step)
	if step == 0 then return function() return nil  end end
	step = step or 1
	if not stop then
		stop = start
		start = 1
	end
	local iter = start - step
	return function()
		iter = iter + step
		return (iter - stop) * step <= 0 and iter or nil
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
