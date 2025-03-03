local ModloaderHelper = require "ModloaderHelper"

local Utils = {}

Utils.mode = "PROD" -- "dev"
Utils.customDeckList = {}
Utils.runMemoryChecks = false
Utils.EditDeckConfig = {
    newDeck = true,
    copyDeck = false,
    editDeck = false,
    deck = nil
}
Utils.deletedSlugs = {}
Utils.disabledSlugs = {}
Utils.redSealMessages = {}

Utils.hoveredTagStartingItemsAddToItemsKey = nil
Utils.hoveredTagStartingItemsAddToItemsSprite = nil
Utils.hoveredTagStartingItemsRemoveKey = nil
Utils.hoveredTagStartingItemsRemoveUUID = nil
Utils.hoveredTagStartingItemsRemoveSprite = nil
Utils.startingTagsPerPage = nil

Utils.hoveredTagBanItemsAddToBanKey = nil
Utils.hoveredTagBanItemsAddToBanSprite = nil
Utils.hoveredTagBanItemsRemoveKey = nil
Utils.hoveredTagBanItemsRemoveSprite = nil
Utils.bannedTagsPerPage = nil
Utils.hoveredBlindBanItemsAddToBanKey = nil
Utils.hoveredBlindBanItemsAddToBanSprite = nil
Utils.hoveredBlindBanItemsRemoveKey = nil
Utils.hoveredBlindBanItemsRemoveSprite = nil
Utils.bannedBlindsPerPage = nil

Utils.runtimeConstants = {
    boosterPacks = 0
}
Utils.currentShopJokerPage = 1
Utils.maxShopJokerPages = 1
Utils.shopJokers = {}
-- G.DeckCreatorModuleAllShopJokersArea = nil

function Utils.resetTagsPerPage()
    Utils.startingTagsPerPage = 8
    Utils.bannedTagsPerPage = 8
end
function Utils.resetBlindsPerPage()
    Utils.bannedBlindsPerPage = 8
end
function Utils.resetShopJokerPages()
    for k,v in pairs(Utils.shopJokers) do
        for x,y in pairs(v) do
            y:remove()
            y = nil
        end
        v = nil
    end
    Utils.shopJokers = {}
    Utils.currentShopJokerPage = 1
    Utils.maxShopJokerPages = 1
    G.DeckCreatorModuleAllShopJokersArea = nil
end
Utils.resetTagsPerPage()
Utils.resetBlindsPerPage()

function Utils.log(message)
    if Utils.mode ~= "PROD" and sendDebugMessage ~= nil then
        sendInfoMessage(message, "DeckCreatorModule")
    end
    sendDebugMessage(message, "DeckCreatorModule")
end

function Utils.checkMemory()
    if Utils.runMemoryChecks then
        return collectgarbage("count")
    end
    return 0
end

function Utils.modDescription()
    return "GUI mod for creating, saving, loading, and sharing your own customizable decks!"
end

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

function Utils.getCurrentEditingDeck()
    return Utils.EditDeckConfig.deck
end

