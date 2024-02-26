local Utils = require "Utils"

local CustomDeck = {name = "", slug = "", config = {}, spritePos = {}, loc_txt = {}, unlocked = true, discovered = true}

function CustomDeck:blankDeck()
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.name = ""
    o.descLine1 = ""
    o.descLine2 = ""
    o.descLine3 = ""
    o.descLine4 = ""

    o.config = {
        customDeck = true,
        dollars = 4,
        hand_size = 8,
        discards = 3,
        hands = 4,
        reroll_cost = 5,
        joker_slot = 5,
        ante_scaling = 1,
        consumable_slot = 2,
        extra_discard_bonus = 0,
        reroll_discount = 0,
        edition_count = 1,
        remove_faces = false,
        randomize_rank_suit = false,
        edition = false,
        interest_amount = 1,
        interest_cap = 25,
        discount_percent = 0,
        double_tag = false,
        balance_chips = false,
        inflation = false,
        all_polychrome = false,
        deck_back_index = 0,
        extra_hand_bonus = 1,
        win_ante = 8,
        joker_rate = 20,
        tarot_rate = 4,
        planet_rate = 4,
        spectral_rate = 0,
        playing_card_rate = 0,
        shop_slots = 2,
        all_polychrome = false,
        all_holo = false,
        all_foil = false,
        all_bonus = false,
        all_mult = false,
        all_wild = false,
        all_glass = false,
        all_steel = false,
        all_stone = false,
        all_gold = false,
        all_lucky = false,
        enable_eternals_in_shop = false,
        booster_ante_scaling = false,
        chips_dollar_cap = false,
        discard_cost = 0,
        minus_hand_size_per_X_dollar = false,
        all_eternal = false,
        debuff_played_cards = false,
        flipped_cards = false
    }
    return o
end

function CustomDeck:new(name, slug, config, spritePos, loc_txt)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt
    o.name = name
    o.slug = "b_" .. slug
    o.config = config or {}
    o.spritePos = spritePos or {x = 0, y = 0}
    o.unlocked = true
    o.discovered = true

    return o
end

function CustomDeck:fullNew(name, loc_txt, dollars, handSize, discards, hands, reRollCost, jokerSlots, anteScaling, consumableSlots, dollarsPerHand, dollarsPerDiscard, jokerRate, tarotRate, planetRate, spectralRate, playingCardRate, randomizeRankSuit, noFaces, interestAmount, interestCap, discountPercent, edition, doubleTag, balanceChips, editionCount, deckBackIndex, winAnte, inflation, shopSlots,
                            allPolychrome, allHolo, allFoil, allBonus, allMult, allWild, allGlass, allSteel, allStone, allGold, allLucky, enableEternalsInShop, boosterAnteScaling, chipsDollarCap, discardCost,
                            minus_hand_size_per_X_dollar, allEternal, debuffPlayedCards, flippedCards)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt
    o.name = name
    if name:match("^%s*$") then
        o.name = "Custom Deck_" .. Utils.tableLength(Utils.customDeckList)
        o.loc_txt.name = o.name
    end

    o.slug = "b_" .. o.name
    o.spritePos = {x = 0, y = 0}
    if deckBackIndex ~= nil and deckBackIndex > 0 and deckBackIndex <= #CustomDeck.getAllDeckBacks() then
        o.spritePos = CustomDeck.getAllDeckBacks()[deckBackIndex]
    end
    o.unlocked = true
    o.discovered = true

    if name:match("^%s*$") then
        o.name = "Custom Deck_" .. Utils.tableLength(Utils.customDeckList)
        o.loc_txt.name = o.name
    end

    o.config = {
        customDeck = true,
        dollars = dollars - 4,
        hand_size = handSize - 8,
        discards = discards - 3,
        hands = hands - 4,
        reroll_cost = reRollCost,
        joker_slot = jokerSlots - 5,
        ante_scaling = anteScaling,
        consumable_slot = consumableSlots - 2,
        reroll_discount = 0,
        edition_count = editionCount or 1,
        win_ante = winAnte or 8,
        remove_faces = noFaces or false,
        randomize_rank_suit = randomizeRankSuit or false,
        edition = edition or false,
        interest_amount = interestAmount or 1,
        interest_cap = interestCap or 25,
        discount_percent = discountPercent or 0,
        double_tag = doubleTag or false,
        balance_chips = balanceChips or false,
        inflation = inflation or false,
        all_polychrome = allPolychrome or false,
        spectral_rate = spectralRate,
        joker_rate = jokerRate,
        tarot_rate = tarotRate,
        planet_rate = planetRate,
        playing_card_rate = playingCardRate,
        shop_slots = shopSlots,
        all_polychrome = allPolychrome,
        all_holo = allHolo,
        all_foil = allFoil,
        all_bonus = allBonus,
        all_mult = allMult,
        all_wild = allWild,
        all_glass = allGlass,
        all_steel = allSteel,
        all_stone = allStone,
        all_gold = allGold,
        all_lucky = allLucky,
        enable_eternals_in_shop = enableEternalsInShop,
        booster_ante_scaling = boosterAnteScaling,
        chips_dollar_cap = chipsDollarCap,
        discard_cost = discardCost,
        minus_hand_size_per_X_dollar = minus_hand_size_per_X_dollar,
        all_eternal = allEternal,
        debuff_played_cards = debuffPlayedCards,
        flipped_cards = flippedCards
    }

    if dollarsPerDiscard ~= 0 then
        o.config.extra_discard_bonus = dollarsPerDiscard
    end

    if dollarsPerHand ~= 1 then
        o.config.extra_hand_bonus = dollarsPerHand
    end

    if interestAmount == 0 then
        o.config.no_interest = true
    end

    if minus_hand_size_per_X_dollar and dollars / 5 >= o.config.hand_size + 8 then
        o.config.hand_size = math.floor(dollars / 5) - 7
    end

    return o
end

function CustomDeck:register()
    if not SMODS.Decks[self] then
        table.insert(SMODS.Decks, self)
    end
end

function CustomDeck.createCustomDeck(name, slug, cardConfig, spritePos, loc_txt)
    local customDeck = CustomDeck:new(name, slug, cardConfig, spritePos, loc_txt)
    customDeck:register()
    return customDeck
end

function CustomDeck.getAllDeckBacks()
    return {
        {x=0,y=0},
        {x=0,y=2},
        {x=1,y=2},
        {x=2,y=2},
        {x=3,y=2},
        {x=0,y=3},
        {x=3,y=0},
        {x=6,y=2},
        {x=3,y=3},
        {x=1,y=3},
        {x=3,y=4},
        {x=4,y=3},
        {x=2,y=4},
        {x=4,y=2},
        {x=2,y=3}
    }
end

function CustomDeck.getAllDeckBackNames()
    return {
        "Red",
        "Blue",
        "Yellow",
        "Green",
        "Black",
        "Magic",
        "Nebula",
        "Ghost",
        "Abandoned",
        "Checkered",
        "Zodiac",
        "Painted",
        "Anaglyph",
        "Plasma",
        "Erratic"
    }
end

return CustomDeck
