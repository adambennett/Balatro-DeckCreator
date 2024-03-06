local Persistence = require "Persistence"
local GUI = require "GUI"
local Helper = require "GuiElementHelper"
local Utils = require "Utils"
local CardUtils = require "CardUtils"

local DeckCreator = {}
DeckCreator.Unloaded = false

function DeckCreator.Enable()

    Utils.registerGlobals()
    GUI.registerGlobals()
    GUI.registerModMenuUI()
    Helper.registerGlobals()
    Persistence.loadAllDeckLists()
    Persistence.setUnloadedLists()

    local CardClick = Card.click
    function Card:click()
        if GUI.DeckCreatorOpen then
            local compareProto
            for k,v in pairs(Utils.customDeckList[#Utils.customDeckList].config.customCardList) do
                if k == self.uuid then
                    compareProto = v
                    break
                end
            end

            if compareProto then
                local removeIndex
                for k,v in pairs(Utils.customDeckList[#Utils.customDeckList].config.customCardList) do
                    if v.value == compareProto.value and v.suit == compareProto.suit and v.edition == compareProto.edition and v.enhancement == compareProto.enhancement and v.seal == compareProto.seal then
                        removeIndex = k
                        break
                    end
                end
                if removeIndex ~= nil then
                    Utils.customDeckList[#Utils.customDeckList].config.customCardList[removeIndex] = nil
                end
            end

            self:remove()

            local memoryBefore = collectgarbage("count")
            GUI.updateAllDeckEditorAreas()
            local memoryAfter = collectgarbage("count")
            local diff = memoryAfter - memoryBefore
            if Utils.runMemoryChecks then
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
                    for k,v in pairs(Utils.customDeckList[#Utils.customDeckList].config.customVoucherList) do
                        if v == self.uuid.key then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.customDeckList[#Utils.customDeckList].config.customVoucherList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = collectgarbage("count")
                    GUI.updateAllStartingItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Vouchers]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'joker' then
                    local removeIndex
                    for k,v in pairs(Utils.customDeckList[#Utils.customDeckList].config.customJokerList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.customDeckList[#Utils.customDeckList].config.customJokerList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = collectgarbage("count")
                    GUI.updateAllStartingItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Jokers]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'tarot' then
                    local removeIndex
                    for k,v in pairs(Utils.customDeckList[#Utils.customDeckList].config.customTarotList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.customDeckList[#Utils.customDeckList].config.customTarotList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = collectgarbage("count")
                    GUI.updateAllStartingItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Tarots]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'planet' then
                    local removeIndex
                    for k,v in pairs(Utils.customDeckList[#Utils.customDeckList].config.customPlanetList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.customDeckList[#Utils.customDeckList].config.customPlanetList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = collectgarbage("count")
                    GUI.updateAllStartingItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Planets]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'spectral' then
                    local removeIndex
                    for k,v in pairs(Utils.customDeckList[#Utils.customDeckList].config.customSpectralList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.customDeckList[#Utils.customDeckList].config.customSpectralList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = collectgarbage("count")
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
        if self.effect.config.customDeck and self.effect.config.copy_deck_config ~= nil and self.effect.config.copy_deck_config ~= "None" then
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
        end

        local hadRerollSurplus = false
        local hadRerollGlut = false
        if self.effect.config.customDeck then
            self.effect.config.vouchers = self.effect.config.vouchers or {}
            for k,v in pairs(self.effect.config.customVoucherList) do
                if v ~= 'v_reroll_surplus' and v ~= 'v_reroll_glut' then
                    table.insert(self.effect.config.vouchers, v)
                elseif v == 'v_reroll_surplus' then
                    hadRerollSurplus = true
                elseif v == 'v_reroll_glut' then
                    hadRerollGlut = true
                end
            end

            if #self.effect.config.vouchers == 0 and not hadRerollGlut and not hadRerollSurplus then self.effect.config.vouchers = nil end
        end

        BackApply_to_runRef(self)

        if self.effect.config.customDeck then

            if self.effect.config.joker_rate == 0 and self.effect.config.tarot_rate == 0 and self.effect.config.planet_rate == 0 and self.effect.config.spectral_rate == 0 and self.effect.config.playing_card_rate == 0 then
                local rateNames = {"joker_rate", "tarot_rate", "planet_rate", "spectral_rate"}
                local randomIndex = math.random(1, #rateNames)
                local selectedRateName = rateNames[randomIndex]
                self.effect.config[selectedRateName] = 100
            end

            G.GAME.shop.joker_max = self.effect.config.shop_slots
            G.GAME.modifiers.inflation = self.effect.config.inflation
            G.GAME.joker_rate = self.effect.config.joker_rate
            G.GAME.tarot_rate = self.effect.config.tarot_rate
            G.GAME.planet_rate = self.effect.config.planet_rate
            G.GAME.playing_card_rate = self.effect.config.playing_card_rate
            G.GAME.interest_cap = self.effect.config.interest_cap
            G.GAME.discount_percent = self.effect.config.discount_percent
            G.GAME.modifiers.chips_dollar_cap = self.effect.config.chips_dollar_cap
            G.GAME.modifiers.discard_cost = self.effect.config.discard_cost
            G.GAME.modifiers.all_eternal = self.effect.config.all_eternal
            G.GAME.modifiers.debuff_played_cards = self.effect.config.debuff_played_cards

            if self.effect.config.flipped_cards then
                G.GAME.modifiers.flipped_cards = 4
            else
                G.GAME.modifiers.flipped_cards = nil
            end

            if self.effect.config.minus_hand_size_per_X_dollar then
                G.GAME.modifiers.minus_hand_size_per_X_dollar = 5
            else
                G.GAME.modifiers.minus_hand_size_per_X_dollar = nil
            end

            if G.GAME.stake >= 4 or (G.GAME.stake < 4 and self.effect.config.enable_eternals_in_shop) then
                G.GAME.modifiers.enable_eternals_in_shop = true
            else
                G.GAME.modifiers.enable_eternals_in_shop = false
            end

            if G.GAME.stake >= 7 or (G.GAME.stake < 7 and self.effect.config.booster_ante_scaling) then
                G.GAME.modifiers.booster_ante_scaling = true
            else
                G.GAME.modifiers.booster_ante_scaling = false
            end

            if self.effect.config.reroll_cost then
                G.GAME.starting_params.reroll_cost = self.effect.config.reroll_cost
                G.GAME.base_reroll_cost = self.effect.config.reroll_cost
            end

            if self.effect.config.win_ante ~= nil and self.effect.config.win_ante > 0 then
                G.GAME.win_ante = self.effect.config.win_ante
            end

            if self.effect.config.extra_hand_bonus == 0 then
                G.GAME.modifiers.no_extra_hand_money = true
            end

            if hadRerollSurplus then
                local v = 'v_reroll_surplus'
                table.insert(self.effect.config.vouchers, v)
                G.GAME.used_vouchers[v] = true
                G.GAME.starting_voucher_count = (G.GAME.starting_voucher_count or 0) + 1
                G.GAME.round_resets.reroll_cost = G.GAME.round_resets.reroll_cost - 2
                G.GAME.current_round.reroll_cost = math.max(0, G.GAME.current_round.reroll_cost - 2)
            end

            if hadRerollGlut then
                local v = 'v_reroll_glut'
                table.insert(self.effect.config.vouchers, v)
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

        local origReturn1, origReturn2 = BackTriggerEffect(self, args)
        if not args then return origReturn1, origReturn2 end

        if self.effect.config.double_tag and args.context == 'eval' and G.GAME.last_blind and G.GAME.last_blind.boss then
            G.E_MANAGER:add_event(Event({
                func = (function()
                    add_tag(Tag('tag_double'))
                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                    return true
                end)
            }))
        end

        if self.effect.config.balance_chips and args.context == 'blind_amount' then
            return
        end

        if self.effect.config.balance_chips and args.context == 'final_scoring_step' then
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
            return args.chips, args.mult
        end
        return origReturn1, origReturn2
    end

    if SMODS.BalamodMode then
        local RunSetup = G.UIDEF.run_setup
        G.UIDEF.run_setup = function(from_game_over)
            Persistence.refreshDeckList()
            return RunSetup(from_game_over)
        end
    end

    local GameStartRun = Game.start_run
    function Game:start_run(args)
        local deck = self.GAME.viewed_back

        if deck.effect.config.customDeck then
            args = args or {}
            args.challenge = {}
            args.challenge.jokers = {}
            args.challenge.consumables = {}
            Utils.log("Joker list:\n" .. Utils.tableToString(deck.effect.config.customJokerList))
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

            if deck.effect.config.custom_cards_set then
                CardUtils.initializeCustomCardList(deck.effect.config.customCardList)
            end

        end

        return originalResult
    end

    local KeyPress = G.CONTROLLER.key_press
    function G.CONTROLLER:key_press(key)
        KeyPress(self, key)
        -- Utils.log("Key pressed: " .. key)
        if key == 'escape' then
            GUI.CloseAllOpenFlags()
        end
        if key == '`' and G.DEBUG then
            G.DEBUG = false
        elseif key == '`' and G.DEBUG == false then
            G.DEBUG = true
        end
    end

    if not SMODS.BalamodMode then
        SMODS.Sprite:new("itemIcons", SMODS.findModByID("ADeckCreatorModule").path, "ItemIcons.png", 18, 18, "asset_atli"):register()
    end
end

function DeckCreator.Disable()
    G.P_CENTERS = Persistence.UnloadedCenters
    G.P_CENTER_POOLS.Back = Persistence.UnloadedDeckList
    DeckCreator.Unloaded = true
end

return DeckCreator
