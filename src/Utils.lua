local Utils = {}

Utils.customDeckList = {}
Utils.runMemoryChecks = false

function Utils.registerGlobals()
    G.FUNCS.LogDebug = function(message)
        Utils.log(message)
    end

    G.FUNCS.LogTableToString = function(table)
        Utils.log(Utils.tableToString(table))
    end
end

function Utils.addDeckToList(newDeck)
    table.insert(Utils.customDeckList , newDeck)
end

function Utils.log(message)
    if sendDebugMessage ~= nil then
        sendDebugMessage("DeckCreatorMod: " .. message)
    end
end

function Utils.generateIntegerList()
    return Utils.generateBoundedIntegerList(0, 10)
end

function Utils.generateBigIntegerList()
    return Utils.generateBoundedIntegerList(0, 9999)
end

function Utils.allDeckNames()
    local output = {
        "None"
    }
    for k,v in pairs(G.P_CENTER_POOLS.Back) do
        local foundMatch = false
        for x,y in pairs(output) do
            if y == v.name then
                foundMatch = true
                break
            end
        end

        if foundMatch == false then
            table.insert(output, v.name)
        end
    end
    return output
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

function Utils.vouchers(includeLevelTwo)
    local output = {
        { id = "v_overstock_norm", name = "Overstock", pos = {x=0,y=0}, },
        { id = "v_clearance_sale", name = "Clearance Sale", pos = {x=3,y=0}},
        { id = "v_hone", name = "Hone", pos = {x=4,y=0}},
        { id = "v_reroll_surplus", name = "Reroll Surplus", pos = {x=0,y=2}},
        { id = "v_crystal_ball", name = "Crystal Ball", pos = {x=2,y=2}},
        { id = "v_telescope", name = "Telescope", pos = {x=3,y=2}},
        { id = "v_grabber", name = "Grabber", pos = {x=5,y=0}},
        { id = "v_wasteful", name = "Wasteful", pos = {x=6,y=0}},
        { id = "v_tarot_merchant", name = "Tarot Merchant", pos = {x=1,y=0}},
        { id = "v_planet_merchant", name = "Planet Merchant", pos = {x=2,y=0}},
        { id = "v_seed_money", name = "Seed Money", pos = {x=1,y=2}},
        { id = "v_blank", name = "Blank", pos = {x=7,y=0}},
        { id = "v_magic_trick", name = "Magic Trick", pos = {x=4,y=2}},
        { id = "v_hieroglyph", name = "Hieroglyph", pos = {x=5,y=2}},
        { id = "v_directors_cut", name = "Director's Cut", pos = {x=6,y=2}},
        { id = "v_paint_brush", name = "Paint Brush", pos = {x=7,y=2}}
    }
    if includeLevelTwo then
        local levelTwos = {
            { id = "v_overstock_plus", name = "Overstock Plus", pos = {x=0,y=1}},
            { id = "v_liquidation", name = "Liquidation", pos = {x=3,y=1}},
            { id = "v_glow_up", name = "Glow Up", pos = {x=4,y=1}},
            { id = "v_reroll_glut", name = "Reroll Glut", pos = {x=0,y=3}},
            { id = "v_omen_globe", name = "Omen Globe", pos = {x=2,y=3}},
            { id = "v_observatory", name = "Observatory", pos = {x=3,y=3}},
            { id = "v_nacho_tong", name = "Nacho Tong", pos = {x=5,y=1}},
            { id = "v_recyclomancy", name = "Recyclomancy", pos = {x=6,y=1}},
            { id = "v_tarot_tycoon", name = "Tarot Tycoon", pos = {x=1,y=1}},
            { id = "v_planet_tycoon", name = "Planet Tycoon", pos = {x=2,y=1}},
            { id = "v_money_tree", name = "Money Tree", pos = {x=1,y=3}},
            { id = "v_antimatter", name = "Antimatter", pos = {x=7,y=1}},
            { id = "v_illusion", name = "Illusion", pos = {x=4,y=3}},
            { id = "v_petroglyph", name = "Petroglyph", pos = {x=5,y=3}},
            { id = "v_retcon", name = "Retcon", pos = {x=6,y=3}},
            { id = "v_palette", name = "Palette", pos = {x=7,y=3}}
        }
        for k,v in pairs(levelTwos) do
            table.insert(output, v)
        end
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
