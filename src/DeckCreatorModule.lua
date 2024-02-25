--- STEAMODDED HEADER
--- MOD_NAME: Deck Creator
--- MOD_ID: DeckCreatorModule
--- MOD_AUTHOR: [Nyoxide]
--- MOD_DESCRIPTION: GUI mod for creating, saving, and loading your own customizable decks!

----------------------------------------------
------------MOD CODE -------------------------

local moduleCache = {}

local function customLoader(moduleName)
    local filename = moduleName:gsub("%.", "/") .. ".lua"
    if moduleCache[filename] then
        return moduleCache[filename]
    end

    local filePath = "Mods/DeckCreator/" .. filename
    local fileContent = love.filesystem.read(filePath)
    if fileContent then
        local moduleFunc = assert(load(fileContent, "@"..filePath))
        moduleCache[filename] = moduleFunc
        return moduleFunc
    end

    return "\nNo module found: " .. moduleName
end

function SMODS.INIT.DeckCreatorModule()
    table.insert(package.loaders, 1, customLoader)
    require "DeckCreator".LoadCustomDecks()
end

----------------------------------------------
------------MOD CODE END----------------------
