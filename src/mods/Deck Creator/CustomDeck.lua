local Utils = require "Utils"
local CardUtils = require "CardUtils"
local ModloaderHelper = require "ModloaderHelper"

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
        stones_are_faces = false,
        replace_broken_glass_with_random_cards_chance = 0,
        replace_broken_glass_with_stones_chance = 0,
        gain_ten_dollars_glass_break_chance = 0,
        triple_mult_cards_chance = 0,
        disable_mult_cards_chance = 0,
        multiply_probabilities = 1,
        divide_probabilities = 1,
        extra_hand_level_upgrades = 0,
        reroll_boosters = false,
        gain_dollars_when_skip_booster = 0,
        aces_are_faces = false,
        sevens_are_faces = false,
        make_sevens_lucky = 0,
        chance_to_double_gold_seal = 0,
        extra_red_seal_repetitions = 0,
        red_seal_silly_messages = false,
        blue_seal_always_most_played = false,
        blue_seal_switch_trigger = false,
        orbital_tag_percent = 0,
        economy_tag_percent = 0,
        skip_tag_percent = 0,
        top_up_tag_percent = 0,
        d6_tag_percent = 0,
        juggle_tag_percent = 0,
        coupon_tag_percent = 0,
        ethereal_tag_percent = 0,
        garbage_tag_percent = 0,
        handy_tag_percent = 0,
        buffoon_tag_percent = 0,
        meteor_tag_percent = 0,
        charm_tag_percent = 0,
        boss_tag_percent = 0,
        voucher_tag_percent = 0,
        investment_tag_percent = 0,
        polychrome_tag_percent = 0,
        holographic_tag_percent = 0,
        foil_tag_percent = 0,
        rare_tag_percent = 0,
        uncommon_tag_percent = 0,
        standard_pack_edition_rate = 2,
        standard_pack_enhancement_rate = 40,
        standard_pack_seal_rate = 20,
        always_telescoping = false,
        never_telescoping = false,
        skip_shop_chance_small_blind = 0,
        skip_shop_chance_big_blind = 0,
        skip_shop_chance_boss = 0,
        skip_shop_chance_any = 0,
        skip_blind_disabled_chance_small_blind = 0,
        skip_blind_disabled_chance_big_blind = 0,
        skip_blind_disabled_chance_any = 0,
        allow_legendary_jokers_everywhere = false,
        allow_duplicate_jokers = false,
        allow_black_hole = false,
        allow_soul = false,
        edition_rate = 1,
        spectral_cards_in_arcana = false,
        tarot_cards_in_spectral = false,
        tarot_cards_in_celestial = false,
        planet_cards_in_arcana = false,
        planet_cards_in_spectral = false,
        spectral_cards_in_celestial = false,
        rawDescription = "",
        copy_deck_config = nil,
        invert_back = true,
        uuid = Utils.uuid(),
        customCardList = CardUtils.standardCardSet(),
        customJokerList = {},
        customTarotList = {},
        customPlanetList = {},
        customSpectralList = {},
        customVoucherList = {},
        customTagList = {},
        bannedJokerList = {},
        bannedTarotList = {},
        bannedPlanetList = {},
        bannedSpectralList = {},
        bannedVoucherList = {},
        bannedTagList = {},
        bannedBlindList = {},
        bannedBoosterList = {},
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
        booster_ante_scaling = 0,
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
        no_aces = false,
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
        draw_to_hand_size = "--",
        chance_to_increase_discard_cards_rank = 0,
        chance_to_increase_drawn_cards_rank = 0,
        random_sell_value_increase = 0,
        random_polychrome_cards = 0,
        random_holographic_cards = 0,
        random_foil_cards = 0,
        random_edition_cards = 0,
        random_bonus_cards = 0,
        random_glass_cards = 0,
        random_lucky_cards = 0,
        random_steel_cards = 0,
        random_stone_cards = 0,
        random_wild_cards = 0,
        random_mult_cards = 0,
        random_gold_cards = 0,
        random_enhancement_cards = 0,
        blind_scaling = 1,
        tag_on_win_config = {}
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
                            customCardList, customCardsSet, customJokerList, customJokersSet, customTarotList, customTarotsSet, customPlanetList, customPlanetsSet, customSpectralList, customSpectralsSet, customVoucherList, customVouchersSet, customTagList, customTagsSet,
                            broken_glass_money, enhanced_dollars_per_round, negative_joker_money, negative_joker_for_broken_glass, balance_percent, double_tag_percent, randomize_ranks, randomize_suits, no_numbered_cards,
                            randomize_money_configurable, randomize_money_small, randomize_money_settings, randomize_appearance_rates, random_starting_jokers, randomize_hands_discards, random_starting_items,
                            randomly_enable_gameplay_settings, one_random_voucher, doubled_probabilities, halved_probabilities, negative_tag_percent, mega_standard_tag_percent, full_price_jokers, full_price_consumables,
                            chip_reduction_percent, mult_reduction_percent, draw_to_hand_size, chance_to_increase_discard_cards_rank, chance_to_increase_drawn_cards_rank, random_sell_value_increase, random_gold_cards,
                            random_polychrome_cards, random_holographic_cards, random_foil_cards, random_edition_cards, random_bonus_cards, random_glass_cards, random_lucky_cards, random_steel_cards, random_stone_cards,
                            random_wild_cards, random_mult_cards, random_enhancement_cards,
                            bannedJokerList, bannedTarotList, bannedPlanetList, bannedSpectralList, bannedVoucherList, bannedTagList, bannedBlindList, bannedBoosterList, blindScaling, rawDescription, no_aces,
                            skip_shop_chance_small_blind, skip_shop_chance_big_blind, skip_shop_chance_boss, skip_shop_chance_any,
                            skip_blind_disabled_chance_small_blind, skip_blind_disabled_chance_big_blind, skip_blind_disabled_chance_any, allow_legendary_jokers_everywhere, allow_duplicate_jokers,
                            edition_rate, spectral_cards_in_arcana, always_telescoping, allow_black_hole, allow_soul, never_telescoping,
                            tarot_cards_in_spectral, tarot_cards_in_celestial, planet_cards_in_arcana, planet_cards_in_spectral, spectral_cards_in_celestial,
                            standard_pack_edition_rate, standard_pack_enhancement_rate, standard_pack_seal_rate,
                            orbital_tag_percent, economy_tag_percent, skip_tag_percent, top_up_tag_percent, d6_tag_percent, juggle_tag_percent, coupon_tag_percent, ethereal_tag_percent, garbage_tag_percent,
                            handy_tag_percent, buffoon_tag_percent, meteor_tag_percent, charm_tag_percent, boss_tag_percent, voucher_tag_percent, investment_tag_percent, polychrome_tag_percent, holographic_tag_percent,
                            foil_tag_percent, uncommon_tag_percent, rare_tag_percent, blue_seal_switch_trigger, blue_seal_always_most_played, red_seal_silly_messages, extra_red_seal_repetitions, chance_to_double_gold_seal,
                            make_sevens_lucky, aces_are_faces, gain_dollars_when_skip_booster, reroll_boosters, extra_hand_level_upgrades, sevens_are_faces, multiply_probabilities, divide_probabilities,
                            triple_mult_cards_chance, disable_mult_cards_chance, gain_ten_dollars_glass_break_chance, replace_broken_glass_with_stones_chance, replace_broken_glass_with_random_cards_chance, stones_are_faces)
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
        if v.name == o.name and v.uuid == newUUID then
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
        stones_are_faces = stones_are_faces,
        replace_broken_glass_with_random_cards_chance = replace_broken_glass_with_random_cards_chance,
        replace_broken_glass_with_stones_chance = replace_broken_glass_with_stones_chance,
        gain_ten_dollars_glass_break_chance = gain_ten_dollars_glass_break_chance,
        triple_mult_cards_chance = triple_mult_cards_chance,
        disable_mult_cards_chance = disable_mult_cards_chance,
        multiply_probabilities = multiply_probabilities,
        divide_probabilities = divide_probabilities,
        extra_hand_level_upgrades = extra_hand_level_upgrades,
        reroll_boosters = reroll_boosters,
        gain_dollars_when_skip_booster = gain_dollars_when_skip_booster,
        aces_are_faces = aces_are_faces,
        sevens_are_faces = sevens_are_faces,
        make_sevens_lucky = make_sevens_lucky,
        chance_to_double_gold_seal = chance_to_double_gold_seal,
        extra_red_seal_repetitions = extra_red_seal_repetitions,
        red_seal_silly_messages = red_seal_silly_messages,
        blue_seal_always_most_played = blue_seal_always_most_played,
        blue_seal_switch_trigger = blue_seal_switch_trigger,
        orbital_tag_percent = orbital_tag_percent,
        economy_tag_percent = economy_tag_percent,
        skip_tag_percent = skip_tag_percent,
        top_up_tag_percent = top_up_tag_percent,
        d6_tag_percent = d6_tag_percent,
        juggle_tag_percent = juggle_tag_percent,
        coupon_tag_percent = coupon_tag_percent,
        ethereal_tag_percent = ethereal_tag_percent,
        garbage_tag_percent = garbage_tag_percent,
        handy_tag_percent = handy_tag_percent,
        buffoon_tag_percent = buffoon_tag_percent,
        meteor_tag_percent = meteor_tag_percent,
        charm_tag_percent = charm_tag_percent,
        boss_tag_percent = boss_tag_percent,
        voucher_tag_percent = voucher_tag_percent,
        investment_tag_percent = investment_tag_percent,
        polychrome_tag_percent = polychrome_tag_percent,
        holographic_tag_percent = holographic_tag_percent,
        foil_tag_percent = foil_tag_percent,
        rare_tag_percent = rare_tag_percent,
        uncommon_tag_percent = uncommon_tag_percent,
        standard_pack_edition_rate = standard_pack_edition_rate,
        standard_pack_enhancement_rate = standard_pack_enhancement_rate,
        standard_pack_seal_rate = standard_pack_seal_rate,
        allow_black_hole = allow_black_hole,
        allow_soul = allow_soul,
        always_telescoping = always_telescoping,
        never_telescoping = never_telescoping,
        spectral_cards_in_arcana = spectral_cards_in_arcana,
        tarot_cards_in_spectral = tarot_cards_in_spectral,
        tarot_cards_in_celestial = tarot_cards_in_celestial,
        planet_cards_in_arcana = planet_cards_in_arcana,
        planet_cards_in_spectral = planet_cards_in_spectral,
        spectral_cards_in_celestial = spectral_cards_in_celestial,
        edition_rate = edition_rate,
        allow_duplicate_jokers = allow_duplicate_jokers,
        allow_legendary_jokers_everywhere = allow_legendary_jokers_everywhere,
        skip_shop_chance_small_blind = skip_shop_chance_small_blind,
        skip_shop_chance_big_blind = skip_shop_chance_big_blind,
        skip_shop_chance_boss = skip_shop_chance_boss,
        skip_shop_chance_any = skip_shop_chance_any,
        skip_blind_disabled_chance_small_blind = skip_blind_disabled_chance_small_blind,
        skip_blind_disabled_chance_big_blind = skip_blind_disabled_chance_big_blind,
        skip_blind_disabled_chance_any = skip_blind_disabled_chance_any,
        rawDescription = rawDescription,
        copy_deck_config = copyDeckConfig,
        customJokerList = customJokerList,
        customTarotList = customTarotList,
        customPlanetList = customPlanetList,
        customSpectralList = customSpectralList,
        customVoucherList = customVoucherList,
        customTagList = customTagList,
        custom_jokers_set = customJokersSet,
        custom_tarots_set = customTarotsSet,
        custom_planets_set = customPlanetsSet,
        custom_spectrals_set = customSpectralsSet,
        custom_vouchers_set = customVouchersSet,
        custom_tags_set = customTagsSet,
        bannedJokerList = bannedJokerList,
        bannedTarotList = bannedTarotList,
        bannedPlanetList = bannedPlanetList,
        bannedSpectralList = bannedSpectralList,
        bannedVoucherList = bannedVoucherList,
        bannedTagList = bannedTagList,
        bannedBlindList = bannedBlindList,
        bannedBoosterList = bannedBoosterList,
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
        no_aces = no_aces,
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
        chance_to_increase_drawn_cards_rank = chance_to_increase_drawn_cards_rank,
        random_sell_value_increase = random_sell_value_increase,
        random_polychrome_cards = random_polychrome_cards,
        random_holographic_cards = random_holographic_cards,
        random_foil_cards = random_foil_cards,
        random_edition_cards = random_edition_cards,
        random_bonus_cards = random_bonus_cards,
        random_glass_cards = random_glass_cards,
        random_lucky_cards = random_lucky_cards,
        random_steel_cards = random_steel_cards,
        random_stone_cards = random_stone_cards,
        random_wild_cards = random_wild_cards,
        random_mult_cards = random_mult_cards,
        random_enhancement_cards = random_enhancement_cards,
        random_gold_cards = random_gold_cards,
        blind_scaling = blindScaling
    }

    o.config.tag_on_win_config = {
        orbital_tag_percent = { chance = orbital_tag_percent, key = 'tag_orbital'},
        economy_tag_percent = { chance = economy_tag_percent, key = 'tag_economy'},
        skip_tag_percent = { chance = skip_tag_percent, key = 'tag_skip'},
        top_up_tag_percent = { chance = top_up_tag_percent, key = 'tag_top_up'},
        d6_tag_percent = { chance = d6_tag_percent, key = 'tag_d_six'},
        juggle_tag_percent = { chance = juggle_tag_percent, key = 'tag_juggle'},
        coupon_tag_percent = { chance = coupon_tag_percent, key = 'tag_coupon'},
        ethereal_tag_percent = { chance = ethereal_tag_percent, key = 'tag_ethereal'},
        garbage_tag_percent = { chance = garbage_tag_percent, key = 'tag_garbage'},
        handy_tag_percent = { chance = handy_tag_percent, key = 'tag_handy'},
        buffoon_tag_percent = { chance = buffoon_tag_percent, key = 'tag_buffoon'},
        meteor_tag_percent = { chance = meteor_tag_percent, key = 'tag_meteor'},
        charm_tag_percent = { chance = charm_tag_percent, key = 'tag_charm'},
        boss_tag_percent = { chance = boss_tag_percent, key = 'tag_boss'},
        voucher_tag_percent = { chance = voucher_tag_percent, key = 'tag_voucher'},
        investment_tag_percent = { chance = investment_tag_percent, key = 'tag_investment'},
        polychrome_tag_percent = { chance = polychrome_tag_percent, key = 'tag_polychrome'},
        holographic_tag_percent = { chance = holographic_tag_percent, key = 'tag_holo'},
        foil_tag_percent = { chance = foil_tag_percent, key = 'tag_foil'},
        rare_tag_percent = { chance = rare_tag_percent, key = 'tag_rare'},
        uncommon_tag_percent = { chance = uncommon_tag_percent, key = 'tag_uncommon'},
        mega_standard_tag_percent = { chance = mega_standard_tag_percent, key = 'tag_standard'},
        negative_tag_percent = { chance = negative_tag_percent, key = 'tag_negative'},
        double_tag_percent = { chance = double_tag_percent, key = 'tag_double'},
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

    if doubled_probabilities == true and multiply_probabilities == 1 then
        o.config.multiply_probabilities = 2
    end

    if halved_probabilities == true and divide_probabilities == 1 then
        o.config.divide_probabilities = 2
    end

    return o
end

function CustomDeck.fullNewFromExisting(deck, descTable, updateUUID)

    if not deck.config and deck.effect and deck.effect.config then
        deck.config = deck.effect.config
    end

    return CustomDeck:fullNew(
            deck.name,
            {name = deck.name, text = descTable },
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
            deck.config.customTagList,
            deck.config.custom_tags_set,
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
            deck.config.chance_to_increase_drawn_cards_rank,
            deck.config.random_sell_value_increase,
            deck.config.random_gold_cards,
            deck.config.random_polychrome_cards,
            deck.config.random_holographic_cards,
            deck.config.random_foil_cards,
            deck.config.random_edition_cards,
            deck.config.random_bonus_cards,
            deck.config.random_glass_cards,
            deck.config.random_lucky_cards,
            deck.config.random_steel_cards,
            deck.config.random_stone_cards,
            deck.config.random_wild_cards,
            deck.config.random_mult_cards,
            deck.config.random_enhancement_cards,
            deck.config.bannedJokerList,
            deck.config.bannedTarotList,
            deck.config.bannedPlanetList,
            deck.config.bannedSpectralList,
            deck.config.bannedVoucherList,
            deck.config.bannedTagList,
            deck.config.bannedBlindList,
            deck.config.bannedBoosterList,
            deck.config.blind_scaling,
            deck.config.rawDescription,
            deck.config.no_aces,
            deck.config.skip_shop_chance_small_blind,
            deck.config.skip_shop_chance_big_blind,
            deck.config.skip_shop_chance_boss,
            deck.config.skip_shop_chance_any,
            deck.config.skip_blind_disabled_chance_small_blind,
            deck.config.skip_blind_disabled_chance_big_blind,
            deck.config.skip_blind_disabled_chance_any,
            deck.config.allow_legendary_jokers_everywhere,
            deck.config.allow_duplicate_jokers,
            deck.config.edition_rate,
            deck.config.spectral_cards_in_arcana,
            deck.config.always_telescoping,
            deck.config.allow_black_hole,
            deck.config.allow_soul,
            deck.config.never_telescoping,
            deck.config.tarot_cards_in_spectral,
            deck.config.tarot_cards_in_celestial,
            deck.config.planet_cards_in_arcana,
            deck.config.planet_cards_in_spectral,
            deck.config.spectral_cards_in_celestial,
            deck.config.standard_pack_edition_rate,
            deck.config.standard_pack_enhancement_rate,
            deck.config.standard_pack_seal_rate,
            deck.config.orbital_tag_percent,
            deck.config.economy_tag_percent,
            deck.config.skip_tag_percent,
            deck.config.top_up_tag_percent,
            deck.config.d6_tag_percent,
            deck.config.juggle_tag_percent,
            deck.config.coupon_tag_percent,
            deck.config.ethereal_tag_percent,
            deck.config.garbage_tag_percent,
            deck.config.handy_tag_percent,
            deck.config.buffoon_tag_percent,
            deck.config.meteor_tag_percent,
            deck.config.charm_tag_percent,
            deck.config.boss_tag_percent,
            deck.config.voucher_tag_percent,
            deck.config.investment_tag_percent,
            deck.config.polychrome_tag_percent,
            deck.config.holographic_tag_percent,
            deck.config.foil_tag_percent,
            deck.config.uncommon_tag_percent,
            deck.config.rare_tag_percent,
            deck.config.blue_seal_switch_trigger,
            deck.config.blue_seal_always_most_played,
            deck.config.red_seal_silly_messages,
            deck.config.extra_red_seal_repetitions,
            deck.config.chance_to_double_gold_seal,
            deck.config.make_sevens_lucky,
            deck.config.aces_are_faces,
            deck.config.gain_dollars_when_skip_booster,
            deck.config.reroll_boosters,
            deck.config.extra_hand_level_upgrades,
            deck.config.sevens_are_faces,
            deck.config.multiply_probabilities,
            deck.config.divide_probabilities,
            deck.config.triple_mult_cards_chance,
            deck.config.disable_mult_cards_chance,
            deck.config.gain_ten_dollars_glass_break_chance,
            deck.config.replace_broken_glass_with_stones_chance,
            deck.config.replace_broken_glass_with_random_cards_chance,
            deck.config.stones_are_faces
    )
end

function CustomDeck:register()
    if ModloaderHelper.SteamoddedLoaded and not SMODS.Decks[self] then
        table.insert(SMODS.Decks, self)
    end
end

function CustomDeck.unregister(deleteUUID)
    if ModloaderHelper.SteamoddedLoaded then
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
