List = {
	new = function(self, o)
		self.__index = self
		return setmetatable(o or {}, self)
	end,
	copy = function(self)
		local tmp ={}
		for i,v in ipairs(self) do
			table.insert(tmp, #tmp + 1, v)
		end
		return tmp
	end,
	set = function(self, target)
		for i,v in ipairs(self) do
			self[i] = nil
		end
		for i=1,#target do
			self[i] = target[i]
		end
	end,
	show = function(self)
		local result = '[ '
		for i,v in ipairs(self) do
			result = result..string.format('%s , ',tostring(v))
		end
		result = string.sub(result,1,string.len(result)-3)..' ]'
		return result
	end,
	append = function(self, value, time, index)
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
		index = index or #self
		if length == nil then
			length, index = index, #self
			index = index - length + 1
		end
		for i=index,#self do
			self[i] = self[i+length]
		end
	end,
	__add = function(this, that)
		if type(that) ~= 'table' then
			that = {that}
		end
		local result = List.copy(this)
		for i=1,#that do
			table.insert(result, #result + 1, that[i])
		end
		return result
	end,
	__mul = function(this, that)
		if type(that) ~= 'number' then
			error('must be a number!')
		end
		if that <= 0 or that % 1 ~= 0 then
			error('whole number onlyl!')
		end
		local result = {}
		for i=1,that do
			result = List.__add(result, this)
		end
		return result
	end,
}

range = function(s,e,g)
	if g == 0 then return function() return nil  end end
	g = g or 1
	if not e then
		e = s
		s = 1
	end
	local iter = s - g
	return function()
		iter = iter + g
		return (iter - e) * g <= 0 and iter or nil
	end
end

rerequire = function(name)
	package.loaded[name] = nil
	require(name)
end

os.clear = function()
	os.execute('clear')
end

os.cls = function()
	os.execute('cls')
end
