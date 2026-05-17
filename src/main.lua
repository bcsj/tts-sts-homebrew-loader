require("tts-sts-homebrew-loader/src/sts-mod-loans")
require("tts-sts-homebrew-loader/src/clean-up-characters")
require("tts-sts-homebrew-loader/src/util")

-- custom_char_SETUP_BOARD --
function onLoad()
    createButtons()
end

function createButtons()
    self.createButton({
        click_function = "setupWrapper",
        function_owner = self,
        label          = "Setup",
        position       = {0, 0.0, -10.5},
        rotation       = {0, 0, 0},
        --scale          = {1/self.getScale()[1], 1/self.getScale()[2], 1/self.getScale()[3]},
        width          = 3500,
        height         = 700,
        tooltip        = "",
        font_color     = {1, 1, 1},
        font_size      = 500,
        color          = "Grey"
    })
end

function setupWrapper(obj, color, alt_click)
    getObjectsAsync(setup, {color})
end

function getHomebrewBag(obj)
    local top_obj_guid = getObjectGUIDOnTop(obj);
    return getObjectFromGUID(top_obj_guid);
end

function getGameObject(color, type)
    local PLAYER_TO_CHARACTER = Global.getVar("PLAYER_TO_CHARACTER")
    local CHARACTER_INFO = Global.getVar("CHARACTER_INFO")
    return getObjectFromGUID(CHARACTER_INFO[PLAYER_TO_CHARACTER[color]][type])
end

function getNameOfReplacedCharacter(color)
    local PLAYER_TO_CHARACTER = Global.getVar("PLAYER_TO_CHARACTER")
    return PLAYER_TO_CHARACTER[color]
end

