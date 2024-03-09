local Utils = require "Utils"
local CardUtils = require "CardUtils"

local CustomDeck = {name = "", slug = "", config = {}, spritePos = {}, loc_txt = {}, unlocked = true, discovered = true}

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
        flipped_cards = false,
        negative_joker_money = 0,
        negative_joker_for_broken_glass = false,
        balance_percent = 0,
        double_tag_percent = 0,
        randomize_ranks = false,
        randomize_suits = false,
        no_numbered_cards = false,
        randomize_money_small = false,
        randomize_money_settings = false,
        randomize_appearance_rates = false,
        randomize_hands_discards = false,
        random_starting_items = false,
        randomly_enable_gameplay_settings = false,
        one_random_voucher = false,
        broken_glass_money = 0,
        enhanced_dollars_per_round = 0,
        randomize_money_configurable = 0,
        random_starting_jokers = 0,
        doubled_probabilities = false,
        halved_probabilities = false,
        negative_tag_percent = 0,
        mega_standard_tag_percent = 0,
        full_price_jokers = false,
        full_price_consumables = false,
        chip_reduction_percent = 0,
        mult_reduction_percent = 0,
        draw_to_hand_size = 5,
        chance_to_increase_discard_cards_rank = 0,
        chance_to_increase_drawn_cards_rank = 0
    }

    return o
end

