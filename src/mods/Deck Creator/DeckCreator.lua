local Persistence = require "Persistence"
local GUI = require "GUI"
local Helper = require "GuiElementHelper"
local Utils = require "Utils"
local CardUtils = require "CardUtils"
local ModloaderHelper = require "ModloaderHelper"

local DeckCreator = {}
DeckCreator.hadPaintbrush = false
DeckCreator.hadPalette = false

function DeckCreator.Enable()

    ModloaderHelper.DeckCreatorLoader = true
    Utils.disabledSlugs = {}
    Utils.registerGlobals()
    GUI.registerGlobals()
    Helper.registerGlobals()
    Persistence.loadAllDeckLists()
    GUI.registerModMenuUI()

    local LoadProfile = G.FUNCS.load_profile
    G.FUNCS.load_profile = function(delete_prof_data)
        LoadProfile(delete_prof_data)
        G.E_MANAGER:add_event(Event({
            delay = 0.5,
            no_delete = true,
            blockable = true,
            blocking = false,
            func = function()
                Persistence.refreshDeckList()
                Utils.log("Back list after reset list:\n" .. Utils.tableToString(G.P_CENTER_POOLS.Back))
                return true
            end
        }))
    end

    local EndRound = end_round
    function end_round()
        EndRound()

        local deck = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config or nil
        if deck.customDeck then
            if G.jokers and G.jokers.cards and #G.jokers.cards > 0 and deck.random_sell_value_increase and deck.random_sell_value_increase > 0 then
                local list = G.jokers.cards
                local rand = list[math.random(1, #list)]
                if rand.set_cost then
                    rand.ability.extra_value = (rand.ability.extra_value or 0) + deck.random_sell_value_increase
                    rand:set_cost()
                end
            end
        end
    end

    local DrawCardFrom = CardArea.draw_card_from
    function CardArea:draw_card_from(area, stay_flipped, discarded_only)
        local isCustomDeckWithRankIncOnDraw = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and G.GAME.selected_back.effect.config.chance_to_increase_drawn_cards_rank and G.GAME.selected_back.effect.config.chance_to_increase_drawn_cards_rank > 0 or false
        if isCustomDeckWithRankIncOnDraw and (self and area and self == G.hand and area == G.deck) and area:is(CardArea) then
            local chance = G.GAME.selected_back.effect.config.chance_to_increase_drawn_cards_rank
            local rankIncreaseRoll = chance == 100 and 0 or math.random(1, 100)
            if rankIncreaseRoll <= chance then
                local card = area:remove_card(nil, discarded_only)
                if card then
                    local stay_flipped = G.GAME and G.GAME.blind and G.GAME.blind:stay_flipped(self, card)
                    if (self == G.hand) and G.GAME.modifiers.flipped_cards then
                        if pseudorandom(pseudoseed('flipped_card')) < 1/G.GAME.modifiers.flipped_cards then
                            stay_flipped = true
                        end
                    end

                    G.E_MANAGER:add_event(Event({trigger = 'immediate',delay = 0.1,func = function()
                        local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                        local rank_suffix = card.base.id == 14 and 2 or math.min(card.base.id+1, 14)
                        if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                        elseif rank_suffix == 10 then rank_suffix = 'T'
                        elseif rank_suffix == 11 then rank_suffix = 'J'
                        elseif rank_suffix == 12 then rank_suffix = 'Q'
                        elseif rank_suffix == 13 then rank_suffix = 'K'
                        elseif rank_suffix == 14 then rank_suffix = 'A'
                        end
                        card:set_base(G.P_CARDS[suit_prefix..rank_suffix])

                        return true
                    end }))

                    self:emplace(card, nil, stay_flipped)
                    return true
                end
            end
        end

        return DrawCardFrom(self, area, stay_flipped, discarded_only)
    end

    local DrawCard = draw_card
    function draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)

        if card and from == G.hand and to == G.discard and G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.chance_to_increase_discard_cards_rank and G.GAME.selected_back.effect.config.chance_to_increase_discard_cards_rank > 0 then
            local chance = G.GAME.selected_back.effect.config.chance_to_increase_discard_cards_rank
            local rankIncreaseRoll = chance == 100 and 0 or math.random(1, 100)
            if rankIncreaseRoll <= chance then
                G.E_MANAGER:add_event(Event({trigger = 'immediate',delay = 0.1,func = function()
                    local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                    local rank_suffix = card.base.id == 14 and 2 or math.min(card.base.id+1, 14)
                    if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
                    elseif rank_suffix == 10 then rank_suffix = 'T'
                    elseif rank_suffix == 11 then rank_suffix = 'J'
                    elseif rank_suffix == 12 then rank_suffix = 'Q'
                    elseif rank_suffix == 13 then rank_suffix = 'K'
                    elseif rank_suffix == 14 then rank_suffix = 'A'
                    end
                    card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                    return true
                end }))
            end
        end

        DrawCard(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
    end

    local DrawFromDeckToHand = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(e)
        if G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.draw_to_hand_size and G.GAME.selected_back.effect.config.draw_to_hand_size ~= "--" and
                not (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK) and
                (G.GAME.current_round.hands_played > 0 or G.GAME.current_round.discards_used > 0) then
            e = math.min(#G.deck.cards, G.GAME.selected_back.effect.config.draw_to_hand_size)
        end
        DrawFromDeckToHand(e)
    end

    local EvaluteRound = G.FUNCS.evaluate_round
    G.FUNCS.evaluate_round = function()
        EvaluteRound()
        -- add_round_eval_row({bonus = true, name='Deck Creator Module', pitch = 0.95, dollars = 10 })
        local deck = G.GAME.selected_back
        if deck and deck.effect.config.customDeck then
            if deck.effect.config.enhanced_dollars_per_round and deck.effect.config.enhanced_dollars_per_round > 0 then
                local enhancedCards = 0
                for k,v in pairs(G.playing_cards) do
                    if v.config.center ~= G.P_CENTERS.c_base then
                        enhancedCards = enhancedCards + 1
                    end
                end
                if enhancedCards > 0 then
                    Utils.addDollarAmountAtEndOfRound(enhancedCards * deck.effect.config.enhanced_dollars_per_round, "Enhanced Cards ($1 each)")
                end
            end

            if deck.effect.config.negative_joker_money and deck.effect.config.negative_joker_money > 0 then
                local negativeJokers = 0
                for k,v in pairs(G.jokers.cards) do
                    if v.edition and v.edition.negative then
                        negativeJokers = negativeJokers + 1
                    end
                end

                if negativeJokers > 0 then
                    ease_dollars(-1 * negativeJokers * deck.effect.config.negative_joker_money, true)
                end
            end
        end

    end

    local SetCost = Card.set_cost
    function Card:set_cost()
        local fullPriced = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and (self.ability.set == "Joker" and G.GAME.selected_back.effect.config.full_price_jokers) or ((self.ability.set == 'Planet' or self.ability.set == 'Tarot' or self.ability.set == 'Spectral') and G.GAME.selected_back.effect.config.full_price_consumables)
        self.extra_cost = 0 + G.GAME.inflation
        if self.edition then
            self.extra_cost = self.extra_cost + (self.edition.holo and 3 or 0) + (self.edition.foil and 2 or 0) +
                    (self.edition.polychrome and 5 or 0) + (self.edition.negative and 5 or 0)
        end
        self.cost = math.max(1, math.floor((self.base_cost + self.extra_cost + 0.5)*(100-G.GAME.discount_percent)/100))
        if self.ability.set == 'Booster' and G.GAME.modifiers.booster_ante_scaling then self.cost = self.cost + G.GAME.round_resets.ante - 1 end
        if self.ability.set == 'Booster' and (not G.SETTINGS.tutorial_complete) and G.SETTINGS.tutorial_progress and (not G.SETTINGS.tutorial_progress.completed_parts['shop_1']) then
            self.cost = self.cost + 3
        end
        if (self.ability.set == 'Planet' or (self.ability.set == 'Booster' and self.ability.name:find('Celestial'))) and #find_joker('Astronomer') > 0 then self.cost = 0 end
        if fullPriced then
            self.sell_cost = math.max(1, math.floor(self.cost)) + (self.ability.extra_value or 0)
        else self.sell_cost = math.max(1, math.floor(self.cost/2)) + (self.ability.extra_value or 0)
            if self.area and self.ability.couponed and (self.area == G.shop_jokers or self.area == G.shop_booster) then self.cost = 0 end
            self.sell_cost_label = self.facing == 'back' and '?' or self.sell_cost
        end
    end

    local CardShatter = Card.shatter
    function Card:shatter()
        CardShatter(self)
        local deck = G.GAME.selected_back
        if deck and deck.effect.config.customDeck then
            if deck.effect.config.broken_glass_money and deck.effect.config.broken_glass_money > 0 then
                ease_dollars(deck.effect.config.broken_glass_money, true)
            end

            if deck.effect.config.negative_joker_for_broken_glass then
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
        end
    end

    local CardClick = Card.click
    function Card:click()
        if GUI.DeckCreatorOpen then
            local compareProto
            for k,v in pairs(Utils.getCurrentEditingDeck().config.customCardList) do
                if k == self.uuid then
                    compareProto = v
                    break
                end
            end

            if compareProto then
                local removeIndex
                for k,v in pairs(Utils.getCurrentEditingDeck().config.customCardList) do
                    if v.value == compareProto.value and v.suit == compareProto.suit and v.edition == compareProto.edition and v.enhancement == compareProto.enhancement and v.seal == compareProto.seal then
                        removeIndex = k
                        break
                    end
                end
                if removeIndex ~= nil then
                    Utils.getCurrentEditingDeck().config.customCardList[removeIndex] = nil
                end
            end

            self:remove()

            local memoryBefore = Utils.checkMemory()
            GUI.updateAllDeckEditorAreas()

            if Utils.runMemoryChecks then
                local memoryAfter = collectgarbage("count")
                local diff = memoryAfter - memoryBefore
                Utils.log("MEMORY CHECK (UpdateDynamicAreas - Deck Editor): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
            end
            return
        elseif GUI.StartingItemsOpen then

            -- Adding item by clicking
            if GUI.OpenStartingItemConfig.openItemType ~= nil then
                local added = false
                if GUI.OpenStartingItemConfig.openItemType == 'voucher' then
                    added = CardUtils.addItemToDeck({ voucher = true, ref = 'customVoucherList', addCard = self.config.center.key, deck_list = Utils.customDeckList})
                elseif GUI.OpenStartingItemConfig.openItemType == 'joker' then
                    added = CardUtils.addItemToDeck({ joker = true, ref = 'customJokerList', addCard = { id = self.config.center.key, key = self.config.center.key, copies = GUI.OpenStartingItemConfig.copies, eternal = GUI.OpenStartingItemConfig.eternal, pinned = GUI.OpenStartingItemConfig.pinned, edition = GUI.OpenStartingItemConfig.edition }, deck_list = Utils.customDeckList})
                elseif GUI.OpenStartingItemConfig.openItemType == 'tarot' then
                    added = CardUtils.addItemToDeck({ tarot = true, ref = 'customTarotList', addCard = { key = self.config.center.key, copies = GUI.OpenStartingItemConfig.copies, edition = GUI.OpenStartingItemConfig.edition }, deck_list = Utils.customDeckList})
                elseif GUI.OpenStartingItemConfig.openItemType == 'planet' then
                    added = CardUtils.addItemToDeck({ planet = true, ref = 'customPlanetList', addCard = { key = self.config.center.key, copies = GUI.OpenStartingItemConfig.copies, edition = GUI.OpenStartingItemConfig.edition }, deck_list = Utils.customDeckList})
                elseif GUI.OpenStartingItemConfig.openItemType == 'spectral' then
                    added = CardUtils.addItemToDeck({ spectral = true, ref = 'customSpectralList', addCard = { key = self.config.center.key, copies = GUI.OpenStartingItemConfig.copies, edition = GUI.OpenStartingItemConfig.edition }, deck_list = Utils.customDeckList})
                end

                if added then
                    self:start_materialize(nil, true)
                end

            -- Removing from Starting Items by clicking
            else
                if self.uuid and self.uuid.type == 'voucher' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.customVoucherList) do
                        if v == self.uuid.key then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.customVoucherList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllStartingItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Vouchers]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'joker' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.customJokerList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.customJokerList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllStartingItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Jokers]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'tarot' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.customTarotList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.customTarotList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllStartingItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Tarots]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'planet' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.customPlanetList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.customPlanetList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllStartingItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Planets]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'spectral' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.customSpectralList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.customSpectralList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllStartingItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Spectrals]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                end
            end


        end

        CardClick(self)
    end

    local BackApply_to_runRef = Back.apply_to_run
    function Back:apply_to_run()
        --[[if self.effect.config.customDeck and self.effect.config.copy_deck_config ~= nil and self.effect.config.copy_deck_config ~= "None" then
            local copyConfig
            for k,v in pairs(G.P_CENTER_POOLS.Back) do
                if v.name == self.effect.config.copy_deck_config then
                    copyConfig = v.config
                    break
                end
            end

            if copyConfig then
                for k,v in pairs(copyConfig) do
                    self.effect.config[k] = v
                end
            end
        end]]

        local hadRerollSurplus = false
        local hadRerollGlut = false
        DeckCreator.hadPaintbrush = false
        DeckCreator.hadPalette = false
        if self.effect.config.customDeck then
            local config = self.effect.config
            config.vouchers = config.vouchers or {}
            for k,v in pairs(config.customVoucherList) do
                if v ~= 'v_reroll_surplus' and v ~= 'v_reroll_glut' and v ~= 'v_paint_brush' and v ~= 'v_palette' then
                    table.insert(config.vouchers, v)
                elseif v == 'v_reroll_surplus' then
                    hadRerollSurplus = true
                elseif v == 'v_reroll_glut' then
                    hadRerollGlut = true
                elseif v == 'v_paint_brush' then
                    DeckCreator.hadPaintbrush = true
                elseif v == 'v_palette' then
                    DeckCreator.hadPalette = true
                end
            end

            if config.one_random_voucher then
                local allVouchers = Utils.vouchers(true)
                if #config.vouchers ~= #allVouchers then
                    local randomVouch
                    local loopMax = 999
                    while randomVouch == nil and loopMax > 0 do
                        randomVouch = allVouchers[math.random(1, #allVouchers)].id
                        for k,v in pairs(config.vouchers) do
                            if v == randomVouch then
                                randomVouch = nil
                                break
                            end
                        end
                        loopMax = loopMax - 1
                    end

                    if randomVouch ~= nil then
                        if randomVouch == 'v_reroll_surplus' then
                            hadRerollSurplus = true
                        elseif randomVouch == 'v_reroll_glut' then
                            hadRerollGlut = true
                        elseif randomVouch == 'v_paint_brush' then
                            DeckCreator.hadPaintbrush = true
                        elseif randomVouch == 'v_palette' then
                            DeckCreator.hadPalette = true
                        else
                            table.insert(config.vouchers, randomVouch)
                        end
                    end
                end
            end

            if #config.vouchers == 0 and not hadRerollGlut and not hadRerollSurplus and not DeckCreator.hadPaintbrush and not DeckCreator.hadPalette then config.vouchers = nil end

            if config.randomize_money_configurable and config.randomize_money_configurable > 0 then
                local moneyRoll = math.random(0, config.randomize_money_configurable)
                if moneyRoll > 0 then
                    config.dollars = config.dollars + moneyRoll
                end
            end

            if config.randomize_money_small then
                local moneyRoll = math.random(0, 20)
                if moneyRoll > 0 then
                    config.dollars = config.dollars + moneyRoll
                end
            end
        end

        BackApply_to_runRef(self)

        if self.effect.config.customDeck then

            local config = self.effect.config
            if config.joker_rate == 0 and config.tarot_rate == 0 and config.planet_rate == 0 and config.spectral_rate == 0 and config.playing_card_rate == 0 then
                local rateNames = {"joker_rate", "tarot_rate", "planet_rate", "spectral_rate"}
                local randomIndex = math.random(1, #rateNames)
                local selectedRateName = rateNames[randomIndex]
                config[selectedRateName] = 100
            end

            G.GAME.shop.joker_max = config.shop_slots
            G.GAME.modifiers.inflation = config.inflation
            G.GAME.joker_rate = config.joker_rate
            G.GAME.tarot_rate = config.tarot_rate
            G.GAME.planet_rate = config.planet_rate
            G.GAME.playing_card_rate = config.playing_card_rate
            G.GAME.interest_cap = config.interest_cap
            G.GAME.discount_percent = config.discount_percent
            G.GAME.modifiers.chips_dollar_cap = config.chips_dollar_cap
            G.GAME.modifiers.discard_cost = config.discard_cost
            G.GAME.modifiers.all_eternal = config.all_eternal
            G.GAME.modifiers.debuff_played_cards = config.debuff_played_cards

            if config.flipped_cards and config.flipped_cards > 0 then
                G.GAME.modifiers.flipped_cards = config.flipped_cards
            else
                G.GAME.modifiers.flipped_cards = nil
            end

            if config.minus_hand_size_per_X_dollar then
                G.GAME.modifiers.minus_hand_size_per_X_dollar = 5
            else
                G.GAME.modifiers.minus_hand_size_per_X_dollar = nil
            end

            if G.GAME.stake >= 4 or (G.GAME.stake < 4 and config.enable_eternals_in_shop) then
                G.GAME.modifiers.enable_eternals_in_shop = true
            else
                G.GAME.modifiers.enable_eternals_in_shop = false
            end

            if G.GAME.stake >= 7 or (G.GAME.stake < 7 and config.booster_ante_scaling) then
                G.GAME.modifiers.booster_ante_scaling = true
            else
                G.GAME.modifiers.booster_ante_scaling = false
            end

            if config.reroll_cost then
                G.GAME.starting_params.reroll_cost = config.reroll_cost
                G.GAME.base_reroll_cost = config.reroll_cost
            end

            if config.win_ante ~= nil and config.win_ante > 0 then
                G.GAME.win_ante = config.win_ante
            end

            if config.extra_hand_bonus == 0 then
                G.GAME.modifiers.no_extra_hand_money = true
            end

            if hadRerollSurplus then
                local v = 'v_reroll_surplus'
                table.insert(config.vouchers, v)
                G.GAME.used_vouchers[v] = true
                G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
                G.GAME.round_resets.reroll_cost = G.GAME.round_resets.reroll_cost - 2
                G.GAME.current_round.reroll_cost = math.max(0, G.GAME.current_round.reroll_cost - 2)
            end

            if hadRerollGlut then
                local v = 'v_reroll_glut'
                table.insert(config.vouchers, v)
                G.GAME.used_vouchers[v] = true
                G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
                G.GAME.round_resets.reroll_cost = G.GAME.round_resets.reroll_cost - 2
                G.GAME.current_round.reroll_cost = math.max(0, G.GAME.current_round.reroll_cost - 2)
            end

            Utils.fullDeckConversionFunctions(self)
        end

    end

    local BackTriggerEffect = Back.trigger_effect
    function Back:trigger_effect(args)

        local chips, mult = BackTriggerEffect(self, args)
        if not args then
            return chips, mult
        end

        if args.context == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
            if self.effect.config.double_tag_percent and self.effect.config.double_tag_percent > 0 then
                local tagRoll = self.effect.config.double_tag_percent == 100 and 0 or math.random(1, 100)
                if tagRoll <= self.effect.config.double_tag_percent then
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            add_tag(Tag('tag_double'))
                            play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                            play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                            return true
                        end)
                    }))
                end
            end

            if self.effect.config.negative_tag_percent and self.effect.config.negative_tag_percent > 0 then
                local tagRoll = self.effect.config.negative_tag_percent == 100 and 0 or math.random(1, 100)
                if tagRoll <= self.effect.config.negative_tag_percent then
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            add_tag(Tag('tag_negative'))
                            play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                            play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                            return true
                        end)
                    }))
                end
            end
        end


        if self.effect.config.balance_chips and args.context == 'blind_amount' then
            return
        end

        if args.context == 'final_scoring_step' then
            if self.effect.config.balance_percent and self.effect.config.balance_percent > 0 then
                local balanceRoll = self.effect.config.balance_percent == 100 and 0 or math.random(1, 100)
                if balanceRoll <= self.effect.config.balance_percent then
                    local tot = args.chips + args.mult
                    args.chips = math.floor(tot/2)
                    args.mult = math.floor(tot/2)
                    update_hand_text({delay = 0}, { mult = args.mult, chips = args.chips})
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            local text = localize('k_balanced')
                            play_sound('gong', 0.94, 0.3)
                            play_sound('gong', 0.94*1.5, 0.2)
                            play_sound('tarot1', 1.5)
                            ease_colour(G.C.UI_CHIPS, {0.8, 0.45, 0.85, 1})
                            ease_colour(G.C.UI_MULT, {0.8, 0.45, 0.85, 1})
                            attention_text({
                                scale = 1.4, text = text, hold = 2, align = 'cm', offset = {x = 0,y = -2.7},major = G.play
                            })
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                blockable = false,
                                blocking = false,
                                delay =  4.3,
                                func = (function()
                                    ease_colour(G.C.UI_CHIPS, G.C.BLUE, 2)
                                    ease_colour(G.C.UI_MULT, G.C.RED, 2)
                                    return true
                                end)
                            }))
                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                blockable = false,
                                blocking = false,
                                no_delete = true,
                                delay =  6.3,
                                func = (function()
                                    G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] = G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
                                    G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] = G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
                                    return true
                                end)
                            }))
                            return true
                        end)
                    }))
                    delay(0.6)
                    chips, mult = args.chips, args.mult
                end
            end

            local triggeredEitherReduction = false
            if self.effect.config.chip_reduction_percent and self.effect.config.chip_reduction_percent > 0 and self.effect.config.chip_reduction_percent < 100 then
                local mod = self.effect.config.chip_reduction_percent / 100
                local reduce = 1 - mod
                local chip = chips or args.chips
                chips = chip * reduce
                args.chips = chips
                triggeredEitherReduction = true
            end

            if self.effect.config.mult_reduction_percent and self.effect.config.mult_reduction_percent > 0 and self.effect.config.mult_reduction_percent < 100 then
                local mod = self.effect.config.mult_reduction_percent / 100
                local reduce = 1 - mod
                local mul = mult or args.mult
                mult = mul * reduce
                args.mult = mult
                triggeredEitherReduction = true
            end

            --[[if triggeredEitherReduction then
                update_hand_text({delay = 0}, { mult = args.mult, chips = args.chips})
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        play_sound('gong', 0.94, 0.3)
                        play_sound('gong', 0.94*1.5, 0.2)
                        play_sound('tarot1', 1.5)
                        ease_colour(G.C.UI_CHIPS, {0.8, 0.45, 0.85, 1})
                        ease_colour(G.C.UI_MULT, {0.8, 0.45, 0.85, 1})
                        -- delay(1)
                        attention_text({
                            scale = 1.4, text = "Reduced", hold = 2, align = 'cm', offset = {x = 0,y = -0.7},major = G.play
                        })
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            blockable = false,
                            blocking = false,
                            delay =  4.3,
                            func = (function()
                                ease_colour(G.C.UI_CHIPS, G.C.BLUE, 2)
                                ease_colour(G.C.UI_MULT, G.C.RED, 2)
                                return true
                            end)
                        }))
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            blockable = false,
                            blocking = false,
                            no_delete = true,
                            delay =  6.3,
                            func = (function()
                                G.C.UI_CHIPS[1], G.C.UI_CHIPS[2], G.C.UI_CHIPS[3], G.C.UI_CHIPS[4] = G.C.BLUE[1], G.C.BLUE[2], G.C.BLUE[3], G.C.BLUE[4]
                                G.C.UI_MULT[1], G.C.UI_MULT[2], G.C.UI_MULT[3], G.C.UI_MULT[4] = G.C.RED[1], G.C.RED[2], G.C.RED[3], G.C.RED[4]
                                return true
                            end)
                        }))
                        return true
                    end)
                }))
                delay(0.6)
            end]]
        end
        return chips, mult
    end

    if ModloaderHelper.BalamodLoaded then
        local RunSetup = G.UIDEF.run_setup
        G.UIDEF.run_setup = function(from_game_over)
            Persistence.refreshDeckList()
            return RunSetup(from_game_over)
        end
    end

    local GameStartRun = Game.start_run
    function Game:start_run(args)
        local deck = self.GAME.viewed_back

        if deck and deck.effect and deck.effect.config and deck.effect.config.customDeck then
            args = args or {}
            args.challenge = {}
            args.challenge.jokers = {}
            args.challenge.consumables = {}
            for k,v in pairs(deck.effect.config.customJokerList) do
                table.insert(args.challenge.jokers, v)
            end
            for k,v in pairs(deck.effect.config.customTarotList) do
                table.insert(args.challenge.consumables, {id = v.key, edition = v.edition})
            end
            for k,v in pairs(deck.effect.config.customPlanetList) do
                table.insert(args.challenge.consumables, {id = v.key, edition = v.edition})
            end
            for k,v in pairs(deck.effect.config.customSpectralList) do
                table.insert(args.challenge.consumables, {id = v.key, edition = v.edition})
            end
        end

        local originalResult = GameStartRun(self, args)

        -- re-set deck var after original function modifies
        deck = self.GAME.selected_back

        if deck.effect.config.customDeck then

            for k, v in ipairs(args.challenge.consumables) do
                G.E_MANAGER:add_event(Event({
                    func = function()
                        add_joker(v.id, v.edition, k ~= 1)
                        return true
                    end
                }))
            end

            if deck.effect.config.random_starting_jokers and deck.effect.config.random_starting_jokers > 0 then
                for i = 1, deck.effect.config.random_starting_jokers do
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local card = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'rif')
                            card:add_to_deck()
                            G.jokers:emplace(card)
                            card:start_materialize()
                            G.GAME.joker_buffer = 0
                            return true
                        end
                    }))
                end
            end

            if deck.effect.config.custom_cards_set then
                CardUtils.initializeCustomCardList(deck)
            else
                local config = deck.effect.config
                local randomizeRanks = config.randomize_ranks
                local randomizeSuits = config.randomize_suits
                local noNumbered = config.no_numbered_cards
                local poly = config.random_polychrome_cards
                local holo = config.random_holographic_cards
                local foil = config.random_foil_cards
                local edition = config.random_edition_cards
                local bonus = config.random_bonus_cards
                local glass = config.random_glass_cards
                local lucky = config.random_lucky_cards
                local steel = config.random_steel_cards
                local stone = config.random_stone_cards
                local wild = config.random_wild_cards
                local mult = config.random_mult_cards
                local enhance = config.random_enhancement_cards
                if randomizeRanks or randomizeSuits or noNumbered or poly > 0 or holo > 0 or foil > 0 or edition > 0 or bonus > 0 or glass > 0 or lucky > 0 or steel > 0 or stone > 0 or wild > 0 or mult > 0 or enhance > 0 then
                    config.customCardList = CardUtils.standardCardSet()
                    CardUtils.initializeCustomCardList(deck)
                end
            end

            if deck.effect.config.doubled_probabilities and not deck.effect.config.halved_probabilities then
                for k, v in pairs(G.GAME.probabilities) do
                    G.GAME.probabilities[k] = v*2
                end
            elseif deck.effect.config.halved_probabilities and not deck.effect.config.doubled_probabilities then
                for k, v in pairs(G.GAME.probabilities) do
                    G.GAME.probabilities[k] = v/2
                end
            end

            if DeckCreator.hadPaintbrush then
                local v = 'v_paint_brush'
                G.GAME.used_vouchers[v] = true
                G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
                G.hand:change_size(1)
            end

            if DeckCreator.hadPalette then
                local v = 'v_palette'
                G.GAME.used_vouchers[v] = true
                G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
                G.hand:change_size(1)
            end
        end

        return originalResult
    end

    local KeyPress = G.CONTROLLER.key_press
    function G.CONTROLLER:key_press(key)
        KeyPress(self, key)
        if key == 'escape' then
            GUI.CloseAllOpenFlags()
            GUI.ManageDecksConfig.manageDecksOpen = false
            GUI.addCard = GUI.resetAddCard()
        end
        if key == '`' and G.DEBUG then
            G.DEBUG = false
        elseif key == '`' and G.DEBUG == false then
            G.DEBUG = true
        end
    end

    if ModloaderHelper.SteamoddedLoaded then
        SMODS.Sprite:new("itemIcons", SMODS.findModByID("ADeckCreatorModule").path, "ItemIcons.png", 18, 18, "asset_atli"):register()
    end
end

function DeckCreator.Disable()
    ModloaderHelper.DeckCreatorLoader = false
    Utils.disabledSlugs = {}
    for k,v in pairs(Utils.customDeckList) do
        table.insert(Utils.disabledSlugs, { slug = v.slug, order = v.config.centerPosition })
    end
    Persistence.refreshDeckList()
end

return DeckCreator