function setup(obj, args)
    -- input arg, color is the player who clicks the button, I call them the "Active Player" from here on
    local color = args[1]

    -- Detect custom_char bag on top
    local custom_char_bag = getHomebrewBag(obj)

    -- Get a list of all the stuff in the bag
    local custom_char_objs = custom_char_bag.getObjects()
    --[[for i = 1, #custom_char_objs do
        print(custom_char_objs[i].guid)
        log(custom_char_objs[i])
    end--]]

    -- Get Board and Bag objects
    local player_curr_board = getGameObject(color, "Board")
    local player_curr_bag = getGameObject(color, "Bag")
    local CHARACTER_NAME = player_curr_board.getVar("CHARACTER_NAME")

    -- Get Standee, Playmat
    local player_curr_standee = getObjectFromGUID(player_curr_board.getVar("STANDEE_GUID"))
    local player_curr_playmat = getObjectFromGUID(player_curr_board.getVar("PLAYMAT_GUID"))

    -- Get Cubes, Decks guids
    local player_curr_cube_guids = player_curr_board.getVar("CUBE_GUIDS")
    local player_curr_deck_guids = player_curr_board.getVar("DECK_GUIDS")

    -- Get the object positions and rotation
    local playmat_pos = player_curr_playmat.getPosition()
    local playmat_rot = player_curr_playmat.getRotation()
    local board_pos = player_curr_board.getPosition()
    local board_rot = player_curr_board.getRotation()
    local standee_pos = player_curr_standee.getPosition()
    local standee_rot = player_curr_standee.getRotation()

    -- Clean up extra tokens and stuff depending on who the Active player's character is
    local replaced_character = getNameOfReplacedCharacter(color)
    cleanUpCharacter(color)

    -- Replace playmat, board, standee
    player_curr_bag.putObject(player_curr_playmat)
    player_curr_bag.putObject(player_curr_board)
    player_curr_bag.putObject(player_curr_standee)

    local n = #custom_char_objs
    custom_char_bag.takeObject({
        guid = custom_char_objs[n].guid,
        position = standee_pos,
        rotation = standee_rot,
    })
    
    custom_board = custom_char_bag.takeObject({
        guid = custom_char_objs[n-5].guid,
        position = board_pos,
        rotation = board_rot,
        callback_function=function(obj)
            obj.setVar("CHARACTER_NAME", CHARACTER_NAME)
        end
    })
    custom_board.setLock(true)

    custom_playmat = custom_char_bag.takeObject({
        guid = custom_char_objs[n-6].guid,
        position = playmat_pos,
        rotation = playmat_rot,
        callback_function=function(obj)
            local playMatScale = obj.getScale()
            obj.setSnapPoints({
            {position = {-1.35/playMatScale[1], 0, 1.92/playMatScale[3]}, rotation_snap = true},    -- Draw
            {position = {-2.37/playMatScale[1], 0, 1.92/playMatScale[3]}, rotation_snap = true},    -- Discard
            {position = {2.37/playMatScale[1], 0, 1.92/playMatScale[3]}, rotation_snap = true},     -- Exhaust
            })
        end
    })
    custom_playmat.setLock(true)

    -- We just seem to need to do a 180 rotation extra here for some things, not centirely clear to me why
    local pos_rot = board_rot[2] - 180

    -- Replace cubes
    for i = 1, #player_curr_cube_guids do
        local cube = getObjectFromGUID(player_curr_cube_guids[i])
        local cube_pos = cube.getPosition()
        if i == #player_curr_cube_guids then
            -- The health cube might be in a different spot than we need, 
            -- e.g. because Ironclad has more health, so we se it at a fixed offset
            local offset = {
                - 3.47 + 8 * 0.509,
                0,
                -1.20
            }
            -- We need to take any board rotation into account
            local local_x_offset = offset[1] * math.cos(math.rad(pos_rot)) + offset[3] * math.sin(math.rad(pos_rot))
            local local_z_offset = offset[3] * math.cos(math.rad(pos_rot)) - offset[1] * math.sin(math.rad(pos_rot))
            cube_pos[1] = board_pos[1] + local_x_offset
            cube_pos[3] = board_pos[3] + local_z_offset
        end
        cube_pos[2] = cube_pos[2] + 1

        player_curr_bag.putObject(cube)
        custom_char_bag.takeObject({
            guid = custom_char_objs[n-i].guid,
            position = cube_pos,
            rotation = board_rot
        })
    end

    --Position custom tokens bag
    local offset = {
        2.07,
        1,
        0.31
    }
    -- We need to take any board rotation into account
    local local_x_offset = offset[1] * math.cos(math.rad(pos_rot)) + offset[3] * math.sin(math.rad(pos_rot))
    local local_z_offset = offset[3] * math.cos(math.rad(pos_rot)) - offset[1] * math.sin(math.rad(pos_rot))
    local tokens_bag_pos = {
        board_pos[1] + local_x_offset,
        board_pos[2] + 1,
        board_pos[3] + local_z_offset
    }
    custom_char_bag.takeObject({
        guid = custom_char_objs[n-4].guid,
        position = tokens_bag_pos,
        rotation = board_rot
    })

    -- Decks
    local starter_deck = getObjectFromGUID(player_curr_deck_guids["Starter"]["Base"])
    local reward_deck = getObjectFromGUID(player_curr_deck_guids["Rewards"]["Base"])
    local rare_deck = getObjectFromGUID(player_curr_deck_guids["Rare"]["Base"])
    
    local upg_deck = getObjectFromGUID(player_curr_deck_guids["Starter"]["Upgrades"])

    local starter_pos = starter_deck.getPosition()
    local discard_pos = {
        starter_pos[1] + 3.0,
        starter_pos[2],
        starter_pos[3]
    }
    local reward_pos = reward_deck.getPosition()
    reward_pos[2] = reward_pos[2] + 1
    local rare_pos = rare_deck.getPosition()
    rare_pos[2] = rare_pos[2] + 1
    local upg_pos = upg_deck.getPosition()
    upg_pos[2] = upg_pos[2] + 1

    local starter_rot = starter_deck.getRotation()
    local reward_rot = reward_deck.getRotation()
    local rare_rot = rare_deck.getRotation()
    local upg_rot = upg_deck.getRotation()

    player_curr_bag.putObject(starter_deck)
    player_curr_bag.putObject(reward_deck)
    player_curr_bag.putObject(rare_deck)
    player_curr_bag.putObject(upg_deck)

    -- decks
    local custom_char_starter_deck_guid = custom_char_objs[n-7].guid
    local custom_char_starter_deck_upg_guid = custom_char_objs[n-8].guid
    local custom_char_reward_deck_guid = custom_char_objs[n-9].guid
    local custom_char_reward_deck_upg_guid = custom_char_objs[n-10].guid
    local custom_char_rare_deck_guid = custom_char_objs[n-11].guid
    local custom_char_rare_deck_upg_guid = custom_char_objs[n-12].guid
    
    -- Rare deck --------------------------------------
    local custom_char_rare_deck = custom_char_bag.takeObject({
        guid = custom_char_rare_deck_guid,
        position = starter_pos,
        rotation = starter_rot
    })
    local custom_char_rare_deck_upg = custom_char_bag.takeObject({
        guid = custom_char_rare_deck_upg_guid,
        position = discard_pos,
        rotation = starter_rot
    })

    -- Wait for the decks to both be loaded, then run the above callback to associate cards with their upgrades
    local awaited_decks = {
        custom_char_rare_deck, 
        custom_char_rare_deck_upg
    }
    whenReady(awaited_decks, function()
        assocUpgrades(custom_char_rare_deck, custom_char_rare_deck_upg)
        custom_char_rare_deck.flip()
        custom_char_rare_deck_upg.flip()
        custom_char_rare_deck.shuffle()
        custom_char_rare_deck.setPosition(rare_pos)
        custom_char_rare_deck.setRotation(rare_rot)
        custom_char_rare_deck_upg.setPosition(upg_pos)
        custom_char_rare_deck_upg.setRotation(upg_rot)
    end)

    -- Reward deck --------------------------------------
    local custom_char_reward_deck = custom_char_bag.takeObject({
        guid = custom_char_reward_deck_guid,
        position = starter_pos,
        rotation = starter_rot
    })
    local custom_char_reward_deck_upg = custom_char_bag.takeObject({
        guid = custom_char_reward_deck_upg_guid,
        position = discard_pos,
        rotation = starter_rot
    })

    -- Wait for the decks to both be loaded, then run the above callback to associate cards with their upgrades
    local awaited_decks = {
        custom_char_reward_deck, 
        custom_char_reward_deck_upg
    }
    whenReady(awaited_decks, function()
        assocUpgrades(custom_char_reward_deck, custom_char_reward_deck_upg)
        custom_char_reward_deck.flip()
        custom_char_reward_deck_upg.flip()
        custom_char_reward_deck.shuffle()
        custom_char_reward_deck.setPosition(reward_pos)
        custom_char_reward_deck.setRotation(reward_rot)
        custom_char_reward_deck_upg.setPosition(upg_pos)
        custom_char_reward_deck_upg.setRotation(upg_rot)
    end)

    -- Starter deck --------------------------------------
    local custom_char_starter_deck = custom_char_bag.takeObject({
        guid = custom_char_starter_deck_guid,
        position = starter_pos,
        rotation = starter_rot
    })
    local custom_char_starter_deck_upg = custom_char_bag.takeObject({
        guid = custom_char_starter_deck_upg_guid,
        position = discard_pos,
        rotation = starter_rot
    })

    -- Wait for the decks to both be loaded, then run the above callback to associate cards with their upgrades
    local awaited_decks = {
        custom_char_starter_deck, 
        custom_char_starter_deck_upg, 
    }
    whenReady(awaited_decks, function()
        assocUpgrades(custom_char_starter_deck, custom_char_starter_deck_upg)
        custom_char_starter_deck.flip()
        custom_char_starter_deck_upg.flip()
        custom_char_starter_deck.setPosition(starter_pos)
        custom_char_starter_deck.setRotation(starter_rot)
        custom_char_starter_deck_upg.setPosition(upg_pos)
        custom_char_starter_deck_upg.setRotation(upg_rot)     
    end)

    -- Make the bag and setup boards remove themselves
    custom_char_bag.destruct()
    self.destruct()

end

-- Upgrade association wrapper
function assocUpgrades(deck, deck_upg)
    local cards = deck.getObjects()
    local cards_upg = deck_upg.getObjects()

    for i = 1, #cards do
        StoreCardAssociation(cards[i].guid, deck.getGUID(), cards_upg[i].guid, deck_upg.getGUID())
    end
end
