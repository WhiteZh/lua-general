require 'lua-general'

local statistic = {}

statistic.mean = function(list)
    local sum = 0
    for v in each(list) do
        sum = sum + v
    end
    return sum / #list
end

statistic.quantile = function(list, q)
    local qf = math.floor(q) * (#list - 1) + 1
    local qc = math.ceil(q) * (#list - 1) + 1
    local qq = (list[qc] - list[qf]) * (q - math.floor(q)) + list[qf]
    return qq
end

statistic.q1 = function(list)
    local middle = (math.floor((#list + 1) / 2) + 1) / 2
    if middle % 1 == 0 then
        return list[middle]
    else
        return list[middle - 0.5] / 2 + list[middle + 0.5] / 2
    end
end

statistic.q2 = function(list)
    local middle = (#list + 1) / 2
    if middle % 1 == 0 then
        return list[middle]
    else
        return list[middle - 0.5] / 2 + list[middle + 0.5] / 2
    end
end

statistic.q3 = function(list)
    local middle = (math.ceil((#list + 1) / 2) + #list) / 2
    if middle % 1 == 0 then
        return list[middle]
    else
        return list[middle - 0.5] / 2 + list[middle + 0.5] / 2
    end
end

statistic.mode = function(list)
    local list = list:new(list):sort()
    local modes = list:new()
    local max = 2
    local count = 0
    local crt
    for v in each(list) do
        if crt ~= v then
            if count > max then
                modes = list:new()
                max = count
            end
            if count == max then
                modes:append(crt)
            end
            crt = v
            count = 0
        end
        count = count + 1
    end
    if count > max then
        modes = list:new()
        max = count
    end
    if count == max then
        modes:append(crt)
    end
    return #modes * max == #list and list:new() or modes
end

statistic.ir = function(list)
    return statistic.q3(list) - statistic.q1(list)
end

statistic.psd = function(list)
    local sm = statistic.mean(list)
    local result = 0
    for i, v in ipairs(list) do
        result = result + math.pow(v - sm, 2)
    end
    result = result / (#list)
    result = math.sqrt(result)
    return result
end

statistic.ssd = function(list)
    local sm = statistic.mean(list)
    local result = 0
    for i, v in ipairs(list) do
        result = result + math.pow(v - sm, 2)
    end
    result = result / (#list - 1)
    result = math.sqrt(result)
    return result
end


statistic.show = function(list)
    print(list.show(list))
end

statistic.anal = function(list)
    print(string.format('Mean: %f', (statistic.mean(list))))
    print(string.format('Median: %f', (statistic.median(list))))
    print(string.format('Q1: %f', (statistic.q1(list))))
    print(string.format('Q3: %f', (statistic.q3(list))))
    print(string.format('Mode(s): '..statistic.mode(list):show()))
    print(string.format('IR: %f', (statistic.ir(list))))
    print(string.format('PSD: %f', (statistic.psd(list))))
    print(string.format('SSD: %f', (statistic.ssd(list))))
end

statistic.median = statistic.q2

return statistic