local Utils = {}

Utils.customDeckList = {}

function Utils.addDeckToList(newDeck)
    table.insert(Utils.customDeckList , newDeck)
end

function Utils.log(message)
    sendDebugMessage("DeckCreatorMod: " .. message)
end

function Utils.generateIntegerList()
    return Utils.generateBoundedIntegerList(0, 10)
end

function Utils.generateBigIntegerList()
    return Utils.generateBoundedIntegerList(0, 9999)
end

function Utils.generateBoundedIntegerList(min, max)
    local list = {}
    for i = min, max do
        table.insert(list, i)
    end
    return list
end

function Utils.suits(includeRandom)
    includeRandom = includeRandom or false
    local output = {
        "Clubs",
        "Diamonds",
        "Hearts",
        "Spades"
    }
    if includeRandom then
        table.insert(output, "Random")
    end
    return output
end

function Utils.ranks(includeRandom)
    includeRandom = includeRandom or false
    local output = {
        2, 3, 4, 5, 6, 7, 8, 9, 10, "J", "Q", "K", "A"
    }
    if includeRandom then
        table.insert(output, "Random")
    end
    return output
end

function Utils.editions(includeNegative, includeRandom)
    includeRandom = includeRandom or false
    includeNegative = includeNegative or false
    local output = {
        "None",
        "Foil",
        "Holo",
        "Polychrome",
    }
    if includeNegative then
        table.insert(output, "Negative")
    end
    if includeRandom then
        table.insert(output, "Random")
    end
    return output
end

function Utils.enhancements(includeRandom)
    includeRandom = includeRandom or false
    local output = {
        "None",
        "Bonus",
        "Glass",
        "Gold",
        "Lucky",
        "Mult",
        "Steel",
        "Stone",
        "Wild"
    }
    if includeRandom then
        table.insert(output, "Random")
    end
    return output
end

function Utils.seals(includeRandom)
    includeRandom = includeRandom or false
    local output = {
        "None",
        "Blue",
        "Gold",
        "Purple",
        "Red"
    }
    if includeRandom then
        table.insert(output, "Random")
    end
    return output
end

function Utils.timestamp()
    -- Get the current hour, minute, and other date components
    local hour = tonumber(os.date("%H"))
    local minute = os.date("%M")
    local am_pm = "AM"

    -- Convert to 12-hour format and determine AM/PM
    if hour >= 12 then
        am_pm = "PM"
        if hour > 12 then
            hour = hour - 12
        end
    elseif hour == 0 then
        hour = 12
    end

    -- Format the date
    local date = os.date("%m/%d/%Y")
    return string.format("%s %d:%s %s", date, hour, minute, am_pm)
end

function Utils.tableToString(tbl, indent)
    if not indent then indent = 0 end
    if type(tbl) ~= "table" then return tostring(tbl) end

    local str = ""
    for k, v in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            str = str .. formatting .. "\n" .. Utils.tableToString(v, indent+1)
        else
            str = str .. formatting .. tostring(v) .. "\n"
        end
    end
    return str
end

function Utils.tableLength(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function Utils.uuid()
    local random = math.random
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function Utils.fullDeckConversionFunctions(arg)
    if arg.effect.config.all_polychrome then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_edition({ polychrome = true }, true, true)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_holo then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_edition({ holo = true }, true, true)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_foil then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_edition({ foil = true }, true, true)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_bonus then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_ability(G.P_CENTERS.m_bonus)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_mult then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_ability(G.P_CENTERS.m_mult)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_wild then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_ability(G.P_CENTERS.m_wild)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_glass then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_ability(G.P_CENTERS.m_glass)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_steel then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_ability(G.P_CENTERS.m_steel)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_stone then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_ability(G.P_CENTERS.m_stone)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_gold then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_ability(G.P_CENTERS.m_gold)
                end
                return true
            end
        }))
    end

    if arg.effect.config.all_lucky then
        G.E_MANAGER:add_event(Event({
            func = function()
                for cardIndex = #G.playing_cards, 1, -1 do
                    G.playing_cards[cardIndex]:set_ability(G.P_CENTERS.m_lucky)
                end
                return true
            end
        }))
    end
end

return Utils