function CustomDeck:new(name, slug, config, spritePos, loc_txt)
    o = {}
    setmetatable(o, self)
    self.__index = self

    if slug == nil or slug == "" then
        o.slug = "b_" .. name .. "_" .. (config and config.uuid or "")
    else
        o.slug = slug
    end

    o.loc_txt = loc_txt
    o.name = name
    o.config = config or {}
    o.spritePos = spritePos or {x = 0, y = 0}
    o.unlocked = true
    o.discovered = true

    o.descLine1 = ""
    o.descLine2 = ""
    o.descLine3 = ""
    o.descLine4 = ""
    if (loc_txt and loc_txt.text and #loc_txt.text > 0) then
        o.descLine1 = loc_txt.text[1]
        o.descLine2 = #loc_txt.text > 1 and loc_txt.text[2] or ""
        o.descLine3 = #loc_txt.text > 2 and loc_txt.text[3] or ""
        o.descLine4 = #loc_txt.text > 3 and loc_txt.text[4] or ""
    end

    return o
end

function CustomDeck:fullNew(name, loc_txt, dollars, handSize, discards, hands, reRollCost, jokerSlots, anteScaling, consumableSlots, dollarsPerHand, dollarsPerDiscard, jokerRate, tarotRate, planetRate, spectralRate, playingCardRate, randomizeRankSuit, noFaces, interestAmount, interestCap, discountPercent, edition, doubleTag, balanceChips, editionCount, deckBackIndex, winAnte, inflation, shopSlots,
                            allPolychrome, allHolo, allFoil, allBonus, allMult, allWild, allGlass, allSteel, allStone, allGold, allLucky, enableEternalsInShop, boosterAnteScaling, chipsDollarCap, discardCost,
                            minus_hand_size_per_X_dollar, allEternal, debuffPlayedCards, flippedCards, uuid, copyDeckConfig,
                            customCardList, customCardsSet, customJokerList, customJokersSet, customTarotList, customTarotsSet, customPlanetList, customPlanetsSet, customSpectralList, customSpectralsSet, customVoucherList, customVouchersSet,
                            broken_glass_money, enhanced_dollars_per_round, negative_joker_money, negative_joker_for_broken_glass, balance_percent, double_tag_percent, randomize_ranks, randomize_suits, no_numbered_cards,
                            randomize_money_configurable, randomize_money_small, randomize_money_settings, randomize_appearance_rates, random_starting_jokers, randomize_hands_discards, random_starting_items,
                            randomly_enable_gameplay_settings, one_random_voucher, doubled_probabilities, halved_probabilities, negative_tag_percent, mega_standard_tag_percent, full_price_jokers, full_price_consumables,
                            chip_reduction_percent, mult_reduction_percent, draw_to_hand_size, chance_to_increase_discard_cards_rank, chance_to_increase_drawn_cards_rank)
    o = {}
    local newUUID = uuid or Utils.uuid()
    setmetatable(o, self)
    self.__index = self

    o.loc_txt = loc_txt
    if o.loc_txt and o.loc_txt.text then
        o.descLine1 = #o.loc_txt.text > 0 and o.loc_txt.text[1] or ""
        o.descLine2 = #o.loc_txt.text > 1 and o.loc_txt.text[2] or ""
        o.descLine3 = #o.loc_txt.text > 2 and o.loc_txt.text[3] or ""
        o.descLine4 = #o.loc_txt.text > 3 and o.loc_txt.text[4] or ""
    end
    o.name = name
    if name:match("^%s*$") then
        o.name = "Custom Deck_" .. Utils.tableLength(Utils.customDeckList)
        o.loc_txt.name = o.name
    end

    for k,v in pairs(Utils.customDeckList) do
        if v.name == o.name then
            o.name = o.name .. " "
            break
        end
    end

    o.slug = "b_" .. o.name .. "_" .. newUUID
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
        uuid = newUUID,
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
        flipped_cards = flippedCards,
        deck_back_index = deckBackIndex,
        broken_glass_money = broken_glass_money,
        enahnced_dollars_per_round = enhanced_dollars_per_round,
        negative_joker_money = negative_joker_money,
        negative_joker_for_broken_glass = negative_joker_for_broken_glass,
        balance_percent = balanceChips and 100 or balance_percent,
        double_tag_percent = doubleTag and 100 or double_tag_percent,
        randomize_ranks = randomize_ranks,
        randomize_suits = randomize_suits,
        no_numbered_cards = no_numbered_cards,
        randomize_money_configurable = randomize_money_configurable,
        randomize_money_small = randomize_money_small,
        randomize_money_settings = randomize_money_settings,
        randomize_appearance_rates = randomize_appearance_rates,
        random_starting_jokers = random_starting_jokers,
        randomize_hands_discards = randomize_hands_discards,
        random_starting_items = random_starting_items,
        randomly_enable_gameplay_settings = randomly_enable_gameplay_settings,
        one_random_voucher = one_random_voucher,
        doubled_probabilities = doubled_probabilities,
        halved_probabilities = halved_probabilities,
        negative_tag_percent = negative_tag_percent,
        mega_standard_tag_percent = mega_standard_tag_percent,
        full_price_jokers = full_price_jokers,
        full_price_consumables = full_price_consumables,
        chip_reduction_percent = chip_reduction_percent,
        mult_reduction_percent = mult_reduction_percent,
        draw_to_hand_size = draw_to_hand_size,
        chance_to_increase_discard_cards_rank = chance_to_increase_discard_cards_rank,
        chance_to_increase_drawn_cards_rank = chance_to_increase_drawn_cards_rank

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

    return o
end

function CustomDeck.fullNewFromExisting(deck, desc1, desc2, desc3, desc4, updateUUID)

    if not deck.config and deck.effect and deck.effect.config then
        deck.config = deck.effect.config
    end

    return CustomDeck:fullNew(
            deck.name,
            {name = deck.name, text = {
                [1] = desc1 or "", [2] = desc2 or "", [3] = desc3 or "", [4] = desc4 or ""
            }},
            deck.config.dollars,
            deck.config.hand_size,
            deck.config.discards,
            deck.config.hands,
            deck.config.reroll_cost,
            deck.config.joker_slot,
            deck.config.ante_scaling,
            deck.config.consumable_slot,
            deck.config.extra_hand_bonus,
            deck.config.extra_discard_bonus,
            deck.config.joker_rate,
            deck.config.tarot_rate,
            deck.config.planet_rate,
            deck.config.spectral_rate,
            deck.config.playing_card_rate,
            deck.config.randomize_rank_suit,
            deck.config.remove_faces,
            deck.config.interest_amount,
            deck.config.interest_cap,
            deck.config.discount_percent,
            deck.config.edition,
            deck.config.double_tag,
            deck.config.balance_chips,
            deck.config.edition_count,
            deck.config.deck_back_index,
            deck.config.win_ante,
            deck.config.inflation,
            deck.config.shop_slots,
            deck.config.all_polychrome,
            deck.config.all_holo,
            deck.config.all_foil,
            deck.config.all_bonus,
            deck.config.all_mult,
            deck.config.all_wild,
            deck.config.all_glass,
            deck.config.all_steel,
            deck.config.all_stone,
            deck.config.all_gold,
            deck.config.all_lucky,
            deck.config.enable_eternals_in_shop,
            deck.config.booster_ante_scaling,
            deck.config.chips_dollar_cap,
            deck.config.discard_cost,
            deck.config.minus_hand_size_per_X_dollar,
            deck.config.all_eternal,
            deck.config.debuff_played_cards,
            deck.config.flipped_cards,
            updateUUID and Utils.uuid() or deck.config.uuid,
            deck.config.copy_deck_config,
            deck.config.customCardList,
            deck.config.custom_cards_set,
            deck.config.customJokerList,
            deck.config.custom_jokers_set,
            deck.config.customTarotList,
            deck.config.custom_tarots_set,
            deck.config.customPlanetList,
            deck.config.custom_planets_set,
            deck.config.customSpectralList,
            deck.config.custom_spectrals_set,
            deck.config.customVoucherList,
            deck.config.custom_vouchers_set,
            deck.config.broken_glass_money,
            deck.config.enhanced_dollars_per_round,
            deck.config.negative_joker_money,
            deck.config.negative_joker_for_broken_glass,
            deck.config.balance_percent,
            deck.config.double_tag_percent,
            deck.config.randomize_ranks,
            deck.config.randomize_suits,
            deck.config.no_numbered_cards,
            deck.config.randomize_money_configurable,
            deck.config.randomize_money_small,
            deck.config.randomize_money_settings,
            deck.config.randomize_appearance_rates,
            deck.config.random_starting_jokers,
            deck.config.randomize_hands_discards,
            deck.config.random_starting_items,
            deck.config.randomly_enable_gameplay_settings,
            deck.config.one_random_voucher,
            deck.config.doubled_probabilities,
            deck.config.halved_probabilities,
            deck.config.negative_tag_percent,
            deck.config.mega_standard_tag_percent,
            deck.config.full_price_jokers,
            deck.config.full_price_consumables,
            deck.config.chip_reduction_percent,
            deck.config.mult_reduction_percent,
            deck.config.draw_to_hand_size,
            deck.config.chance_to_increase_discard_cards_rank,
            deck.config.chance_to_increase_drawn_cards_rank
    )
end

function CustomDeck:register()
    if not SMODS.BalamodMode and not SMODS.Decks[self] then
        table.insert(SMODS.Decks, self)
    end
end

function CustomDeck.unregister(deleteUUID)
    if not SMODS.BalamodMode then
        local deckList = SMODS.Decks
        local removeIndex
        for k,v in pairs(deckList) do
            if v.config.uuid == deleteUUID then
                removeIndex = k
                break
            end
        end

        if removeIndex then
            table.remove(deckList, removeIndex)
        end
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
        {x=3,y=4}, -- Gold Seal
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
