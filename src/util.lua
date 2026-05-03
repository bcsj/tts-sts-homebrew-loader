function when(condition, callback)
    Wait.condition(callback, condition)
end

function whenReady(objects, callback)
    when(isDoneSpawningOrLoading(objects), callback)
end

function isDoneSpawningOrLoading(objects)
    return function()
        local check = true
        for _, obj in pairs(objects) do
            if obj.spawning or obj.loading_custom then
                check = false
                break
            end
        end
        return check
    end
end