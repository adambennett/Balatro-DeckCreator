local Utils = require "Utils"

local CardUtils = {}

function CardUtils.resetToMainMenuState()
--[[    for k, v in ipairs(G.playing_cards) do
        v:remove()
    end

    if G.deck_preview ~= nil then
        G.deck_preview:remove()
        G.deck_preview = nil
    end

    G.deck = nil
    G.playing_cards = nil
    G.GAME.starting_deck_size = nil
    G.VIEWING_DECK = nil]]
    -- G.FUNCS.go_to_menu()
end

function CardUtils.resetPlayingCardsToDefault()
    return CardUtils.standardCardSet()
end

function CardUtils.initializeCustomCardList(deck)
    G.playing_cards = {}
    G.deck.cards = {}
    local card_protos = {}

    for k, v in pairs(deck) do
        local rank = string.sub(k, 3, 3)
        local suit = string.sub(k, 1, 1)
        card_protos[#card_protos+1] = {
            suit = suit,
            rank = rank,
            enhancement = v.enhancement ~= "None" and v.enhancementKey or nil,
            edition = v.edition ~= "None" and v.editionKey or nil,
            seal = v.seal ~= "None" and v.seal or nil
        }
    end

    for k, v in ipairs(card_protos) do
        local _card = Card(9999, 9999, G.CARD_W, G.CARD_H, G.P_CARDS[v.suit ..'_'.. v.rank], G.P_CENTERS[v.enhancement or 'c_base'])
        if v.edition then _card:set_edition({[v.edition] = true}, true, true) end
        if v.seal then _card:set_seal(v.seal, true, true) end
        G.deck:emplace(_card)
        table.insert(G.playing_cards, _card)
    end

    G.GAME.starting_deck_size = #G.playing_cards
    G.deck.card_limit = #G.playing_cards
end

function CardUtils.getCardsFromCustomCardList(deck)
    local CAI = {
        discard_W = G.CARD_W,
        discard_H = G.CARD_H,
        deck_W = G.CARD_W*1.1,
        deck_H = 0.95*G.CARD_H,
        hand_W = 6*G.CARD_W,
        hand_H = 0.95*G.CARD_H,
        play_W = 5.3*G.CARD_W,
        play_H = 0.95*G.CARD_H,
        joker_W = 4.9*G.CARD_W,
        joker_H = 0.95*G.CARD_H,
        consumeable_W = 2.3*G.CARD_W,
        consumeable_H = 0.95*G.CARD_H
    }
    G.deck = CardArea(9999, 9999, CAI.deck_W,CAI.deck_H, {card_limit = 52, type = 'deck'})
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
            seal = v.seal ~= "None" and v.seal or nil
        }
    end

    for k, v in ipairs(card_protos) do
        local _card = Card(G.deck.T.x, G.deck.T.y, G.CARD_W, G.CARD_H, G.P_CARDS[v.suit ..'_'.. v.rank], G.P_CENTERS[v.enhancement or 'c_base'])
        if v.edition then _card:set_edition({[v.edition] = true}, true, true) end
        if v.seal then _card:set_seal(v.seal, true, true) end
        -- G.deck:emplace(_card)
        table.insert(G.playing_cards, _card)
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
            seal = generatedCard.seal
        }

        if deckList[#deckList].config.customCardList[key] == nil then
            deckList[#deckList].config.customCardList[key] = newCard
        else
            while deckList[#deckList].config.customCardList[key .. "_" .. counter] ~= nil do
                counter = counter + 1
            end
            deckList[#deckList].config.customCardList[key .. "_" .. counter] = newCard
        end
    end
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
