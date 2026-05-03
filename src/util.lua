function when(condition, callback)
    Wait.condition(callback, condition)
end

function whenReady(objects, callback)
    when(isDoneSpawningOrLoading(objects), callback)
end