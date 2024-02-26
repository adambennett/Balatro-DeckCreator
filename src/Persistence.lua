local Persistence = {}
local Utils = require "Utils"
local CustomDeck = require "CustomDeck"

local filename = "CustomDecks.txt"

function Persistence.saveAllDecks()
    local serialized = serializeDeck(Utils.customDeckList, 0)
    local file, err = io.open(filename, "w")
    if not file then
        Utils.log("Error saving custom decks:", err)
        return
    end
    file:write(serialized)
    file:close()
    Utils.log("All custom decks saved")
end

function Persistence.loadAllDecks()
    local allDecks = readFile()
    if allDecks then
        Utils.customDeckList = {}
        for _, deckConfig in ipairs(allDecks) do
            local loadedDeck = CustomDeck.createCustomDeck(deckConfig.name, deckConfig.slug, deckConfig.config, deckConfig.spritePos, deckConfig.loc_txt)
            Utils.addDeckToList(loadedDeck)
        end
    else
        Utils.log("Could not load any decks")
    end
end

function readFile()
    local file = io.open(filename, "r")
    if not file then
        Utils.log("Could not open " .. filename .. " file")
        return nil
    end
    local serialized = file:read("*a")
    file:close()
    local func, err = loadstring("return " .. serialized)
    if func then
        return func()
    else
        Utils.log("Could not deserialize custom deck data." .. err)
        return nil
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
