function getSilentObjects(board)
    local dagger_guids = board.getVar("DAGGER_GUIDS")
    local decay_guids = board.getVar("DECAY_GUIDS")
    local decay_single_guids = decay_guids["Single"]["Tokens"]
    local decay_five_guids = decay_guids["Five"]["Tokens"]
    local decay_ten_guids = decay_guids["Ten"]["Tokens"]

    local all_guids = {}
    concatTables(all_guids, dagger_guids)
    concatTables(all_guids, decay_single_guids)
    concatTables(all_guids, decay_five_guids)
    concatTables(all_guids, decay_ten_guids)

    return all_guids
end

function getDefectObjects(board)
    local elemental_cube_guid = board.getVar("ELEMENTAL_CUBE_GUID")
    local elemental_cube_guids = board.getVar("ELEMENTAL_CUBE_GUIDS")
    
    local all_guids = {}
    all_guids[1] = elemental_cube_guid
    concatTables(all_guids, elemental_cube_guids["Dark"])
    concatTables(all_guids, elemental_cube_guids["Frost"])
    concatTables(all_guids, elemental_cube_guids["Lightning"])
    
    return all_guids
end

function getWatcherObjects(board)
    local align_cube_guid = board.getVar("ALIGNMENT_CUBE_GUID")
    local miracle_guids = board.getVar("MIRACLE_GUIDS")

    local all_guids = {}
    all_guids[1] = align_cube_guid
    concatTables(all_guids, miracle_guids)

    return all_guids
end

function getGuardianObjects(board)
    local align_cube_guid = board.getVar("ALIGNMENT_CUBE_GUID")
    local vigor_guids = board.getVar("VIGOR_GUIDS")

    --local gemify_tool_guid = Global.getVar("GEMIFY_TOOL")
    -- The gemify tool is a clone of the original, so it has a random id
    -- No immediate good way to get it
    -- The best idea so far is to create a temp zone around the position
    -- of it, which we should be able to compute like how the setup in the
    -- board code does it, then get all objects in that zone whioch should
    -- just be the gemify tool, and get its guid 

    local decks = board.getTable("DECK_GUIDS")
    local gem_deck_guid = decks["Gem"]

    -- We should also remove the "Gem Deck" text somehow

    local all_guids = {
        align_cube_guid, 
        --gemify_tool_guid, 
        gem_deck_guid
    }
    concatTables(all_guids, vigor_guids)

    return all_guids
end

function getHexaghostObjects(board)
    local soulburn_guid = board.getVar("SOULBURN_GUIDS")
    local wheel_cube_guid = board.getVar("WHEEL_CUBE_GUID")

    local all_guids = {wheel_cube_guid}
    concatTables(all_guids, soulburn_guid)

    return all_guids
end


function getSlimeBossObjects(board)
    local bruiser_slime_guid = "7a5ae2"
    -- BRUISER_SLIME_GUID -- seems they don't use this variable

    local all_guids = {bruiser_slime_guid}

    return all_guids
end

function putAway(bag, guids)
    for i = 1, #guids do
        bag.putObject(getObjectFromGUID(guids[i]))
    end
end

function cleanUpCharacter(color)
    local character = getNameOfReplacedCharacter(color)
    local board = getGameObject(color, "Board")
    local bag = getGameObject(color, "Bag")

    if isCoreGameMod() then
        if character == "Silent" then
            putAway(bag, getSilentObjects(board))
        end

        if character == "Defect" then
            putAway(bag, getDefectObjects(board))
        end

        if character == "Watcher" then
            putAway(bag, getWatcherObjects(board))
        end
    end

    -- The character boards have just been skinned over and
    -- have the original game character's names, so we need
    -- to check the mod version to know how to treat each.
    if isDownfallGameMod() then
        -- Guardian
        if character == "Silent" then
            putAway(bag, getGuardianObjects(board))
        end

        -- Hexaghost
        if character == "Defect" then
            putAway(bag, getHexaghostObjects(board))
        end

        -- Slime Boss
        if character == "Watcher" then
            putAway(bag, getSlimeBossObjects(board))
        end
    end
end