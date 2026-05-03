-- ############################################################################################
-- Shamelessly taken and adapted from the StS mod script
-- ############################################################################################
-- I got this function from the StS mod, but had to manually pull the global 
-- variable with the card upgrade information, modify it and then put it back updated.
function StoreCardAssociation(baseCardGuid, baseDeckGuid, upgradeCardGuid, upgradeDeckGuid)
    local CARD_UPGRADE_INFO = Global.getTable("CARD_UPGRADE_INFO")
    CARD_UPGRADE_INFO[baseCardGuid] = {}
    CARD_UPGRADE_INFO[baseCardGuid]["Related_Card"] = upgradeCardGuid
    CARD_UPGRADE_INFO[baseCardGuid]["Source_Deck"] = baseDeckGuid
    CARD_UPGRADE_INFO[baseCardGuid]["Card_Type"] = "Base"

    CARD_UPGRADE_INFO[upgradeCardGuid] = {}
    CARD_UPGRADE_INFO[upgradeCardGuid]["Related_Card"] = baseCardGuid
    CARD_UPGRADE_INFO[upgradeCardGuid]["Source_Deck"] = upgradeDeckGuid
    CARD_UPGRADE_INFO[upgradeCardGuid]["Card_Type"] = "Upgrade"
    Global.setTable("CARD_UPGRADE_INFO", CARD_UPGRADE_INFO)
end

-- Retrieves objects on the tool and calls the associated callback with the results. Does this by spawning a temporary scripting zone on each area and getting objects
function getObjectsAsync(callback_function, callback_func_args)
    -- Internal coroutine
    function setupScriptingZonesInternal()
        local object_scale = self.getScale()
        local expected_scale = {0.22, 0.22, 0.22}
        local base_scale = {2.46, 2, 3.38}
        local scale_factor = {object_scale[1] / expected_scale[1], object_scale[2] / expected_scale[2], object_scale[3] / expected_scale[3]}
        local target_scale = {scale_factor[1] * base_scale[1], scale_factor[2] * base_scale[2], scale_factor[3] * base_scale[3]}

        local zone = createScriptingZone(getSlotPosition(), self.getRotation(), target_scale)

        callback_function(zone.getObjects(), callback_func_args)

        zone.destruct()
        return 1
    end

    startLuaCoroutine(self, "setupScriptingZonesInternal")
end

function getSlotPosition()
        local X_OFFSET = 0
        local Z_OFFSET = 0.135
        local object_scale = self.getScale()
        local expected_scale = {0.18, 0.18, 0.18}
        local base_scale = {2.46, 2, 3.38}
        local scale_factor = {object_scale[1] / expected_scale[1], object_scale[2] / expected_scale[2], object_scale[3] / expected_scale[3]}
        local target_scale = {scale_factor[1] * base_scale[1], scale_factor[2] * base_scale[2], scale_factor[3] * base_scale[3]}
    
        local base_pos = self.getPosition()
    
        local local_x_offset = (X_OFFSET * scale_factor[1]) * math.cos(math.rad(self.getRotation()[2])) + (Z_OFFSET * scale_factor[3]) * math.sin(math.rad(self.getRotation()[2]))
        local local_z_offset = (Z_OFFSET * scale_factor[3]) * math.cos(math.rad(self.getRotation()[2])) - (X_OFFSET * scale_factor[1]) * math.sin(math.rad(self.getRotation()[2]))
        local pos = {base_pos.x + local_x_offset, base_pos.y, base_pos.z + local_z_offset}
        return pos
end

function createScriptingZone(position, rot, scale)
    local zone = spawnObject({type='ScriptingTrigger', position=position, rotation=rot, scale=scale})
    repeat
        coroutine.yield(0)
    until zone.getGUID() ~= nil
    return zone
end

-- Takes a list of objects and returns the one on top. Optional if you require that the object is face up
function getObjectGUIDOnTop(objList, requireFaceup)
    local topObj = nil
    for _, obj in ipairs(objList) do
        if topObj == nil or obj.getPosition().y > topObj.getPosition().y then
            if not requireFaceup or (obj.getRotation().z > 135 or obj.getRotation().z < -135) then
            topObj = obj
            end
        end
    end

    if topObj.name == "Deck" or topObj.name == "DeckCustom" then
        if topObj.getRotation().z > 135 or topObj.getRotation().z < -135 then
            return topObj.getObjects()[1].guid
        else
            return topObj.getObjects()[#topObj.getObjects()].guid
        end
    end

    return topObj.getGUID()
end