function Utils.addDollarAmountAtEndOfRound(dollars, text)
    local num_dollars = dollars
    local scale = 0.9
    local pitch = 0.95
    local width = G.round_eval.T.w - 0.51
    local eventId = Utils.uuid()
    G.E_MANAGER:add_event(Event({
        trigger = 'before',delay = 0.5,
        func = function()
            local left_text = {}
            table.insert(left_text, {n=G.UIT.T, config={text = tostring(num_dollars), scale = 0.8*scale, colour = G.C.MONEY, shadow = true, juice = true}})
            table.insert(left_text,{n=G.UIT.O, config={object = DynaText({string = {" " .. text}, colours = {G.C.UI.TEXT_LIGHT}, shadow = true, pop_in = 0, scale = 0.4*scale, silent = true})}})
            local full_row = {n=G.UIT.R, config={align = "cm", minw = 5}, nodes={
                {n=G.UIT.C, config={padding = 0.05, minw = width*0.55, minh = 0.61, align = "cl"}, nodes=left_text},
                {n=G.UIT.C, config={padding = 0.05,minw = width*0.45, align = "cr"}, nodes={{n=G.UIT.C, config={align = "cm", id = 'dollar_' .. eventId},nodes={}}}}
            }}
            G.round_eval:add_child(full_row,G.round_eval:get_UIE_by_ID('bonus_round_eval'))
            play_sound('cancel', pitch or 1)
            play_sound('highlight1',( 1.5*pitch) or 1, 0.2)
            return true
        end
    }))
    local dollar_row = 0
    if num_dollars > 60 then
        G.E_MANAGER:add_event(Event({
            trigger = 'before',delay = 0.38,
            func = function()
                G.round_eval:add_child(
                        {n=G.UIT.R, config={align = "cm", id = 'dollar_row_'..(dollar_row+1)..'_'..eventId}, nodes={
                            {n=G.UIT.O, config={object = DynaText({string = {localize('$')..num_dollars}, colours = {G.C.MONEY}, shadow = true, pop_in = 0, scale = 0.65, float = true})}}
                        }},
                        G.round_eval:get_UIE_by_ID('dollar_'..eventId))

                play_sound('coin3', 0.9+0.2*math.random(), 0.7)
                play_sound('coin6', 1.3, 0.8)
                return true
            end
        }))
    else
        for i = 1, num_dollars or 1 do
            G.E_MANAGER:add_event(Event({
                trigger = 'before',delay = 0.18 - ((num_dollars > 20 and 0.13) or (num_dollars > 9 and 0.1) or 0),
                func = function()
                    if i%30 == 1 then
                        G.round_eval:add_child(
                                {n=G.UIT.R, config={align = "cm", id = 'dollar_row_'..(dollar_row+1)..'_'..eventId}, nodes={}},
                                G.round_eval:get_UIE_by_ID('dollar_'..eventId))
                        dollar_row = dollar_row+1
                    end

                    local r = {n=G.UIT.T, config={text = localize('$'), colour = G.C.MONEY, scale = ((num_dollars > 20 and 0.28) or (num_dollars > 9 and 0.43) or 0.58), shadow = true, hover = true, can_collide = false, juice = true}}
                    play_sound('coin3', 0.9+0.2*math.random(), 0.7 - (num_dollars > 20 and 0.2 or 0))
                    G.round_eval:add_child(r,G.round_eval:get_UIE_by_ID('dollar_row_'..(dollar_row)..'_'..eventId))
                    G.VIBRATION = G.VIBRATION + 0.4
                    return true
                end
            }))
        end
    end
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

function Utils.generateBoundedFloatList(min, max, step)
    local list = {}
    local value = min
    while value <= max do
        local roundedValue = math.floor(value * 100 + 0.5) / 100
        table.insert(list, roundedValue)
        value = value + step
    end
    return list
end

function Utils.generateBoundedIntegerListWithNoneOption(min, max, noneString)
    noneString = noneString or '--'
    local list = {
        noneString
    }
    for i = min, max do
        table.insert(list, i)
    end
    return list
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

function Utils.suits(includeRandom, fullObject)
    local output = {}
    includeRandom = includeRandom or false
    if ModloaderHelper.SteamoddedLoaded then
        for k,v in pairs(SMODS.Card.SUITS) do
            if fullObject ~= nil then
                table.insert(output, v)
            else
                table.insert(output, v.key)
            end
        end
    else
        output = {
            "Clubs",
            "Diamonds",
            "Hearts",
            "Spades"
        }
    end
    if includeRandom then
        table.insert(output, "Random")
    end
    return output
end

function Utils.protoSuits()
    local output = {}
    if ModloaderHelper.SteamoddedLoaded then
        for k,v in pairs(SMODS.Card.SUITS) do
            table.insert(output, v.card_key)
        end
    else
        output = {
            "H", "C", "D", "S"
        }
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

function Utils.protoRanks()
    return {
        "A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K"
    }
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

