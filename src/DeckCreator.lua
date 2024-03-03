local Persistence = require "Persistence"
local GUI = require "GUI"
local Helper = require "GuiElementHelper"
local Utils = require "Utils"
local CardUtils = require "CardUtils"

local DeckCreator = {}

function DeckCreator.Initialize()

    if SMODS ~= nil then
        SMODS.Sprite:new("itemIcons", SMODS.findModByID("DeckCreatorModule").path, "ItemIcons.png", 18, 18, "asset_atli"):register()
    end

    GUI.registerGlobals()
    GUI.registerModMenuUI()
    Helper.registerGlobals()
    Persistence.loadAllDeckLists()

    G.FUNCS.LogDebug = function(message)
        Utils.log(message)
    end

    G.FUNCS.LogTableToString = function(table)
        Utils.log(Utils.tableToString(table))
    end

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
                Utils.log("Clicked voucher: " .. self.config.center.key)
                if GUI.openItemType == 'voucher' then
                    local added = CardUtils.addItemToDeck({ voucher = true, ref = 'customVoucherList', addCard = self.config.center.key, deck_list = Utils.customDeckList})
                    if added then
                        self:start_materialize(nil, true)
                    end
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
                end
            end


        end

        CardClick(self)
    end

    local BackApply_to_runRef = Back.apply_to_run
    function Back.apply_to_run(arg)
        if arg.effect.config.customDeck and arg.effect.config.copy_deck_config ~= nil and arg.effect.config.copy_deck_config ~= "None" then
            local copyConfig
            for k,v in pairs(G.P_CENTER_POOLS.Back) do
                if v.name == arg.effect.config.copy_deck_config then
                    copyConfig = v.config
                    break
                end
            end

            if copyConfig then
                for k,v in pairs(copyConfig) do
                    arg.effect.config[k] = v
                end
            end
        end

        if arg.effect.config.customDeck then
            arg.effect.config.vouchers = arg.effect.config.vouchers or {}
            for k,v in pairs(arg.effect.config.customVoucherList) do
                table.insert(arg.effect.config.vouchers, v)
            end

            if #arg.effect.config.vouchers == 0 then arg.effect.config.vouchers = nil end
        end

        BackApply_to_runRef(arg)

        if arg.effect.config.customDeck then

            Utils.log("Custom deck config at run start:\n" .. Utils.tableToString(arg.effect.config.customDeck))

            if arg.effect.config.joker_rate == 0 and arg.effect.config.tarot_rate == 0 and arg.effect.config.planet_rate == 0 and arg.effect.config.spectral_rate == 0 and arg.effect.config.playing_card_rate == 0 then
                local rateNames = {"joker_rate", "tarot_rate", "planet_rate", "spectral_rate"}
                local randomIndex = math.random(1, #rateNames)
                local selectedRateName = rateNames[randomIndex]
                arg.effect.config[selectedRateName] = 100
            end

            G.GAME.shop.joker_max = arg.effect.config.shop_slots
            G.GAME.modifiers.inflation = arg.effect.config.inflation
            G.GAME.joker_rate = arg.effect.config.joker_rate
            G.GAME.tarot_rate = arg.effect.config.tarot_rate
            G.GAME.planet_rate = arg.effect.config.planet_rate
            G.GAME.playing_card_rate = arg.effect.config.playing_card_rate
            G.GAME.interest_cap = arg.effect.config.interest_cap
            G.GAME.discount_percent = arg.effect.config.discount_percent
            G.GAME.modifiers.chips_dollar_cap = arg.effect.config.chips_dollar_cap
            G.GAME.modifiers.discard_cost = arg.effect.config.discard_cost
            G.GAME.modifiers.all_eternal = arg.effect.config.all_eternal
            G.GAME.modifiers.debuff_played_cards = arg.effect.config.debuff_played_cards

            if arg.effect.config.flipped_cards then
                G.GAME.modifiers.flipped_cards = 4
            else
                G.GAME.modifiers.flipped_cards = nil
            end

            if arg.effect.config.minus_hand_size_per_X_dollar then
                G.GAME.modifiers.minus_hand_size_per_X_dollar = 5
            else
                G.GAME.modifiers.minus_hand_size_per_X_dollar = nil
            end

            if G.GAME.stake >= 4 or (G.GAME.stake < 4 and arg.effect.config.enable_eternals_in_shop) then
                G.GAME.modifiers.enable_eternals_in_shop = true
            else
                G.GAME.modifiers.enable_eternals_in_shop = false
            end

            if G.GAME.stake >= 7 or (G.GAME.stake < 7 and arg.effect.config.booster_ante_scaling) then
                G.GAME.modifiers.booster_ante_scaling = true
            else
                G.GAME.modifiers.booster_ante_scaling = false
            end

            if arg.effect.config.reroll_cost then
                G.GAME.starting_params.reroll_cost = arg.effect.config.reroll_cost
                G.GAME.base_reroll_cost = arg.effect.config.reroll_cost
            end

            if arg.effect.config.win_ante ~= nil and arg.effect.config.win_ante > 0 then
                G.GAME.win_ante = arg.effect.config.win_ante
            end

            if arg.effect.config.extra_hand_bonus == 0 then
                G.GAME.modifiers.no_extra_hand_money = true
            end

            Utils.fullDeckConversionFunctions(arg)
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

    local GameStartRun = Game.start_run
    function Game:start_run(args)
        local originalResult = GameStartRun(self, args)

        local deck = self.GAME.selected_back

        G.FUNCS.LogTableToString(deck.effect.config)

        if deck.effect.config.customDeck then



            if deck.effect.config.custom_cards_set then
                CardUtils.initializeCustomCardList(deck.effect.config.customCardList)
            end

            --[[if deck.effect.config.custom_vouchers_set then
                G.GAME.starting_voucher_count = #deck.effect.config.customVoucherList
                for k,v in pairs(deck.effect.config.customVoucherList) do
                    Card.apply_to_run(nil, G.P_CENTERS[v])
                end
            end]]
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

return DeckCreator
