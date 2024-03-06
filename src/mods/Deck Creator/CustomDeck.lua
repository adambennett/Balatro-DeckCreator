local Utils = require "Utils"
local CardUtils = require "CardUtils"

local CustomDeck = {name = "", slug = "", config = {}, spritePos = {}, loc_txt = {}, unlocked = true, discovered = true}
CustomDeck.BalamodDeckList = {}

function CustomDeck:blankDeck()
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.name = ""
    o.slug = ""
    o.descLine1 = ""
    o.descLine2 = ""
    o.descLine3 = ""
    o.descLine4 = ""
    o.loc_txt = {
        name = "",
        text = {}
    }

    o.config = {
        copy_deck_config = nil,
        invert_back = true,
        uuid = Utils.uuid(),
        customCardList = CardUtils.standardCardSet(),
        customJokerList = {},
        customTarotList = {},
        customPlanetList = {},
        customSpectralList = {},
        customVoucherList = {},
        customDeck = true,
        custom_cards_set = false,
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
        interest_cap = 5,
        discount_percent = 0,
        double_tag = false,
        balance_chips = false,
        inflation = false,
        all_polychrome = false,
        deck_back_index = 1,
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

    if slug == nil or slug == "" then
        o.slug = "b_" .. name
    else
        o.slug = "b_" .. slug
    end

    o.loc_txt = loc_txt
    o.name = name
    o.config = config or {}
    o.spritePos = spritePos or {x = 0, y = 0}
    o.unlocked = true
    o.discovered = true

    return o
end

function CustomDeck:fullNew(name, loc_txt, dollars, handSize, discards, hands, reRollCost, jokerSlots, anteScaling, consumableSlots, dollarsPerHand, dollarsPerDiscard, jokerRate, tarotRate, planetRate, spectralRate, playingCardRate, randomizeRankSuit, noFaces, interestAmount, interestCap, discountPercent, edition, doubleTag, balanceChips, editionCount, deckBackIndex, winAnte, inflation, shopSlots,
                            allPolychrome, allHolo, allFoil, allBonus, allMult, allWild, allGlass, allSteel, allStone, allGold, allLucky, enableEternalsInShop, boosterAnteScaling, chipsDollarCap, discardCost,
                            minus_hand_size_per_X_dollar, allEternal, debuffPlayedCards, flippedCards, uuid, copyDeckConfig, customCardList, customCardsSet, customJokerList, customJokersSet, customTarotList, customTarotsSet, customPlanetList, customPlanetsSet, customSpectralList, customSpectralsSet, customVoucherList, customVouchersSet)
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
    local list = CustomDeck.getAllDeckBacks()
    if deckBackIndex ~= nil and deckBackIndex > 0 and deckBackIndex <= #list then
        o.spritePos = list[deckBackIndex]
    else
        o.spritePos = list[math.random(1, #list)]
    end
    o.unlocked = true
    o.discovered = true

    o.config = {
        copy_deck_config = copyDeckConfig,
        customJokerList = customJokerList,
        customTarotList = customTarotList,
        customPlanetList = customPlanetList,
        customSpectralList = customSpectralList,
        customVoucherList = customVoucherList,
        custom_jokers_set = customJokersSet,
        custom_tarots_set = customTarotsSet,
        custom_planets_set = customPlanetsSet,
        custom_spectrals_set = customSpectralsSet,
        custom_vouchers_set = customVouchersSet,
        invert_back = true,
        uuid = uuid or Utils.uuid(),
        customCardList = customCardList,
        customDeck = true,
        custom_cards_set = customCardsSet,
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
        interest_cap = (interestCap and interestCap * 5) or 25,
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

    if discardCost ~= nil and discardCost > 0 then
        o.config.discard_cost = discardCost
    end
    o:register()
    return o
end

function CustomDeck:register()
    if SMODS.BalamodMode then
        table.insert(CustomDeck.BalamodDeckList, self)
    else
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
        {x=0,y=0}, -- Red
        {x=0,y=2}, -- Blue
        {x=1,y=2}, -- Yellow
        {x=2,y=2}, -- Green
        {x=3,y=2}, -- Black
        {x=0,y=3}, -- Magic
        {x=3,y=0}, -- Nebula
        {x=6,y=2}, -- Ghost
        {x=3,y=3}, -- Abandoned
        {x=1,y=3}, -- Checkered
        {x=3,y=4}, -- Zodiac
        {x=4,y=3}, -- Painted
        {x=2,y=4}, -- Anaglyph
        {x=4,y=2}, -- Plasma
        {x=2,y=3}, -- Erratic
        {x=0,y=4}, -- Challenge
        {x=1,y=4}, -- Special
        {x=4,y=2}, -- Fade
        {x=6,y=0}, -- Gold
        {x=6,y=1}, -- Silver
        {x=5,y=1}, -- Glass
        {x=5,y=0}, -- Stone
        {x=4,y=1}, -- Lucky
        {x=3,y=1}, -- Wild
        {x=2,y=1}, -- Mult
        {x=1,y=1}, -- Bonus
        {x=1,y=0}, -- White
        {x=4,y=0}, -- Lock
        {x=0,y=1}, -- Soul
        {x=5,y=3}, -- Question
        {x=6,y=3}, -- Question 2
        {x=3,y=0}, -- Gold Seal
        {x=4,y=4}, -- Purple Seal
        {x=5,y=4}, -- Red Seal
        {x=6,y=4}, -- Blue Seal
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
        "Erratic",
        "Challenge",
        "Special",
        "Fade",
        "Gold",
        "Silver",
        "Glass",
        "Stone",
        "Lucky",
        "Wild",
        "Mult",
        "Bonus",
        "White",
        "Lock",
        "Soul",
        "Question",
        "Question 2",
        "Gold Seal",
        "Purple Seal",
        "Red Seal",
        "Blue Seal",
        "Random"
    }
end

return CustomDeck