function Utils.jokerKeys()
    local output = {}
    for k,v in pairs(G.P_CENTERS) do
        if v.set == 'Joker' then
            table.insert(output, k)
        end
    end
    return output
end

function Utils.tarotKeys()
    local output = {}
    for k,v in pairs(G.P_CENTERS) do
        if v.set == 'Tarot' then
            table.insert(output, k)
        end
    end
    return output
end

function Utils.planetKeys()
    local output = {}
    for k,v in pairs(G.P_CENTERS) do
        if v.set == 'Planet' then
            table.insert(output, k)
        end
    end
    return output
end

function Utils.spectralKeys()
    local output = {}
    for k,v in pairs(G.P_CENTERS) do
        if v.set == 'Spectral' then
            table.insert(output, k)
        end
    end
    return output
end

function Utils.tagKeys()
    local output = {}
    for k,v in pairs(G.P_TAGS) do
        table.insert(output, k)
    end
    return output
end

function Utils.blindKeys()
    local output = {}
    for k,v in pairs(G.P_BLINDS) do
        if v.name ~= 'Big Blind' and v.name ~= 'Small Blind' and v.name ~= 'The Empty' then
            table.insert(output, v.name)
        end
    end
    return output
end

function Utils.boosterKeys()
    Utils.runtimeConstants.boosterPacks = 0
    local output = {}
    for k,v in pairs(G.P_CENTERS) do
        if v.set == 'Booster' then
            Utils.runtimeConstants.boosterPacks = Utils.runtimeConstants.boosterPacks + 1
            table.insert(output, k)
        end
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

function Utils.tableToStringIgnoreKeys(tbl, ignoreKeys, indent)
    if not indent then indent = 0 end
    if type(tbl) ~= "table" then return tostring(tbl) end

    local str = ""
    for k, v in pairs(tbl) do
        local skipKey = false
        if ignoreKeys and #ignoreKeys > 0 then
            for x,y in pairs(ignoreKeys) do
                if y == k then
                    skipKey = true
                    break
                end
            end
        end

        if not skipKey then
            local formatting = string.rep("  ", indent) .. k .. ": "
            if type(v) == "table" then
                str = str .. formatting .. "\n" .. Utils.tableToStringIgnoreKeys(v, ignoreKeys, indent+1)
            else
                str = str .. formatting .. tostring(v) .. "\n"
            end
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

function Utils.configureEmptyBlind()
    local newLocalizationEntry = { name = "The Empty", text = { "No boss effects" }}
    local newEntry = {
        key = 'bl_empty',
        name = 'The Empty',
        defeated = false,
        order = 99,
        dollars = 5,
        mult = 2,
        vars = {},
        debuff = {},
        pos = {x=0, y=1},
        boss = {min = 1, max = 99},
        boss_colour = HEX('c6e0eb')
    }

    newLocalizationEntry.text_parsed = {}
    for _, line in ipairs(newLocalizationEntry.text) do
        newLocalizationEntry.text_parsed[#newLocalizationEntry.text_parsed+1] = loc_parse_string(line)
    end
    newLocalizationEntry.name_parsed = {}
    for _, line in ipairs(type(newLocalizationEntry.name) == 'table' and newLocalizationEntry.name or {newLocalizationEntry.name}) do
        newLocalizationEntry.name_parsed[#newLocalizationEntry.name_parsed+1] = loc_parse_string(line)
    end

    G.localization.descriptions.Blind['bl_empty'] = newLocalizationEntry
    G.P_BLINDS['bl_empty'] = newEntry
end

function Utils.addTag(tagKey)
    if tagKey == 'tag_orbital' and G.orbital_hand == nil then
        local _poker_hands = {}
        for x, y in pairs(G.GAME.hands) do
            if y.visible then _poker_hands[#_poker_hands+1] = x end
        end
        G.orbital_hand = pseudorandom_element(_poker_hands, pseudoseed('orbital'))
    end
    add_tag(Tag(tagKey))
    G.orbital_hand = nil
end

return Utils
