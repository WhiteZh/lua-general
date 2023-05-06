require 'lua-general/List'

range = function(...)
	local paramCount = select('#', ...)
	local start = 1
	local stop = 1
	local step = 1

	if paramCount == 0 then
		return
	elseif paramCount == 1 then
		stop = select('1', ...)
	elseif paramCount == 2 then
		start = select('1', ...)
		stop = select('2', ...)
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
		print(string.format('%.64f', iter))
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
