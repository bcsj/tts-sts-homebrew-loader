function isCoreGameMod()
    local boot_meeple = getObjectFromGUID("d4e0e6")
    if boot_meeple ~= nil then
        return true
    end
    return false
end

function isDownfallGameMod()
    local hat_meeple = getObjectFromGUID("668988")
    if hat_meeple ~= nil then
        return true
    end
    return false
end