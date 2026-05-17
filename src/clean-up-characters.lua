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

function putAway(bag, guids)
    for i = 1, #guids do
        bag.putObject(getObjectFromGUID(guids[i]))
    end
end

function cleanUpCharacter(color)
    local character = getNameOfReplacedCharacter(color)
    local board = getGameObject(color, "Board")
    local bag = getGameObject(color, "Bag")

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