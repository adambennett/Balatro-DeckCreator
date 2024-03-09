local Utils = require "Utils"

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

function CardUtils.initializeCustomCardList(deckObj)
    local deck = deckObj.effect.config.customCardList
    local randomizeRanks = deckObj.effect.config.randomize_ranks
    local randomizeSuits = deckObj.effect.config.randomize_suits
    local randomizeRankAndSuits = deckObj.effect.config.randomize_rank_suit
    local noFaces = deckObj.effect.config.remove_faces
    local noNumbered = deckObj.effect.config.no_numbered_cards
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

    for k, v in ipairs(card_protos) do
        local _card = Card(G.deck.T.x, G.deck.T.y, G.CARD_W, G.CARD_H, G.P_CARDS[v.suit ..'_'.. v.rank], G.P_CENTERS[v.enhancement or 'c_base'])
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

function CardUtils.getCardsFromCustomCardList(deck)

    CardUtils.flushGPlayingCards()
    G.playing_cards = {}
    local card_protos = {}

    for k, v in pairs(deck) do
        local rank = string.sub(k, 3, 3)
        local suit = string.sub(k, 1, 1)
        card_protos[#card_protos+1] = {
            suit = suit,
            rank = rank,
            enhancement = v.enhancement ~= "None" and v.enhancementKey or nil,
            edition = v.edition ~= "None" and v.editionKey or nil,
            seal = v.seal ~= "None" and v.seal or nil,
            key = k
        }
    end

    local memoryBefore = collectgarbage("count")
    for k, v in ipairs(card_protos) do
        local _card = Card(999, 999, G.CARD_W, G.CARD_H, G.P_CARDS[v.suit ..'_'.. v.rank], G.P_CENTERS[v.enhancement or 'c_base'])
        _card.uuid = v.key
        if v.edition then _card:set_edition({[v.edition] = true}, true, true) end
        if v.seal then _card:set_seal(v.seal, true, true) end
        table.insert(G.playing_cards, _card)
        table.insert(CardUtils.allCardsEverMade, _card)
    end
    local memoryAfter = collectgarbage("count")
    local diff = memoryAfter - memoryBefore
    if Utils.runMemoryChecks then
        Utils.log("MEMORY CHECK (CardCreation): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function CardUtils.getJokersFromCustomJokerList(deck)
    CardUtils.flushStartingItems('jokers')
    CardUtils.startingItems.jokers = {}

    local memoryBefore = collectgarbage("count")

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

    local memoryBefore = collectgarbage("count")

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

    local memoryBefore = collectgarbage("count")

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

    local memoryBefore = collectgarbage("count")

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

    local memoryBefore = collectgarbage("count")

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

function CardUtils.addCardToDeck(args)
    local deckList = args.deck_list or {}

    local counter = 1
    for i = 1, args.addCard.copies do

        local generatedCard = {
            rank = args.addCard.rank,
            suit = args.addCard.suit,
            suitKey = args.addCard.suitKey,
            edition = args.addCard.edition,
            enhancement = args.addCard.enhancement,
            editionKey = args.addCard.editionKey,
            enhancementKey = args.addCard.enhancementKey,
            seal = args.addCard.seal,
            copies = args.addCard.copies
        }

        if args.addCard.suit == "Random" then
            local list = Utils.suits()
            local randomSuit = list[math.random(1, #list)]
            generatedCard.suit = randomSuit
            generatedCard.suitKey = string.sub(randomSuit, 1, 1)
        end

        if args.addCard.rank == "Random" then
            local list = Utils.ranks()
            generatedCard.rank = list[math.random(1, #list)]
        end

        if args.addCard.enhancement == "Random" then
            if math.random(1, 100) > 80 then
                local list = Utils.enhancements()
                local randomEnhance = list[math.random(1, #list)]
                generatedCard.enhancement = randomEnhance
                generatedCard.enhancementKey = randomEnhance ~= "None" and "m_" .. string.lower(randomEnhance) or nil
            else
                generatedCard.enhancement = "None"
            end

        end

        if args.addCard.edition == "Random" then
            if math.random(1, 100) > 90 then
                local list = Utils.editions(false)
                local randomEdition = list[math.random(1, #list)]
                generatedCard.edition = randomEdition
                generatedCard.editionKey = randomEdition ~= "None" and string.lower(randomEdition) or nil
            else
                generatedCard.edition = "None"
            end
        end

        if args.addCard.seal == "Random" then
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

function CardUtils.addItemToDeck(args)
    local deckList = args.deck_list or {}
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

            -- temporary line to prevent random tag
            if typeRoll == 6 then typeRoll = 2 end

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
            else
                newCard = {
                    id = args.addCard.id,
                    key = args.addCard.key,
                    copies = copies,
                    edition = args.addCard.edition,
                    pinned = args.addCard.pinned,
                    eternal = args.addCard.eternal,
                    edition = args.addCard.edition,
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

function CardUtils.standardCardSet()
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

return CardUtils
