function cleanUpCharacter(color)
    local character = getNameOfReplacedCharacter(color)
    local board = getGameObject(color, "Board")
    local bag = getGameObject(color, "Bag")
    
    log(character .. " is being cleaned up.")
    if character == "Silent" then
        local dagger_guids = board.getVar("DAGGER_GUIDS")
        for i = 1, #dagger_guids do
            bag.putObject(getObjectFromGUID(dagger_guids[i]))
        end
        local decay_guids = board.getVar("DECAY_GUIDS")
        local decay_single_guids = decay_guids["Single"]["Tokens"]
        for i = 1, #decay_single_guids do
            bag.putObject(getObjectFromGUID(decay_single_guids[i]))
        end
        local decay_five_guids = decay_guids["Five"]["Tokens"]
        bag.putObject(getObjectFromGUID(decay_five_guids[1]))
        bag.putObject(getObjectFromGUID(decay_five_guids[2]))
        local decay_ten_guids = decay_guids["Ten"]["Tokens"]
        bag.putObject(getObjectFromGUID(decay_ten_guids[1]))
    end

     if character == "Defect" then
        local elemental_cube_guid = board.getVar("ELEMENTAL_CUBE_GUID")
        bag.putObject(getObjectFromGUID(elemental_cube_guid))
        local elemental_cube_guids = board.getVar("ELEMENTAL_CUBE_GUIDS")
        for i = 1, #elemental_cube_guids["Dark"] do
            bag.putObject(getObjectFromGUID(elemental_cube_guids["Dark"][i]))
        end
        for i = 1, #elemental_cube_guids["Frost"] do
            bag.putObject(getObjectFromGUID(elemental_cube_guids["Frost"][i]))
        end
        for i = 1, #elemental_cube_guids["Lightning"] do
            bag.putObject(getObjectFromGUID(elemental_cube_guids["Lightning"][i]))
        end
    end

     if character == "Watcher" then
        local align_cube_guid = board.getVar("ALIGNMENT_CUBE_GUID")
        bag.putObject(getObjectFromGUID(align_cube_guid))
        local miracle_guids = board.getVar("MIRACLE_GUIDS")
        for i = 1, #miracle_guids do
            bag.putObject(getObjectFromGUID(miracle_guids[i]))
        end
    end
end