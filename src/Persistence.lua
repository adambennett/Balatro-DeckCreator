local Utils = require "Utils"
local CustomDeck = require "CustomDeck"

local Persistence = {}
local filename = "CustomDecks.txt"

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

    for _, file in ipairs(files) do
        if string.sub(file, -4) == ".txt" then  -- Check if the file is a .txt file
            local filePath = directory .. "/" .. file
            local fileContent = love.filesystem.read(filePath)

            local func, err = loadstring("return " .. fileContent)
            if func then
                local allDecks = func()
                for _, deckConfig in ipairs(allDecks) do

                    local baseName = deckConfig.name
                    local count = deckNames[baseName] or 0
                    deckNames[baseName] = count + 1
                    if count > 0 then
                        deckConfig.name = baseName .. " (" .. count .. ")"
                        deckConfig.loc_txt.name = deckConfig.name
                        deckConfig.slug = deckConfig.name
                    end

                    if file ~= "CustomDecks.txt" then
                        deckConfig.loc_txt.text = { "Custom Deck", "imported via", "{C:attention}" .. file .. "{}", "" }
                    end

                    local loadedDeck = CustomDeck.createCustomDeck(deckConfig.name, deckConfig.slug, deckConfig.config, deckConfig.spritePos, deckConfig.loc_txt)
                    Utils.addDeckToList(loadedDeck)
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
    end
end

function serializeDeck(val, depth)
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

return Persistence
