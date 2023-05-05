require 'general'

statistic = {

    mean = function(list)
        local sum = 0
        local count
        for i, v in pairs(list) do
            sum = sum + v
            count = i
        end
        return sum / count
    end,

    quantile = function(list, q)
        local qf = math.floor(q) * (#list - 1) + 1
        local qc = math.ceil(q) * (#list - 1) + 1
        local qq = (list[qc] - list[qf]) * (q - math.floor(q)) + list[qf]
        return qq
    end,

    q1 = function(list)
        local middle = (math.floor((#list + 1) / 2) + 1) / 2
        if middle % 1 == 0 then
            return list[middle]
        else
            return list[middle - 0.5] / 2 + list[middle + 0.5] / 2
        end
    end,

    q2 = function(list)
        local middle = (#list + 1) / 2
        if middle % 1 == 0 then
            return list[middle]
        else
            return list[middle - 0.5] / 2 + list[middle + 0.5] / 2
        end
    end,

    q3 = function(list)
        local middle = (math.ceil((#list + 1) / 2) + #list) / 2
        if middle % 1 == 0 then
            return list[middle]
        else
            return list[middle - 0.5] / 2 + list[middle + 0.5] / 2
        end
    end,

    mode = function(list)
        local ret = {}
        local ret_ptr = 0
        local current = nil
        local max = 0
        for i, v in ipairs(list) do
            if current ~= v then
                if ret_ptr ~= 0 and ret[ret_ptr].value > max then
                    max = ret[ret_ptr].value
                end
                current = v
                ret_ptr = ret_ptr + 1
                ret[ret_ptr] = { key = v, value = 1 }
            else
                ret[ret_ptr].value = ret[ret_ptr].value + 1
            end
        end

        local ret2 = {}
        for i, v in ipairs(ret) do
            if v.value == max then
                table.insert(ret2, 1, v.key)
            end
        end

        ret = ret2

        if #ret == #list then
            ret = {}
        end

        return List:new(ret)
    end,

    ir = function(list)
        return statistic.q3(list) - statistic.q1(list)
    end,

    psd = function(list)
        local sm = statistic.mean(list)
        local result = 0
        for i, v in ipairs(list) do
            result = result + math.pow(v - sm, 2)
        end
        result = result / (#list)
        result = math.sqrt(result)
        return result
    end,

    ssd = function(list)
        local sm = statistic.mean(list)
        local result = 0
        for i, v in ipairs(list) do
            result = result + math.pow(v - sm, 2)
        end
        result = result / (#list - 1)
        result = math.sqrt(result)
        return result
    end,


    showl = function(list)
        List:new(list):show()
    end,

    anal = function(list)
        print(string.format('Mean: %f', (statistic.mean(list))))
        print(string.format('Median: %f', (statistic.median(list))))
        print(string.format('Q1: %f', (statistic.q1(list))))
        print(string.format('Q3: %f', (statistic.q3(list))))
        print(string.format('Mode: '))
        statistic.showl(statistic.mode(list))
        print(string.format('IR: %f', (statistic.ir(list))))
        print(string.format('PSD: %f', (statistic.psd(list))))
        print(string.format('SSD: %f', (statistic.ssd(list))))
    end,

}

statistic.median = statistic.q2

return statistic