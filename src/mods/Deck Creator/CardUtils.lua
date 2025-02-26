local Utils = require "Utils"
local Helper = require "GuiElementHelper"

local CardUtils = {}
CardUtils.allCardsEverMade = {}
CardUtils.startingItems = {
    jokers = {},
    tarots = {},
    planets = {},
    spectrals = {},
    vouchers = {},
    tags = {}
}
CardUtils.bannedItems = {
    jokers = {},
    tarots = {},
    planets = {},
    spectrals = {},
    vouchers = {},
    tags = {},
    blinds = {},
    boosters = {}
}

local function shuffleDeck(deck)
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end

local function applyRandomAbilities(card_protos, config)
    -- Define edition and enhancement abilities
    local editionAbilities = {'polychrome', 'holo', 'foil'}
    local enhancementAbilities = {'m_bonus', 'm_glass', 'm_lucky', 'm_steel', 'm_stone', 'm_wild', 'm_mult', 'm_gold'}

    -- Combine edition and enhancement abilities with their counts
    local abilities = {
        {name = 'polychrome', count = config.random_polychrome_cards, isEdition = true},
        {name = 'holo', count = config.random_holographic_cards, isEdition = true},
        {name = 'foil', count = config.random_foil_cards, isEdition = true},
        {name = 'm_bonus', count = config.random_bonus_cards, isEdition = false},
        {name = 'm_mult', count = config.random_mult_cards, isEdition = false},
        {name = 'm_wild', count = config.random_wild_cards, isEdition = false},
        {name = 'm_glass', count = config.random_glass_cards, isEdition = false},
        {name = 'm_steel', count = config.random_steel_cards, isEdition = false},
        {name = 'm_stone', count = config.random_stone_cards, isEdition = false},
        {name = 'm_gold', count = config.random_gold_cards, isEdition = false},
        {name = 'm_lucky', count = config.random_lucky_cards, isEdition = false},
        {name = 'random_edition', count = config.random_edition_cards, pool = editionAbilities, isEdition = true},
        {name = 'random_enhancement', count = config.random_enhancement_cards, pool = enhancementAbilities, isEdition = false},
    }

    -- Function to apply a random ability from a pool
    local function applyRandomAbilityFromPool(card, pool, isEdition)
        local ability = pool[math.random(#pool)]
        if isEdition then
            card.edition = ability
        else
            card.enhancement = ability
        end
    end

    -- Function to apply an ability to a card
    local function applyAbilityToCard(card, ability)
        if ability.pool then -- If it's a random pool selection
            applyRandomAbilityFromPool(card, ability.pool, ability.isEdition)
        else -- Directly apply named ability
            if ability.isEdition then
                card.edition = ability.name
            else
                card.enhancement = ability.name
            end
        end
    end

    -- Function to check if there are still abilities to apply
    local function remainingAbilities(abilities)
        for _, ability in ipairs(abilities) do
            if ability.count > 0 then
                return true
            end
        end
        return false
    end

    -- Main loop for applying abilities
    while remainingAbilities(abilities) do
        -- Filter for abilities that still have counts > 0
        local availableAbilities = {}
        for _, ability in ipairs(abilities) do
            if ability.count > 0 then
                table.insert(availableAbilities, ability)
            end
        end

        -- Randomly select an ability to apply
        local abilityToApply = availableAbilities[math.random(#availableAbilities)]

        -- Attempt to apply the selected ability to a random card
        local applied = false
        for _, card in ipairs(card_protos) do
            if abilityToApply.isEdition and not card.edition or not abilityToApply.isEdition and not card.enhancement then
                applyAbilityToCard(card, abilityToApply)
                abilityToApply.count = abilityToApply.count - 1
                applied = true
                break -- Break after applying to one card to re-evaluate available abilities
            end
        end

        if not applied then
            break -- If we can't apply the ability, exit the loop
        end
    end
end

function CardUtils.initializeCustomCardList(deckObj)
    local config = deckObj.effect.config
    local deck = config.customCardList
    local randomizeRanks = config.randomize_ranks
    local randomizeSuits = config.randomize_suits
    local randomizeRankAndSuits = config.randomize_rank_suit
    local noFaces = config.remove_faces
    local noNumbered = config.no_numbered_cards
    local noAces = config.no_aces
    G.playing_cards = {}
    G.deck.cards = {}
    local card_protos = {}

    for k, v in pairs(deck) do
        local keep = true
        if randomizeRankAndSuits then _, k = pseudorandom_element(G.P_CARDS, pseudoseed('erratic')) end
        local rank = string.sub(k, 3, 3)
        local suit = string.sub(k, 1, 1)
        if randomizeRanks then
            local list = Utils.protoRanks()
            rank = list[math.random(1, #list)]
        end
        if randomizeSuits then
            local list = Utils.protoSuits()
            suit = list[math.random(1, #list)]
        end

        if noFaces and (rank == 'K' or rank == 'Q' or rank == 'J') then keep = false end
        if noAces and (rank == 'A') then keep = false end
        if noNumbered and (rank == '2' or rank == '3' or rank == '4' or rank == '5' or rank == '6' or rank == '7' or rank == '8' or rank == '9' or rank == 'T') then keep = false end

        if keep then
            card_protos[#card_protos+1] = {
                suit = suit,
                rank = rank,
                enhancement = v.enhancement ~= "None" and v.enhancementKey or nil,
                edition = v.edition ~= "None" and v.editionKey or nil,
                seal = v.seal ~= "None" and v.seal or nil
            }
        end
    end

    shuffleDeck(card_protos)
    applyRandomAbilities(card_protos, config)

    for k, v in ipairs(card_protos) do
        G.playing_card = (G.playing_card and G.playing_card + 1) or 1
        local _card = Card(G.deck.T.x, G.deck.T.y, G.CARD_W, G.CARD_H, G.P_CARDS[v.suit ..'_'.. v.rank], G.P_CENTERS[v.enhancement or 'c_base'], {playing_card = G.playing_card})
        if v.edition then _card:set_edition({[v.edition] = true}, true, true) end
        if v.seal then _card:set_seal(v.seal, true, true) end
        G.deck:emplace(_card)
        table.insert(G.playing_cards, _card)
    end

    G.GAME.starting_deck_size = #G.playing_cards
    G.deck.card_limit = #G.playing_cards
end

function CardUtils.flushGPlayingCards()
    if G.playing_cards and #G.playing_cards > 0 then
        for j = 1, #G.playing_cards do
            local c = G.playing_cards[j]
            if c then
                c:remove()
                c = nil
            end
        end
    end
end

function CardUtils.flushStartingItems(specific)
    if CardUtils.startingItems and #CardUtils.startingItems > 0 then
        for k,v in pairs(CardUtils.startingItems) do
            if v and (specific == nil or specific == k) then
                for i = 1, #v do
                    local c = v[i]
                    if c then
                        c:remove()
                        c = nil
                    end
                end
            end
        end
    end
end

function CardUtils.flushBannedItems(specific)
    if CardUtils.bannedItems and #CardUtils.bannedItems > 0 then
        for k,v in pairs(CardUtils.bannedItems) do
            if v and (specific == nil or specific == k) then
                for i = 1, #v do
                    local c = v[i]
                    if c then
                        c:remove()
                        c = nil
                    end
                end
            end
        end
    end
end

-- Base Deck
function CardUtils.getCardsFromCustomCardList(deck)

    CardUtils.flushGPlayingCards()
    G.playing_cards = {}
    local memoryBefore = Utils.checkMemory()
    for k, v in pairs(deck) do
        local card = CardUtils.cardProtoToCardObject(v, k, 999, 999)
        table.insert(G.playing_cards, card)
        table.insert(CardUtils.allCardsEverMade, card)
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (CardCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.cardProtoToCardObject(proto, key, x, y)
    local rank = string.sub(key, 3, 3)
    local suit = string.sub(key, 1, 1)
    local cardProto = {
        suit = suit,
        rank = rank,
        enhancement = proto.enhancement ~= "None" and proto.enhancementKey or nil,
        edition = proto.edition ~= "None" and proto.editionKey or nil,
        seal = proto.seal ~= "None" and proto.seal or nil,
        key = key
    }
    local _card = Card(x, y, G.CARD_W, G.CARD_H, G.P_CARDS[cardProto.suit ..'_'.. cardProto.rank], G.P_CENTERS[cardProto.enhancement or 'c_base'])
    _card.uuid = cardProto.key
    if cardProto.edition then _card:set_edition({[cardProto.edition] = true}, true, true) end
    if cardProto.seal then _card:set_seal(cardProto.seal, true, true) end
    return _card
end

function CardUtils.generateCardProto(args)
    local generatedCard = {
        rank = args.rank,
        suit = args.suit,
        suitKey = args.suitKey,
        edition = args.edition,
        enhancement = args.enhancement,
        editionKey = args.editionKey,
        enhancementKey = args.enhancementKey,
        seal = args.seal,
        copies = args.copies
    }

    if args.suit == "Random" then
        local list = Utils.suits(false, true)
        local randomSuit = list[math.random(1, #list)]

        if randomSuit.name ~= nil then
            generatedCard.suit = randomSuit.key
            generatedCard.suitKey = randomSuit.card_key
            sendTraceMessage("Genned suitkey: " .. generatedCard.suitKey, "DeckCreatorLogger")
        else
            generatedCard.suit = randomSuit
            generatedCard.suitKey = string.sub(randomSuit, 1, 1)
            sendTraceMessage("Genned suitkey: " .. generatedCard.suitKey, "DeckCreatorLogger")
        end


    end

    if args.rank == "Random" then
        local list = Utils.ranks()
        generatedCard.rank = list[math.random(1, #list)]
    end

    if args.enhancement == "Random" then
        if math.random(1, 100) > 80 then
            local list = Utils.enhancements()
            local randomEnhance = list[math.random(1, #list)]
            generatedCard.enhancement = randomEnhance
            generatedCard.enhancementKey = randomEnhance ~= "None" and "m_" .. string.lower(randomEnhance) or nil
        else
            generatedCard.enhancement = "None"
        end

    end

    if args.edition == "Random" then
        if math.random(1, 100) > 90 then
            local list = Utils.editions(false)
            local randomEdition = list[math.random(1, #list)]
            generatedCard.edition = randomEdition
            generatedCard.editionKey = randomEdition ~= "None" and string.lower(randomEdition) or nil
            if generatedCard.editionKey and generatedCard.editionKey == 'holographic' then
                generatedCard.editionKey = 'holo'
            end
        else
            generatedCard.edition = "None"
        end
    end

    if args.seal == "Random" then
        if math.random(1, 100) > 70 then
            local list = Utils.seals()
            generatedCard.seal = list[math.random(1, #list)]
        else
            generatedCard.seal = "None"
        end

    end

    local newCardName = generatedCard.rank .. " of " .. generatedCard.suit
    local rank = generatedCard.rank
    if rank == 10 then rank = "T" end
    local key = generatedCard.suitKey .. "_" .. rank
    local newCard = {
        name = newCardName ,
        value = generatedCard.rank,
        suit = generatedCard.suit,
        pos = {x=0,y=1},
        edition = generatedCard.edition,
        editionKey = generatedCard.editionKey,
        enhancement = generatedCard.enhancement,
        enhancementKey = generatedCard.enhancementKey,
        seal = generatedCard.seal,
        uuid = Utils.uuid()
    }
    return newCard, key
end

function CardUtils.addCardToDeck(args)
    local counter = 1
    for i = 1, args.copies do

        local newCard, key = CardUtils.generateCardProto(args)

        if Utils.getCurrentEditingDeck().config.customCardList[key] == nil then
            newCard.key = key
            Utils.getCurrentEditingDeck().config.customCardList[key] = newCard
        else
            while Utils.getCurrentEditingDeck().config.customCardList[key .. "_" .. counter] ~= nil do
                counter = counter + 1
            end
            local extraKey = key .. "_" .. counter
            newCard.key = extraKey
            Utils.getCurrentEditingDeck().config.customCardList[extraKey] = newCard
        end
    end
end

-- Starting Items
function CardUtils.getJokersFromCustomJokerList(deck)
    CardUtils.flushStartingItems('jokers')
    CardUtils.startingItems.jokers = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        local eternal = false
        local pinned = false
        local perishable = false
        local rental = false
        local edition
        local uuid
        for k,v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if deck[j] ~= nil and v.key == deck[j].key then
                center = v
                index = k
                eternal = deck[j].eternal
                pinned = deck[j].pinned
                edition = deck[j].edition
                uuid = deck[j].uuid
                perishable = deck[j].perishable
                rental = deck[j].rental
                break
            end
        end

        if center then
            sendTraceMessage(edition, "DeckCreatorLog")
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'joker', uuid = uuid }
            card.ability.order = (j-1)*4
            if edition then
                edition = string.lower(edition) -- Lazy fix for Base option
                card:set_edition{[edition] = true} 
            end
            if eternal then card:set_eternal(true) end
            if perishable then card:set_perishable() end
            if rental then card:set_rental(true) end
            if pinned then card.pinned = true end
            table.insert(CardUtils.startingItems.jokers, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (JokerCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getTarotsFromCustomTarotList(deck)
    CardUtils.flushStartingItems('tarots')
    CardUtils.startingItems.tarots = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        local edition
        local uuid
        for k,v in pairs(G.P_CENTER_POOLS['Tarot']) do
            if deck[j] ~= nil and v.key == deck[j].key then
                center = v
                index = k
                edition = deck[j].edition
                uuid = deck[j].uuid
                break
            end
        end

        if center then
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'tarot', uuid = uuid }
            card.ability.order = (j-1)*4
            if edition then card:set_edition{[edition] = true} end
            table.insert(CardUtils.startingItems.tarots, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (TarotCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getPlanetsFromCustomPlanetList(deck)
    CardUtils.flushStartingItems('planets')
    CardUtils.startingItems.planets = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        local edition
        local uuid
        for k,v in pairs(G.P_CENTER_POOLS['Planet']) do
            if deck[j] ~= nil and v.key == deck[j].key then
                center = v
                index = k
                edition = deck[j].edition
                uuid = deck[j].uuid
                break
            end
        end

        if center then
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'planet', uuid = uuid }
            card.ability.order = (j-1)*4
            if edition then card:set_edition{[edition] = true} end
            table.insert(CardUtils.startingItems.planets, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (PlanetCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getSpectralsFromCustomSpectralList(deck)
    CardUtils.flushStartingItems('spectrals')
    CardUtils.startingItems.spectrals = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        local edition
        local uuid
        for k,v in pairs(G.P_CENTER_POOLS['Spectral']) do
            if deck[j] ~= nil and v.key == deck[j].key then
                center = v
                index = k
                edition = deck[j].edition
                uuid = deck[j].uuid
                break
            end
        end

        if center then
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'spectral', uuid = uuid }
            card.ability.order = (j-1)*4
            if edition then card:set_edition{[edition] = true} end
            table.insert(CardUtils.startingItems.spectrals, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (SpectralCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getVouchersFromCustomVoucherList(deck)

    CardUtils.flushStartingItems('vouchers')
    CardUtils.startingItems.vouchers = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        for k,v in pairs(G.P_CENTER_POOLS["Voucher"]) do
            if deck[j] ~= nil and v.key == deck[j] then
                center = v
                index = k
                break
            end
        end
        if center then
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'voucher'}
            card.ability.order = (j-1)*4
            if center.key == 'v_reroll_surplus' or center.key == 'v_reroll_glut' then
                card.ability.extra = G.P_CENTERS[center.key].config.extra
            end
            table.insert(CardUtils.startingItems.vouchers, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (VoucherCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getTagsFromCustomTagList(deck)

    CardUtils.flushStartingItems('tags')
    CardUtils.startingItems.tags = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local tag
        local uuid
        for k,v in pairs(G.P_TAGS) do
            if deck[j] ~= nil and deck[j].key ~= nil and k == deck[j].key then
                tag = v
                uuid = deck[j].uuid
                break
            end
        end
        if tag then
            local v = tag
            local temp_tag = Tag(v.key, true)
            temp_tag.config.uuid = uuid
            local _, sprite = Helper.generateTagUI(temp_tag, 0.8, { key = 'hoveredTagStartingItemsRemoveKey', sprite = 'hoveredTagStartingItemsRemoveSprite' })
            table.insert(CardUtils.startingItems.tags, sprite)
            table.insert(CardUtils.allCardsEverMade, sprite)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (StartingTagCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.addItemToDeck(args)
    args.addCard = args.addCard or {}
    local copies = args.addCard and type(args.addCard) ~= 'string' and args.addCard.copies or 1

    local randomEdition = false
    for i = 1, copies do

        if args.isRandomType then

            local allVouchers = Utils.vouchers(true)
            local unObtainedVouchers = {}
            for x, y in pairs(allVouchers) do
                local foundMatch = false
                for k,v in pairs(Utils.getCurrentEditingDeck().config.customVoucherList) do
                    if v == y.id then
                        foundMatch = true
                        break
                    end
                end
                if foundMatch == false then
                    table.insert(unObtainedVouchers, y)
                end
            end

            local typeRollMax = #unObtainedVouchers > 0 and 7 or 6
            local typeRoll = math.random(1, typeRollMax)
            if typeRollMax < typeRoll then typeRoll = 1 end

            if typeRoll <= 2 then
                local edition
                local editionRoll = math.random(1, 100)
                if editionRoll < 45 then
                    edition = 'foil'
                elseif editionRoll < 35 then
                    edition = 'holo'
                elseif editionRoll < 25 then
                    edition = 'polychrome'
                elseif editionRoll < 15 then
                    edition = 'negative'
                end

                local list = Utils.jokerKeys()
                local keyRoll = list[math.random(1, #list)]
                args.addCard = {
                    id = keyRoll,
                    key = keyRoll,
                    edition = edition,
                    eternal = false,
                    pinned = false
                }
                args.joker = true
                args.ref = 'customJokerList'
            end
            if typeRoll == 3 then
                local list = Utils.tarotKeys()
                args.addCard = { key = list[math.random(1, #list)], edition = nil }
                args.tarot = true
                args.ref = 'customTarotList'
            end
            if typeRoll == 4 then
                local list = Utils.planetKeys()
                args.addCard = { key = list[math.random(1, #list)], edition = nil }
                args.planet = true
                args.ref = 'customPlanetList'
            end
            if typeRoll == 5 then
                local list = Utils.spectralKeys()
                args.addCard = { key = list[math.random(1, #list)], edition = nil }
                args.spectral = true
                args.ref = 'customSpectralList'
            end
            if typeRoll == 6 then
                local list = Utils.tagKeys()
                args.addCard = { key = list[math.random(1, #list)] }
                args.tag = true
                args.ref = 'customTagList'
            end
            if typeRoll == 7 then
                args.addCard = unObtainedVouchers[math.random(1, #unObtainedVouchers)].id
                args.voucher = true
                args.ref = 'customVoucherList'
            end
        end

        local type
        local newCard
        if args.addCard ~= nil then
            if args.voucher then newCard = tostring(args.addCard)
            elseif args.tag then
                newCard = { key = tostring(args.addCard.key), uuid = Utils.uuid() }
            else
                newCard = {
                    id = args.addCard.id,
                    key = args.addCard.key,
                    copies = copies,
                    edition = args.addCard.edition,
                    pinned = args.addCard.pinned,
                    eternal = args.addCard.eternal,
                    edition = args.addCard.edition,
                    perishable = args.addCard.perishable,
                    rental = args.addCard.rental,
                    uuid = Utils.uuid()
                }
            end
        end

        local calcRandomEdition = (randomEdition or (newCard.edition ~= nil and newCard.edition == 'random'))

        if calcRandomEdition and (args.tarot or args.planet or args.spectral) then
            randomEdition = true
            local roll = math.random(1, 100)
            newCard.edition = roll > 85 and 'negative' or nil
        elseif calcRandomEdition and args.joker then
            randomEdition = true
            local editionRoll = math.random(1, 100)
            if editionRoll < 15 then
                newCard.edition = 'negative'
            elseif editionRoll < 20 then
                newCard.edition = 'polychrome'
            elseif editionRoll < 25 then
                newCard.edition = 'holo'
            elseif editionRoll < 30 then
                newCard.edition = 'foil'
            else
                newCard.edition = nil
            end
        end

        if args.joker then
            type = 'jokers'
        elseif args.tarot then
            type = 'tarots'
        elseif args.planet then
            type = 'planets'
        elseif args.spectral then
            type = 'spectrals'
        elseif args.tag then
            type = 'tags'
        elseif args.voucher then
            type = 'vouchers'

            -- return early if duplicated voucher to prevent crashes
            for k,v in pairs(Utils.getCurrentEditingDeck().config.customVoucherList) do
                if v == newCard then
                    return false
                end
            end
        end

        if newCard then
            table.insert(Utils.getCurrentEditingDeck().config[args.ref], newCard)
            local key = 'custom_' .. type .. '_set'
            Utils.getCurrentEditingDeck().config[key] = true
        end
    end
    return true
end

-- Banned Items
function CardUtils.getBannedJokersFromBannedJokerList(deck)
    CardUtils.flushBannedItems('jokers')
    CardUtils.bannedItems.jokers = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        local eternal = false
        local pinned = false
        local edition
        local uuid
        for k,v in pairs(G.P_CENTER_POOLS["Joker"]) do
            if deck[j] ~= nil and v.key == deck[j].key then
                center = v
                index = k
                eternal = deck[j].eternal
                pinned = deck[j].pinned
                edition = deck[j].edition
                uuid = deck[j].uuid
                break
            end
        end

        if center then
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'joker', uuid = uuid }
            card.ability.order = (j-1)*4
            if edition then card:set_edition{[edition] = true} end
            if eternal then card:set_eternal(true) end
            if pinned then card.pinned = true end
            table.insert(CardUtils.bannedItems.jokers, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (BannedJokerCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getBannedTarotsFromBannedTarotList(deck)
    CardUtils.flushBannedItems('tarots')
    CardUtils.bannedItems.tarots = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        local edition
        local uuid
        for k,v in pairs(G.P_CENTER_POOLS['Tarot']) do
            if deck[j] ~= nil and v.key == deck[j].key then
                center = v
                index = k
                edition = deck[j].edition
                uuid = deck[j].uuid
                break
            end
        end

        if center then
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'tarot', uuid = uuid }
            card.ability.order = (j-1)*4
            if edition then card:set_edition{[edition] = true} end
            table.insert(CardUtils.bannedItems.tarots, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (BannedTarotCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getBannedPlanetsFromBannedPlanetList(deck)
    CardUtils.flushBannedItems('planets')
    CardUtils.bannedItems.planets = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        local edition
        local uuid
        for k,v in pairs(G.P_CENTER_POOLS['Planet']) do
            if deck[j] ~= nil and v.key == deck[j].key then
                center = v
                index = k
                edition = deck[j].edition
                uuid = deck[j].uuid
                break
            end
        end

        if center then
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'planet', uuid = uuid }
            card.ability.order = (j-1)*4
            if edition then card:set_edition{[edition] = true} end
            table.insert(CardUtils.bannedItems.planets, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (BannedPlanetCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getBannedSpectralsFromBannedSpectralList(deck)
    CardUtils.flushBannedItems('spectrals')
    CardUtils.bannedItems.spectrals = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        local edition
        local uuid
        for k,v in pairs(G.P_CENTER_POOLS['Spectral']) do
            if deck[j] ~= nil and v.key == deck[j].key then
                center = v
                index = k
                edition = deck[j].edition
                uuid = deck[j].uuid
                break
            end
        end

        if center then
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'spectral', uuid = uuid }
            card.ability.order = (j-1)*4
            if edition then card:set_edition{[edition] = true} end
            table.insert(CardUtils.bannedItems.spectrals, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (BannedSpectralCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getBannedVouchersFromBannedVoucherList(deck)
    CardUtils.flushBannedItems('vouchers')
    CardUtils.bannedItems.vouchers = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local center
        local index
        for k,v in pairs(G.P_CENTER_POOLS["Voucher"]) do
            if deck[j] ~= nil and v.key == deck[j] then
                center = v
                index = k
                break
            end
        end
        if center then
            local card = Card(9999, 9999, G.CARD_W, G.CARD_H, nil, center)
            card.uuid = { key = center.key, type = 'voucher'}
            card.ability.order = (j-1)*4
            if center.key == 'v_reroll_surplus' or center.key == 'v_reroll_glut' then
                card.ability.extra = G.P_CENTERS[center.key].config.extra
            end
            table.insert(CardUtils.bannedItems.vouchers, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (BannedVoucherCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getBannedTagsFromBannedTagList(deck)
    CardUtils.flushBannedItems('tags')
    CardUtils.bannedItems.tags = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local tag
        for k,v in pairs(G.P_TAGS) do
            if deck[j] ~= nil and deck[j].key and k == deck[j].key then
                tag = v
                break
            end
        end
        if tag then
            local v = tag
            local temp_tag = Tag(v.key, true)
            local _, sprite = Helper.generateTagUI(temp_tag, 0.8, { key = 'hoveredTagBanItemsRemoveKey', sprite = 'hoveredTagBanItemsRemoveSprite' })
            table.insert(CardUtils.bannedItems.tags, sprite)
            table.insert(CardUtils.allCardsEverMade, sprite)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (BannedTagCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getBannedBlindsFromBannedBlindList(deck)
    CardUtils.flushBannedItems('blinds')
    CardUtils.bannedItems.blinds = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local blind
        local index
        for k,v in pairs(G.P_BLINDS) do
            if deck[j] ~= nil and deck[j].key and v.name == deck[j].key then
                blind = v
                index = k
                break
            end
        end
        if blind then
            local v = blind
            local discovered = v.discovered
            local atlas = 'blind_chips'
            if v.atlas then
                atlas = v.atlas
            end
            local temp_blind = AnimatedSprite(0,0,0.8,0.8, G.ANIMATION_ATLAS[atlas], v.pos)
            temp_blind:define_draw_steps({
                {shader = 'dissolve', shadow_height = 0.05},
                {shader = 'dissolve'}
            })
            temp_blind.float = true
            temp_blind.states.hover.can = true
            temp_blind.states.drag.can = false
            temp_blind.states.collide.can = true
            temp_blind.config = {blind = v, force_focus = true}
            temp_blind.hover = function()
                if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
                    if not temp_blind.hovering and temp_blind.states.visible then
                        temp_blind.hovering = true
                        temp_blind.hover_tilt = 3
                        temp_blind:juice_up(0.05, 0.02)
                        Utils.hoveredBlindBanItemsRemoveKey = v.name
                        Utils.hoveredBlindBanItemsRemoveSprite = temp_blind
                        play_sound('chips1', math.random()*0.1 + 0.55, 0.12)
                        temp_blind.config.h_popup = create_UIBox_blind_popup(v, discovered)
                        temp_blind.config.h_popup_config ={align = 'cl', offset = {x=-0.1,y=0},parent = temp_blind}
                        Node.hover(temp_blind)
                        if temp_blind.children.alert then
                            temp_blind.children.alert:remove()
                            temp_blind.children.alert = nil
                            temp_blind.config.blind.alerted = true
                            G:save_progress()
                        end
                    end
                end
                temp_blind.stop_hover = function()
                    temp_blind.hovering = false
                    Utils.hoveredBlindBanItemsRemoveKey = nil
                    Utils.hoveredBlindBanItemsRemoveSprite = nil
                    Node.stop_hover(temp_blind)
                    temp_blind.hover_tilt = 0
                end
            end

            table.insert(CardUtils.bannedItems.blinds, temp_blind)
            table.insert(CardUtils.allCardsEverMade, temp_blind)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (BannedBlindCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getBannedBoostersFromBannedBoosterList(deck)
    CardUtils.flushBannedItems('boosters')
    CardUtils.bannedItems.boosters = {}

    local memoryBefore = Utils.checkMemory()

    for j = 1, #deck do
        local booster
        local index
        local uuid
        for k,v in pairs(G.P_CENTER_POOLS.Booster) do
            if deck[j] ~= nil and deck[j].key and v.key == deck[j].key then
                booster = v
                index = k
                uuid = deck[j].uuid
                break
            end
        end
        if booster then

            local center = booster
            local card = Card(9999, 9999, G.CARD_W*1.27, G.CARD_H*1.27, nil, center)
            card.uuid = { key = center.key, type = 'booster', uuid = uuid }
            table.insert(CardUtils.bannedItems.boosters, card)
            table.insert(CardUtils.allCardsEverMade, card)
        end
    end

    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (BannedBoosterCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.banItem(args)
    args.addCard = args.addCard or {}
    local newCard

    if Utils.runtimeConstants.boosterPacks == 0 then
        Utils.boosterKeys()
    end

    if args.isRandomType then

        local allJokers = Utils.jokerKeys()
        local allTarots = Utils.tarotKeys()
        local allPlanets = Utils.planetKeys()
        local allSpectral = Utils.spectralKeys()
        local allTags = Utils.tagKeys()
        local allBlinds = Utils.blindKeys()
        local allBoosters = Utils.boosterKeys()
        local allVouchers = Utils.vouchers(true)
        local unObtainedJokers = {}
        local unObtainedTarots = {}
        local unObtainedPlanets = {}
        local unObtainedSpectrals = {}
        local unObtainedTags = {}
        local unObtainedBlinds = {}
        local unObtainedVouchers = {}
        local unObtainedBoosters = {}
        for x, y in pairs(allJokers) do
            local foundMatch = false
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedJokerList) do
                if v.key == y then
                    foundMatch = true
                    break
                end
            end
            if foundMatch == false then
                table.insert(unObtainedJokers, y)
            end
        end
        for x, y in pairs(allTarots) do
            local foundMatch = false
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedTarotList) do
                if v.key == y then
                    foundMatch = true
                    break
                end
            end
            if foundMatch == false then
                table.insert(unObtainedTarots, y)
            end
        end
        for x, y in pairs(allPlanets) do
            local foundMatch = false
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedPlanetList) do
                if v.key == y then
                    foundMatch = true
                    break
                end
            end
            if foundMatch == false then
                table.insert(unObtainedPlanets, y)
            end
        end
        for x, y in pairs(allSpectral) do
            local foundMatch = false
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedSpectralList) do
                if v.key == y then
                    foundMatch = true
                    break
                end
            end
            if foundMatch == false then
                table.insert(unObtainedSpectrals, y)
            end
        end
        for x, y in pairs(allTags) do
            local foundMatch = false
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedTagList) do
                if v.key == y then
                    foundMatch = true
                    break
                end
            end
            if foundMatch == false then
                table.insert(unObtainedTags, y)
            end
        end
        for x, y in pairs(allBlinds) do
            local foundMatch = false
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedBlindList) do
                if v.key == y then
                    foundMatch = true
                    break
                end
            end
            if foundMatch == false then
                table.insert(unObtainedBlinds, y)
            end
        end
        for x, y in pairs(allVouchers) do
            local foundMatch = false
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedVoucherList) do
                if v == y.id then
                    foundMatch = true
                    break
                end
            end
            if foundMatch == false then
                table.insert(unObtainedVouchers, y)
            end
        end
        for x, y in pairs(allBoosters) do
            local foundMatch = false
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedBoosterList) do
                if v.key == y then
                    foundMatch = true
                    break
                end
            end
            if foundMatch == false then
                table.insert(unObtainedBoosters, y)
            end
        end

        local typeRoll = math.random(1, 8)

        if typeRoll == 1 and #unObtainedJokers > 0 then
            newCard = { key = unObtainedJokers[math.random(1, #unObtainedJokers)], uuid = Utils.uuid() }
            args.joker = true
            args.ref = 'bannedJokerList'
        elseif typeRoll <= 2 and #unObtainedTarots > 0 then
            newCard = { key = unObtainedTarots[math.random(1, #unObtainedTarots)], uuid = Utils.uuid() }
            args.tarot = true
            args.ref = 'bannedTarotList'
        elseif typeRoll <= 3 and #unObtainedPlanets > 0 then
            newCard = { key = unObtainedPlanets[math.random(1, #unObtainedPlanets)], uuid = Utils.uuid() }
            args.planet = true
            args.ref = 'bannedPlanetList'
        elseif typeRoll <= 4 and #unObtainedSpectrals > 0 then
            newCard = { key = unObtainedSpectrals[math.random(1, #unObtainedSpectrals)], uuid = Utils.uuid() }
            args.spectral = true
            args.ref = 'bannedSpectralList'
        elseif typeRoll <= 5 and #unObtainedTags > 0 then
            newCard = { key = unObtainedTags[math.random(1, #unObtainedTags)], uuid = Utils.uuid() }
            args.tag = true
            args.ref = 'bannedTagList'
        elseif typeRoll <= 6 and #unObtainedVouchers > 0 then
            newCard = unObtainedVouchers[math.random(1, #unObtainedVouchers)].id
            args.voucher = true
            args.ref = 'bannedVoucherList'
        elseif typeRoll <= 7 and #unObtainedBlinds > 0 then
            newCard = { key = unObtainedBlinds[math.random(1, #unObtainedBlinds)], uuid = Utils.uuid() }
            args.blind = true
            args.ref = 'bannedBlindList'
        elseif typeRoll <= 8 and #unObtainedBoosters > 0 then
            newCard = { key = unObtainedBoosters[math.random(1, #unObtainedBoosters)], uuid = Utils.uuid() }
            args.booster = true
            args.ref = 'bannedBoosterList'
        elseif #unObtainedJokers > 0 then
            newCard = { key = unObtainedJokers[math.random(1, #unObtainedJokers)], uuid = Utils.uuid() }
            args.joker = true
            args.ref = 'bannedJokerList'
        end
    elseif args.addCard ~= nil then
        if args.voucher then newCard = tostring(args.addCard)
        else
            newCard = {
                key = args.addCard,
                uuid = Utils.uuid()
            }
        end
    end

    if newCard then
        local skip = false
        for k,v in pairs(Utils.getCurrentEditingDeck().config[args.ref]) do
            if args.voucher and v == newCard then
                skip = true
                break
            elseif not args.voucher and v.key == newCard.key then
                skip = true
                break
            end
        end

        if skip == false then
            table.insert(Utils.getCurrentEditingDeck().config[args.ref], newCard)
            return true
        end
    end

    return false
end

-- General purpose utilities
function CardUtils.standardCardSet()
    --return G.P_CARDS
    return {
        H_2={name = "2 of Hearts",value = '2', suit = 'Hearts', pos = {x=0,y=0}},
        H_3={name = "3 of Hearts",value = '3', suit = 'Hearts', pos = {x=1,y=0}},
        H_4={name = "4 of Hearts",value = '4', suit = 'Hearts', pos = {x=2,y=0}},
        H_5={name = "5 of Hearts",value = '5', suit = 'Hearts', pos = {x=3,y=0}},
        H_6={name = "6 of Hearts",value = '6', suit = 'Hearts', pos = {x=4,y=0}},
        H_7={name = "7 of Hearts",value = '7', suit = 'Hearts', pos = {x=5,y=0}},
        H_8={name = "8 of Hearts",value = '8', suit = 'Hearts', pos = {x=6,y=0}},
        H_9={name = "9 of Hearts",value = '9', suit = 'Hearts', pos = {x=7,y=0}},
        H_T={name = "10 of Hearts",value = '10', suit = 'Hearts', pos = {x=8,y=0}},
        H_J={name = "Jack of Hearts",value = 'Jack', suit = 'Hearts', pos = {x=9,y=0}},
        H_Q={name = "Queen of Hearts",value = 'Queen', suit = 'Hearts', pos = {x=10,y=0}},
        H_K={name = "King of Hearts",value = 'King', suit = 'Hearts', pos = {x=11,y=0}},
        H_A={name = "Ace of Hearts",value = 'Ace', suit = 'Hearts', pos = {x=12,y=0}},
        C_2={name = "2 of Clubs",value = '2', suit = 'Clubs', pos = {x=0,y=1}},
        C_3={name = "3 of Clubs",value = '3', suit = 'Clubs', pos = {x=1,y=1}},
        C_4={name = "4 of Clubs",value = '4', suit = 'Clubs', pos = {x=2,y=1}},
        C_5={name = "5 of Clubs",value = '5', suit = 'Clubs', pos = {x=3,y=1}},
        C_6={name = "6 of Clubs",value = '6', suit = 'Clubs', pos = {x=4,y=1}},
        C_7={name = "7 of Clubs",value = '7', suit = 'Clubs', pos = {x=5,y=1}},
        C_8={name = "8 of Clubs",value = '8', suit = 'Clubs', pos = {x=6,y=1}},
        C_9={name = "9 of Clubs",value = '9', suit = 'Clubs', pos = {x=7,y=1}},
        C_T={name = "10 of Clubs",value = '10', suit = 'Clubs', pos = {x=8,y=1}},
        C_J={name = "Jack of Clubs",value = 'Jack', suit = 'Clubs', pos = {x=9,y=1}},
        C_Q={name = "Queen of Clubs",value = 'Queen', suit = 'Clubs', pos = {x=10,y=1}},
        C_K={name = "King of Clubs",value = 'King', suit = 'Clubs', pos = {x=11,y=1}},
        C_A={name = "Ace of Clubs",value = 'Ace', suit = 'Clubs', pos = {x=12,y=1}},
        D_2={name = "2 of Diamonds",value = '2', suit = 'Diamonds', pos = {x=0,y=2}},
        D_3={name = "3 of Diamonds",value = '3', suit = 'Diamonds', pos = {x=1,y=2}},
        D_4={name = "4 of Diamonds",value = '4', suit = 'Diamonds', pos = {x=2,y=2}},
        D_5={name = "5 of Diamonds",value = '5', suit = 'Diamonds', pos = {x=3,y=2}},
        D_6={name = "6 of Diamonds",value = '6', suit = 'Diamonds', pos = {x=4,y=2}},
        D_7={name = "7 of Diamonds",value = '7', suit = 'Diamonds', pos = {x=5,y=2}},
        D_8={name = "8 of Diamonds",value = '8', suit = 'Diamonds', pos = {x=6,y=2}},
        D_9={name = "9 of Diamonds",value = '9', suit = 'Diamonds', pos = {x=7,y=2}},
        D_T={name = "10 of Diamonds",value = '10', suit = 'Diamonds', pos = {x=8,y=2}},
        D_J={name = "Jack of Diamonds",value = 'Jack', suit = 'Diamonds', pos = {x=9,y=2}},
        D_Q={name = "Queen of Diamonds",value = 'Queen', suit = 'Diamonds', pos = {x=10,y=2}},
        D_K={name = "King of Diamonds",value = 'King', suit = 'Diamonds', pos = {x=11,y=2}},
        D_A={name = "Ace of Diamonds",value = 'Ace', suit = 'Diamonds', pos = {x=12,y=2}},
        S_2={name = "2 of Spades",value = '2', suit = 'Spades', pos = {x=0,y=3}},
        S_3={name = "3 of Spades",value = '3', suit = 'Spades', pos = {x=1,y=3}},
        S_4={name = "4 of Spades",value = '4', suit = 'Spades', pos = {x=2,y=3}},
        S_5={name = "5 of Spades",value = '5', suit = 'Spades', pos = {x=3,y=3}},
        S_6={name = "6 of Spades",value = '6', suit = 'Spades', pos = {x=4,y=3}},
        S_7={name = "7 of Spades",value = '7', suit = 'Spades', pos = {x=5,y=3}},
        S_8={name = "8 of Spades",value = '8', suit = 'Spades', pos = {x=6,y=3}},
        S_9={name = "9 of Spades",value = '9', suit = 'Spades', pos = {x=7,y=3}},
        S_T={name = "10 of Spades",value = '10', suit = 'Spades', pos = {x=8,y=3}},
        S_J={name = "Jack of Spades",value = 'Jack', suit = 'Spades', pos = {x=9,y=3}},
        S_Q={name = "Queen of Spades",value = 'Queen', suit = 'Spades', pos = {x=10,y=3}},
        S_K={name = "King of Spades",value = 'King', suit = 'Spades', pos = {x=11,y=3}},
        S_A={name = "Ace of Spades",value = 'Ace', suit = 'Spades', pos = {x=12,y=3}},
    }
end

function CardUtils.isStone(card)
    return card.ability.effect == 'Stone Card' and not card.vampired
end

function CardUtils.receiveRandomNegativeJoker()
    G.GAME.joker_buffer = G.GAME.joker_buffer + 1
    G.E_MANAGER:add_event(Event({
        func = function()
            local card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'rif')
            card:set_edition({ negative = true }, true, true)
            card:add_to_deck()
            G.jokers:emplace(card)
            card:start_materialize()
            G.GAME.joker_buffer = 0
            return true
        end
    }))
end

function CardUtils.destroyRandomJoker()
    local deletable_jokers = {}
    for k, v in pairs(G.jokers.cards) do
        if not v.ability.eternal then deletable_jokers[#deletable_jokers + 1] = v end
    end
    local chosen_joker = pseudorandom_element(deletable_jokers, pseudoseed('ankh_choice'))
    G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.75, func = function()
        for k, v in pairs(G.jokers.cards) do
            if v == chosen_joker then
                v:start_dissolve()
            end
        end
        return true end })
    )
end

function CardUtils.removeAllJokersFromShop()
    for i = #G.shop_jokers.cards,1, -1 do
        local c = G.shop_jokers:remove_card(G.shop_jokers.cards[i])
        c:remove()
        c = nil
    end
end

function CardUtils.addFourJokersToShop()
    for i = 1, 4 do
        local joker = Utils.shopJokers[Utils.currentShopJokerPage][i]
        if joker ~= nil then
            G.shop_jokers:emplace(joker)
        end
    end


end

function CardUtils.setupBigJokerShop(juice)
    juice = juice or false
    local page = 0
    local currentPage = 1
    local maxPage = 1
    for i = 1, G.GAME.shop.joker_max - #G.shop_jokers.cards do
        local joker = create_card_for_shop(G.shop_jokers)
        Utils.shopJokers[currentPage] = Utils.shopJokers[currentPage] or {}
        table.insert(Utils.shopJokers[currentPage], joker)
        G.DeckCreatorModuleAllShopJokersArea:emplace(joker)
        page = page + 1
        if page == 4 then
            page = 0
            currentPage = currentPage + 1
            maxPage = currentPage
        end
    end

    Utils.maxShopJokerPages = maxPage
    local jokersInShop = G.GAME.shop.joker_max - #G.shop_jokers.cards
    if jokersInShop > 4 then jokersInShop = 4 end

    for i = 1, jokersInShop do
        local joker = Utils.shopJokers[Utils.currentShopJokerPage][i]
        if joker ~= nil then
            G.shop_jokers:emplace(joker)
            if juice then
                joker:juice_up()
            end
        end
    end
end

function CardUtils.savedJokerAreaToPages()
    if G.DeckCreatorModuleAllShopJokersArea then

    end
end

return CardUtils
