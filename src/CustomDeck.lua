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
        dollars = 0,
        hand_size = 0,
        discards = 0,
        hands = 0,
        reroll_cost = 5,
        joker_slot = 0,
        ante_scaling = 1,
        consumable_slot = 2,
        extra_discard_bonus = 0,
        reroll_discount = 0,
        edition_count = 1,
        remove_faces = false,
        randomize_rank_suit = false,
        edition = false,
        no_interest = false,
        double_tag = false,
        balance_chips = false
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

function CustomDeck:fullNew(name, slug, spritePos, loc_txt, dollars, handSize, discards, hands, reRollCost, reRollDiscount, jokerSlots, anteScaling, consumableSlots, dollarsPerHand, dollarsPerDiscard, spectralRate, randomizeRankSuit, noFaces, noInterest, edition, doubleTag, balanceChips, editionCount)
    o = {}
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt
    o.name = name
    o.slug = "b_" .. slug
    o.spritePos = spritePos or {x = 0, y = 0}
    o.unlocked = true
    o.discovered = true

    o.config = {
        dollars = dollars - 4,
        hand_size = handSize - 8,
        discards = discards - 3,
        hands = hands - 4,
        reroll_cost = reRollCost,
        joker_slot = jokerSlots - 5,
        ante_scaling = anteScaling,
        consumable_slot = consumableSlots - 2,
        extra_discard_bonus = dollarsPerDiscard or 0,
        reroll_discount = reRollDiscount or 0,
        edition_count = editionCount or 1,
        remove_faces = noFaces or false,
        randomize_rank_suit = randomizeRankSuit or false,
        edition = edition or false,
        no_interest = noInterest or false,
        double_tag = doubleTag or false,
        balance_chips = balanceChips or false
    }

    if dollarsPerHand == 0 then
        o.config.extra_hand_bonus = -1
    elseif dollarsPerHand ~= 1 then
        o.config.extra_hand_bonus = dollarsPerHand
    end

    if spectralRate ~= nil and spectralRate > 0 then
        o.config.spectral_rate = spectralRate
    end

    return o
end

function CustomDeck:register()
    if not SMODS.Decks[self] then
        table.insert(SMODS.Decks, self)
        -- SMODS.injectDecks()
    end
end

return CustomDeck
