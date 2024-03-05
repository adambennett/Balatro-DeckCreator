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
            if GUI.openItemType ~= nil then
                local added = false
                if GUI.openItemType == 'voucher' then
                    added = CardUtils.addItemToDeck({ voucher = true, ref = 'customVoucherList', addCard = self.config.center.key, deck_list = Utils.customDeckList})
                elseif GUI.openItemType == 'joker' then
                    added = CardUtils.addItemToDeck({ joker = true, ref = 'customJokerList', addCard = { id = self.config.center.key, key = self.config.center.key, isEternal = false, isPinned = false, edition = nil }, deck_list = Utils.customDeckList})
                elseif GUI.openItemType == 'tarot' then
                    added = CardUtils.addItemToDeck({ tarot = true, ref = 'customTarotList', addCard = { key = self.config.center.key, edition = nil }, deck_list = Utils.customDeckList})
                elseif GUI.openItemType == 'planet' then
                    added = CardUtils.addItemToDeck({ planet = true, ref = 'customPlanetList', addCard = { key = self.config.center.key, edition = nil }, deck_list = Utils.customDeckList})
                elseif GUI.openItemType == 'spectral' then
                    added = CardUtils.addItemToDeck({ spectral = true, ref = 'customSpectralList', addCard = { key = self.config.center.key, edition = nil }, deck_list = Utils.customDeckList})
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
                        Utils.customDeckList[#Utils.customDeckList].config.customVoucherList[removeIndex] = nil
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
                        if v.key == self.uuid.key then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        Utils.customDeckList[#Utils.customDeckList].config.customJokerList[removeIndex] = nil
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
                        if v.key == self.uuid.key then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        Utils.customDeckList[#Utils.customDeckList].config.customTarotList[removeIndex] = nil
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
                        if v.key == self.uuid.key then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        Utils.customDeckList[#Utils.customDeckList].config.customPlanetList[removeIndex] = nil
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
                        if v.key == self.uuid.key then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        Utils.customDeckList[#Utils.customDeckList].config.customSpectralList[removeIndex] = nil
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
            args.challenge.consumeables = {}
            for k,v in pairs(deck.effect.config.customJokerList) do
                table.insert(args.challenge.jokers, v)
            end
            for k,v in pairs(deck.effect.config.customTarotList) do
                table.insert(args.challenge.consumeables, {id = v.key})
            end
            for k,v in pairs(deck.effect.config.customPlanetList) do
                table.insert(args.challenge.consumeables, {id = v.key})
            end
            for k,v in pairs(deck.effect.config.customSpectralList) do
                table.insert(args.challenge.consumeables, {id = v.key})
            end
        end

        local originalResult = GameStartRun(self, args)

        -- re-set deck var after original function modifies
        deck = self.GAME.selected_back

        if deck.effect.config.customDeck then

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

    --[[local RunSetupCheckBackName = G.FUNCS.RUN_SETUP_check_back_name
    G.FUNCS.RUN_SETUP_check_back_name = function(e)
        RunSetupCheckBackName(e)

    end]]

    --[[local ChangeViewedBack = G.FUNCS.change_viewed_back
    G.FUNCS.change_viewed_back = function(args)
        ChangeViewedBack(args)
        local _card = G.sticker_card
        _card:set_sprites(_card.config.center)
    end]]

    --[[local SetSpritePos = Sprite.set_sprite_pos
    function Sprite:set_sprite_pos(sprite_pos)
        Utils.log("Sprite: " .. Utils.tableToString(sprite_pos))
        if sprite_pos.customDeck then
            Utils.log("Was custom deck sprite")
            if sprite_pos and sprite_pos.v then
                self.sprite_pos = {x = (math.random(sprite_pos.v)-1), y = sprite_pos.y}
            else
                self.sprite_pos = sprite_pos or {x=0,y=0}
            end
            self.sprite_pos_copy = {x = self.sprite_pos.x, y = self.sprite_pos.y}

            self.sprite = love.graphics.newQuad(
                    self.sprite_pos.x*self.atlas.px,
                    self.sprite_pos.y*self.atlas.py,
                    self.scale.x,
                    self.scale.y, G.ASSET_ATLAS["testCenters"].image:getDimensions())

            self.image_dims = {}
            self.image_dims[1], self.image_dims[2] = G.ASSET_ATLAS["testCenters"].image:getDimensions()
        else
            SetSpritePos(self, sprite_pos)
        end
    end]]

    --[[local CardSetSprites = Card.set_sprites
    function Card:set_sprites(_center, _front)
        Utils.log("Running set_sprites:\n" .. Utils.tableToString(G.GAME[self.back]))
        -- CardSetSprites(self, _center, _front)
        if self.back == nil or _front or self.children.center then
            CardSetSprites(self, _center, _front)
            return
        end

        if _center and _center.set and (_center.consumeable == nil or _center.consumeable == false) and _center.set ~= 'Joker' and _center.set ~= 'Voucher' and _center.set ~= "Edition" and _center.set ~= "Booster" then
            -- Utils.log("self.back in top if" .. Utils.tableToString(G.GAME.viewed_back))
            -- local file = G.GAME[self.back].effect.config.invert_back and "testCenters" or "centers"
            self.children.center = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS["centers"], _center.pos)
            self.children.center.states.hover = self.states.hover
            self.children.center.states.click = self.states.click
            self.children.center.states.drag = self.states.drag
            self.children.center.states.collide.can = false
            self.children.center:set_role({major = self, role_type = 'Glued', draw_major = self})



            if not self.children.back then
                -- Utils.log("Deck:\n" .. Utils.tableToString(G.GAME.viewed_back))
                local file = G.GAME[self.back].effect.config.invert_back and "testCenters" or "centers"
                self.children.back = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[file], self.params.bypass_back or (self.playing_card and G.GAME[self.back].pos or G.P_CENTERS['b_red'].pos))
                self.children.back.states.hover = self.states.hover
                self.children.back.states.click = self.states.click
                self.children.back.states.drag = self.states.drag
                self.children.back.states.collide.can = false
                self.children.back:set_role({major = self, role_type = 'Glued', draw_major = self})
            end
        else
            CardSetSprites(self, _center, _front)
        end
    end]]

    --[[local RunSetupOption = G.UIDEF.run_setup_option
    function G.UIDEF.run_setup_option(type)
        if not G.SAVED_GAME then
            G.SAVED_GAME = get_compressed(G.SETTINGS.profile..'/'..'save.jkr')
            if G.SAVED_GAME ~= nil then G.SAVED_GAME = STR_UNPACK(G.SAVED_GAME) end
        end

        G.SETTINGS.current_setup = type
        G.GAME.viewed_back = Back(get_deck_from_name(G.PROFILES[G.SETTINGS.profile].MEMORY.deck))

        G.PROFILES[G.SETTINGS.profile].MEMORY.stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1

        if type == 'Continue' then

            G.viewed_stake = 1
            if G.SAVED_GAME ~= nil then
                saved_game = G.SAVED_GAME
                local viewed_deck = 'b_red'
                for k, v in pairs(G.P_CENTERS) do
                    if v.name == saved_game.BACK.name then viewed_deck = k end
                end
                G.GAME.viewed_back:change_to(G.P_CENTERS[viewed_deck])
                G.viewed_stake = saved_game.GAME.stake or 1
            end
        end

        if type == 'New Run' then
            if G.OVERLAY_MENU then
                local seed_toggle = G.OVERLAY_MENU:get_UIE_by_ID('run_setup_seed')
                if seed_toggle then seed_toggle.states.visible = true end
            end
            G.viewed_stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1
            G.FUNCS.change_stake({to_key = G.viewed_stake})
        else
            G.run_setup_seed = nil
            if G.OVERLAY_MENU then
                local seed_toggle = G.OVERLAY_MENU:get_UIE_by_ID('run_setup_seed')
                if seed_toggle then seed_toggle.states.visible = false end
            end
        end

        local area = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                G.CARD_W,
                G.CARD_H,
                {card_limit = 5, type = 'deck', highlight_limit = 0, deck_height = 0.75, thin_draw = 1})

        for i = 1, 10 do
            local card = Card(G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h, G.CARD_W, G.CARD_H, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base, {playing_card = i, viewed_back = true})
            card.sprite_facing = 'back'
            card.facing = 'back'
            area:emplace(card)
            if i == 10 then G.sticker_card = card; card.sticker = get_deck_win_sticker(G.GAME.viewed_back.effect.center) end
        end

        local ordered_names, viewed_deck = {}, 1
        for k, v in ipairs(G.P_CENTER_POOLS.Back) do
            ordered_names[#ordered_names+1] = v.name
            if v.name == G.GAME.viewed_back.name then
                viewed_deck = k
            end
        end

        local lwidth, rwidth = 1.4, 1.8

        local type_colour = G.C.BLUE

        local scale = 0.39
        G.setup_seed = ''

        local t = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR, minh = 6.6, minw = 6}, nodes={
            type == 'Continue' and {n=G.UIT.R, config={align = "tm", minh = 3.8, padding = 0.15}, nodes={
                {n=G.UIT.R, config={align = "cm", minh = 3.3, minw = 6.8}, nodes={
                    {n=G.UIT.C, config={align = "cm", colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05}, nodes={
                        {n=G.UIT.C, config={align = "cm"}, nodes={
                            {n=G.UIT.R, config={align = "cm", shadow = false}, nodes={
                                {n=G.UIT.O, config={object = area}}
                            }},
                        }},{n=G.UIT.C, config={align = "cm", minw = 4, maxw = 4, minh = 1.7, r = 0.1, colour = G.C.L_BLACK, padding = 0.1}, nodes={
                            {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 4, maxw = 4, minh = 0.6}, nodes={
                                {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_back_name', object = Moveable()}},
                            }},
                            {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE,padding = 0.03, minh = 1.75, r = 0.1}, nodes={
                                {n=G.UIT.R, config={align = "cm"}, nodes={
                                    {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_round'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = tostring(saved_game.GAME.round),colour = G.C.RED, scale = 0.8*scale}}}}
                                }},
                                {n=G.UIT.R, config={align = "cm"}, nodes={
                                    {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_ante'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = tostring(saved_game.GAME.round_resets.ante),colour = G.C.BLUE, scale = 0.8*scale}}}}
                                }},
                                {n=G.UIT.R, config={align = "cm"}, nodes={
                                    {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_money'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('$')..tostring(saved_game.GAME.dollars),colour = G.C.ORANGE, scale = 0.8*scale}}}}
                                }},
                                {n=G.UIT.R, config={align = "cm"}, nodes={
                                    {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_best_hand'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = number_format(saved_game.GAME.round_scores.hand.amt),colour = G.C.RED, scale = scale_number(saved_game.GAME.round_scores.hand.amt, 0.8*scale)}}}}
                                }},
                                saved_game.GAME.seeded and {n=G.UIT.R, config={align = "cm"}, nodes={
                                    {n=G.UIT.C, config={align = "cm", minw = lwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = localize('k_seed'),colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = ': ',colour = G.C.UI.TEXT_DARK, scale = scale*0.8}}}},
                                    {n=G.UIT.C, config={align = "cl", minw = rwidth, maxw = lwidth}, nodes={{n=G.UIT.T, config={text = tostring(saved_game.GAME.pseudorandom.seed),colour = G.C.RED, scale = 0.8*scale}}}}
                                }} or nil,
                            }}
                        }},
                        {n=G.UIT.C, config={align = "cm"}, nodes={
                            {n=G.UIT.O, config={id = G.GAME.viewed_back.name, func = 'RUN_SETUP_check_back_stake_column', object = UIBox{definition = G.UIDEF.deck_stake_column(G.GAME.viewed_back.effect.center.key), config = {offset = {x=0,y=0}}}}}
                        }}
                    }}
                }}}} or
                    {n=G.UIT.R, config={align = "cm", minh = 3.8}, nodes={
                        create_option_cycle({options =  ordered_names, opt_callback = 'change_viewed_back', current_option = viewed_deck, colour = G.C.RED, w = 3.5, mid =
                        {n=G.UIT.R, config={align = "cm", minh = 3.3, minw = 5}, nodes={
                            {n=G.UIT.C, config={align = "cm", colour = G.C.BLACK, padding = 0.15, r = 0.1, emboss = 0.05}, nodes={
                                {n=G.UIT.C, config={align = "cm"}, nodes={
                                    {n=G.UIT.R, config={align = "cm", shadow = false}, nodes={
                                        {n=G.UIT.O, config={object = area}}
                                    }},
                                }},{n=G.UIT.C, config={align = "cm", minh = 1.7, r = 0.1, colour = G.C.L_BLACK, padding = 0.1}, nodes={
                                    {n=G.UIT.R, config={align = "cm", r = 0.1, minw = 4, maxw = 4, minh = 0.6}, nodes={
                                        {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_back_name', object = Moveable()}},
                                    }},
                                    {n=G.UIT.R, config={align = "cm", colour = G.C.WHITE, minh = 1.7, r = 0.1}, nodes={
                                        {n=G.UIT.O, config={id = G.GAME.viewed_back.name, func = 'RUN_SETUP_check_back', object = UIBox{definition = G.GAME.viewed_back:generate_UI(), config = {offset = {x=0,y=0}}}}}
                                    }}
                                }},
                                {n=G.UIT.C, config={align = "cm"}, nodes={
                                    {n=G.UIT.O, config={id = G.GAME.viewed_back.name, func = 'RUN_SETUP_check_back_stake_column', object = UIBox{definition = G.UIDEF.deck_stake_column(G.GAME.viewed_back.effect.center.key), config = {offset = {x=0,y=0}}}}}
                                }}
                            }}
                        }}
                        })
                    }},
            {n=G.UIT.R, config={align = "cm"}, nodes={
                type == 'Continue' and {n=G.UIT.R, config={align = "cm", minh = 2.2, minw = 5}, nodes={
                    {n=G.UIT.R, config={align = "cm", minh = 0.17}, nodes={}},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_stake', insta_func = true, object = Moveable()}},
                    }}
                }}
                        or {n=G.UIT.R, config={align = "cm", minh = 2.2, minw = 6.8}, nodes={
                    {n=G.UIT.O, config={id = nil, func = 'RUN_SETUP_check_stake', insta_func = true, object = Moveable()}},
                }},
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.05, minh = 0.9}, nodes={
                {n=G.UIT.O, config={align = "cm", func = 'toggle_seeded_run', object = Moveable()}, nodes={
                }},
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                {n=G.UIT.C, config={align = "cm", minw = 2.4, id = 'run_setup_seed'}, nodes={
                    type == 'New Run' and create_toggle{col = true, label = localize('k_seeded_run'), label_scale = 0.25, w = 0, scale = 0.7, ref_table = G, ref_value = 'run_setup_seed'} or nil
                }},
                {n=G.UIT.C, config={align = "cm", minw = 5, minh = 0.8, padding = 0.2, r = 0.1, hover = true, colour = G.C.BLUE, button = "start_setup_run", shadow = true, func = 'can_start_run'}, nodes={
                    {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                        {n=G.UIT.T, config={text = localize('b_play_cap'), scale = 0.8, colour = G.C.UI.TEXT_LIGHT,func = 'set_button_pip', focus_args = {button = 'x',set_button_pip = true}}}
                    }}
                }},
                {n=G.UIT.C, config={align = "cm", minw = 2.5}, nodes={}}
            }}
        }}
        return t
    end]]
end

function DeckCreator.Disable()
    G.P_CENTERS = Persistence.UnloadedCenters
    G.P_CENTER_POOLS.Back = Persistence.UnloadedDeckList
    DeckCreator.Unloaded = true
end

return DeckCreator
