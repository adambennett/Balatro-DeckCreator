--- STEAMODDED HEADER
--- MOD_NAME: Deck Creator
--- MOD_ID: ADeckCreatorModule
--- MOD_AUTHOR: [Nyoxide]
--- MOD_DESCRIPTION: GUI mod for creating, saving, loading, and sharing your own customizable decks!

----------------------------------------------
------------MOD CODE -------------------------

local moduleCache = {}

local function customLoader(moduleName)
    local filename = moduleName:gsub("%.", "/") .. ".lua"
    if moduleCache[filename] then
        return moduleCache[filename]
    end

    local filePath = "Mods/Deck Creator/" .. filename
    local fileContent = love.filesystem.read(filePath)
    if fileContent then
        local moduleFunc = assert(load(fileContent, "@"..filePath))
        moduleCache[filename] = moduleFunc
        return moduleFunc
    end

    return "\nNo module found: " .. moduleName
end

-- Steamodded
if SMODS == nil or SMODS.INIT == nil then
    SMODS = {}
    SMODS.BalamodMode = true
    SMODS.INIT = {}
end
function SMODS.INIT.DeckCreatorModule()
    table.insert(package.loaders, 1, customLoader)
    require "DeckCreator".Enable()
end

--[[if mods == nil then
    mods = {}
end]]

-- Balamod
if mods ~= nil then
    table.insert(package.loaders, 1, customLoader)

    local mod = require "DeckCreator"
    table.insert(mods, {
        mod_id = "ADeckCreatorModule",
        name = "Deck Creator",
        version = "1.0.0",
        author = "Nyoxide",
        menu = "DeckCreatorModuleOpenCreateDeck",
        description = "GUI mod for creating, saving, loading, and sharing your own customizable decks!\nUse the Menu button below to create or manage your custom decks.",
        enabled = true,
        on_enable = function()
            mod.Enable()
        end,
        on_disable = function()
            mod.Disable()
        end
    })

end



----------------------------------------------
------------MOD CODE END----------------------
