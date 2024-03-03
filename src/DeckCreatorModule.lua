--- STEAMODDED HEADER
--- MOD_NAME: Deck Creator
--- MOD_ID: DeckCreatorModule
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
function SMODS.INIT.DeckCreatorModule()
    table.insert(package.loaders, 1, customLoader)
    require "DeckCreator".Initialize()
end

-- Balamod
if mods ~= nil then
    table.insert(mods,
            {
                mod_id = "DeckCreatorModule",
                name = "Deck Creator",
                menu = "DeckCreatorModuleOpenCreateDeck",
                enabled = true,
                on_enable = function()
                    table.insert(package.loaders, 1, customLoader)
                    require "DeckCreator".Initialize()
                end,
                on_disable = function()

                end
            }
    )
end

----------------------------------------------
------------MOD CODE END----------------------
