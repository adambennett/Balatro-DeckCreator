local Utils = require "Utils"
local CustomDeck = require "CustomDeck"
local ModloaderHelper = require "ModloaderHelper"

local Persistence = {}
local filename = "CustomDecks.txt"
local RedSealFilename = "Red_Seal_Messages.txt"

local function serializeDeck(val, depth)
    local temp = string.rep(" ", depth)

    if type(val) == "table" then
        temp = temp .. "{\n"
        local entries = {}
        for k, v in pairs(val) do
            local entry = string.rep(" ", depth + 1)
            if type(k) == "string" then
                entry = entry .. "[" .. string.format("%q", k) .. "] = "
            end
            entry = entry .. serializeDeck(v, depth + 2)
            table.insert(entries, entry)
        end
        temp = temp .. table.concat(entries, ",\n")  -- Concatenating with comma separator
        temp = temp .. "\n" .. string.rep(" ", depth) .. "}"
    else
        if type(val) == "string" then
            temp = temp .. string.format("%q", val)
        else
            temp = temp .. tostring(val)
        end
    end
    return temp
end

function Persistence.saveAllDecks()
    local directory = "Mods/Deck Creator/Custom Decks"
    local filePath = directory .. "/" .. filename
    local serialized = serializeDeck(Utils.customDeckList, 0)
    love.filesystem.write(filePath, serialized)
    Utils.log("All custom decks saved")
end

function Persistence.loadAllDeckLists()
    local directory = "Mods/Deck Creator/Custom Decks"
    local files = love.filesystem.getDirectoryItems(directory)

    Utils.customDeckList = {}
    local deckNames = {}
    local loadedUUIDs = {}

    for _, file in ipairs(files) do
        if string.sub(file, -4) == ".txt" then  -- Check if the file is a .txt file
            local filePath = directory .. "/" .. file
            local fileContent = love.filesystem.read(filePath)

            local func, err = loadstring("return " .. fileContent)
            if func then
                local allDecks = func()
                for _, deckConfig in ipairs(allDecks) do

                    if deckConfig.config.uuid == nil or loadedUUIDs[deckConfig.config.uuid] == nil then
                        local baseName = deckConfig.name
                        local count = deckNames[baseName] or 0
                        deckNames[baseName] = count + 1
                        if count > 0 then
                            deckConfig.name = baseName .. " "
                            deckConfig.loc_txt.name = deckConfig.name
                            deckConfig.slug = deckConfig.name
                        end
                        local loadedDeck = CustomDeck.createCustomDeck(deckConfig.name, deckConfig.slug, deckConfig.config, deckConfig.spritePos, deckConfig.loc_txt)
                        local blankCheck = CustomDeck:blankDeck()
                        for k,v in pairs(blankCheck.config) do
                            if loadedDeck.config[k] == nil then
                                loadedDeck.config[k] = v
                            end
                        end

                        if loadedDeck.config.extra_discard_bonus == 0 then
                            loadedDeck.config.extra_discard_bonus = nil
                        end
                        if loadedDeck.config.rawDescription ~= nil then
                            local descTable = CustomDeck.parseRawDescription(loadedDeck.config.rawDescription)
                            Utils.log("Parsed rawDescription from imported deck\n" .. Utils.tableToString(descTable))
                            loadedDeck = CustomDeck.fullNewFromExisting(loadedDeck, descTable, false)
                            G.localization.descriptions["Back"][deckConfig.slug] = loadedDeck.loc_txt
                        end
                        Utils.addDeckToList(loadedDeck)
                        Utils.log("Loaded deck loc_txt\n" .. Utils.tableToString(G.localization.descriptions["Back"][deckConfig.slug]))
                        loadedUUIDs[loadedDeck.config.uuid] = true
                    end
                end
            else
                Utils.log("Could not deserialize custom deck data from " .. file .. ": " .. err)
            end
        end
    end

    if #Utils.customDeckList == 0 then
        Utils.log("No decks loaded from any files")
    else
        Utils.log(Utils.tableLength(Utils.customDeckList) .. " custom decks loaded")
        Persistence.refreshDeckList()
    end
end

function Persistence.refreshDeckList()
    local minId = 17
    local id = 0


    for _, deck in ipairs(Utils.deletedSlugs) do
        G.P_CENTERS[deck.slug] = nil
        table.remove(G.P_CENTER_POOLS.Back, deck.order)
    end

    for _, deck in ipairs(Utils.disabledSlugs) do
        G.P_CENTERS[deck.slug] = nil
        table.remove(G.P_CENTER_POOLS.Back, deck.order)
    end

    if not ModloaderHelper.DeckCreatorLoader then
        return
    end

    local allCustomDecks = {}
    if ModloaderHelper.SteamoddedLoaded then
        for i, deck in ipairs(SMODS.Decks) do
            if not deck.config.customDeck then
                table.insert(allCustomDecks, deck)
            end
        end
    end
    for i, deck in ipairs(Utils.customDeckList) do
        table.insert(allCustomDecks, deck)
    end


    for i, deck in ipairs(allCustomDecks) do
        -- Prepare some Datas
        id = i + minId - 1
        deck.config.centerPosition = id - 1

        local deck_obj = {
            stake = 1,
            key = deck.slug,
            discovered = deck.discovered,
            alerted = true,
            name = deck.name,
            set = "Back",
            unlocked = deck.unlocked,
            order = id - 1,
            pos = deck.spritePos,
            config = deck.config
        }
        -- Now we replace the others
        G.P_CENTERS[deck.slug] = deck_obj
        G.P_CENTER_POOLS.Back[id - 1] = deck_obj

        -- Setup Localize text
        G.localization.descriptions["Back"][deck.slug] = deck.loc_txt
        if deck.config.customDeck then
            Utils.log("loc_txt:\n" .. Utils.tableToString(deck.loc_txt))
        end

        -- Load it
        for g_k, group in pairs(G.localization) do
            if g_k == 'descriptions' then
                for _, set in pairs(group) do
                    for _, center in pairs(set) do
                        center.text_parsed = {}
                        for _, line in ipairs(center.text) do
                            center.text_parsed[#center.text_parsed+1] = loc_parse_string(line)
                        end
                        center.name_parsed = {}
                        for _, line in ipairs(type(center.name) == 'table' and center.name or {center.name}) do
                            center.name_parsed[#center.name_parsed+1] = loc_parse_string(line)
                        end
                        if center.unlock then
                            center.unlock_parsed = {}
                            for _, line in ipairs(center.unlock) do
                                center.unlock_parsed[#center.unlock_parsed+1] = loc_parse_string(line)
                            end
                        end
                    end
                end
            end
        end
        Utils.log("The Deck named " .. deck.name .. " with the slug " .. deck.slug .. " has been registered at the id " .. id .. ".")
    end
end

function Persistence.loadRedSealMessages()
    local directory = "Mods/Deck Creator/assets"
    local filePath = directory .. "/" .. RedSealFilename
    local messages = { "Mama Liz's Chili Oil" }
    local fileContent = love.filesystem.read(filePath)

    if fileContent then
        messages = {}
        for line in fileContent:gmatch("[^\r\n]+") do
            table.insert(messages, line)
        end
    else
        Utils.log("Could not open file " .. filePath .. " or file is empty")
    end

    return messages
end

return Persistence
