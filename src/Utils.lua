local Utils = {}
local CustomDeck = require "CustomDeck"

Utils.customDeckList = {}

function Utils.addDeckToList(newDeck)
    table.insert(Utils.customDeckList , newDeck)
end

function Utils.log(message)
    sendDebugMessage("DeckCreatorMod: " .. message)
end

function Utils.createCustomDeck(name, slug, cardConfig, spritePos, loc_txt)
    local customDeck = CustomDeck:new(name, slug, cardConfig, spritePos, loc_txt)
    customDeck:register()
    return customDeck
end

function Utils.generateIntegerList()
    return { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
    --[[local list = {}
    for i = 0, 9999 do
        table.insert(list, i)
    end
    return list]]
end

function Utils.generateBoundedIntegerList(min, max)
    local list = {}
    for i = min, max do
        table.insert(list, i)
    end
    return list
end

return Utils
