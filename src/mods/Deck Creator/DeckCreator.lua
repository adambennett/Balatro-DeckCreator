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
    Utils.redSealMessages = Persistence.loadRedSealMessages()
    GUI.registerGlobals()
    Helper.registerGlobals()
    Persistence.loadAllDeckLists()
    GUI.registerModMenuUI()
    GUI.initializeStaticMods()
    Utils.boosterKeys()
    -- This is missing from the 0.9.8 compatibility layer. Gotta fix it someday
    SMODS.Card.RANK_SHORTHAND_LOOKUP = {
        ['J'] = 'Jack',
        ['Q'] = 'Queen',
        ['K'] = 'King',
        ['A'] = 'Ace',
    }


    --[[local Shop = G.UIDEF.shop
    function G.UIDEF.shop()
        local shopChangesNeeded = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.shop.joker_max > 4 or G.GAME.selected_back.effect.config.booster_pack_slots ~= 2 or G.GAME.selected_back.effect.config.voucher_slots ~= 1) or false
        if shopChangesNeeded == false then
            return Shop()
        end

        local areaSize = G.GAME.shop.joker_max
        if areaSize > 4 then areaSize = 3 end

        G.shop_jokers = CardArea(
                G.hand.T.x+0,
                G.hand.T.y+G.ROOM.T.y + 9,
                areaSize*1.02*G.CARD_W,
                1.05*G.CARD_H,
                {card_limit = areaSize, type = 'shop', highlight_limit = 1})

        G.DeckCreatorModuleAllShopJokersArea = CardArea(
                G.hand.T.x+0,
                G.hand.T.y+G.ROOM.T.y + 9,
                G.GAME.shop.joker_max*1.02*G.CARD_W,
                1.05*G.CARD_H,
                {card_limit = G.GAME.shop.joker_max, type = 'shop', highlight_limit = 1})


        G.shop_vouchers = CardArea(
                G.hand.T.x+0,
                G.hand.T.y+G.ROOM.T.y + 9,
                2.1*G.CARD_W,
                1.05*G.CARD_H,
                {card_limit = 1, type = 'shop', highlight_limit = 1})

        G.shop_booster = CardArea(
                G.hand.T.x+0,
                G.hand.T.y+G.ROOM.T.y + 9,
                2.4*G.CARD_W,
                1.15*G.CARD_H,
                {card_limit = 2, type = 'shop', highlight_limit = 1, card_w = 1.27*G.CARD_W})

        local shop_sign = AnimatedSprite(0,0, 4.4, 2.2, G.ANIMATION_ATLAS['shop_sign'])
        shop_sign:define_draw_steps({
            {shader = 'dissolve', shadow_height = 0.05},
            {shader = 'dissolve'}
        })
        G.SHOP_SIGN = UIBox{
            definition =
            {n=G.UIT.ROOT, config = {colour = G.C.DYN_UI.MAIN, emboss = 0.05, align = 'cm', r = 0.1, padding = 0.1}, nodes={
                {n=G.UIT.R, config={align = "cm", padding = 0.1, minw = 4.72, minh = 3.1, colour = G.C.DYN_UI.DARK, r = 0.1}, nodes={
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.O, config={object = shop_sign}}
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.O, config={object = DynaText({string = {localize('ph_improve_run')}, colours = {lighten(G.C.GOLD, 0.3)},shadow = true, rotate = true, float = true, bump = true, scale = 0.5, spacing = 1, pop_in = 1.5, maxw = 4.3})}}
                    }},
                }},
            }},
            config = {
                align="cm",
                offset = {x=0,y=-15},
                major = G.HUD:get_UIE_by_ID('row_blind'),
                bond = 'Weak'
            }
        }
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function()
                G.SHOP_SIGN.alignment.offset.y = 0
                return true
            end)
        }))

        local jokerRow
        if G.GAME.shop.joker_max > 4 then
            jokerRow = {
                {
                    n = G.UIT.C,
                    config = {
                        align = "cm",
                        r = 0.1,
                        minw = 0.4,
                        colour = G.C.BLACK,
                        button = 'DeckCreatorModuleChangeShopJokersPageLeft',
                        focus_args = {type = 'none'}
                    },
                    nodes = {
                        { n=G.UIT.T, config = { text = '<', scale = 0.3, colour = G.C.UI.TEXT_LIGHT } }
                    }
                },
                {
                    n=G.UIT.C,
                    config={align = "cm", padding = 0.1},
                    nodes={
                        {n=G.UIT.O, config={object = G.shop_jokers}}
                    }
                },
                {
                    n = G.UIT.C,
                    config = {
                        align = "cm",
                        r = 0.1,
                        minw = 0.4,
                        colour = G.C.BLACK,
                        button = 'DeckCreatorModuleChangeShopJokersPageRight',
                        focus_args = {type = 'none'}
                    },
                    nodes = {
                        { n=G.UIT.T, config = { text = '>', scale = 0.3, colour = G.C.UI.TEXT_LIGHT } }
                    }
                }
            }
        else
            jokerRow = {
                {n=G.UIT.O, config={object = G.shop_jokers}}
            }
        end

        local t = {n=G.UIT.ROOT, config = {align = 'cl', colour = G.C.CLEAR}, nodes={
            UIBox_dyn_container({
                {n=G.UIT.C, config={align = "cm", padding = 0.1, emboss = 0.05, r = 0.1, colour = G.C.DYN_UI.BOSS_MAIN}, nodes={
                    {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
                        {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                            {n=G.UIT.R,config={id = 'next_round_button', align = "cm", minw = 2.8, minh = 1.5, r=0.15,colour = G.C.RED, one_press = true, button = 'toggle_shop', hover = true,shadow = true}, nodes = {
                                {n=G.UIT.R, config={align = "cm", padding = 0.07, focus_args = {button = 'y', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
                                    {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                                        {n=G.UIT.T, config={text = localize('b_next_round_1'), scale = 0.4, colour = G.C.WHITE, shadow = true}}
                                    }},
                                    {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                                        {n=G.UIT.T, config={text = localize('b_next_round_2'), scale = 0.4, colour = G.C.WHITE, shadow = true}}
                                    }}
                                }},
                            }},
                            {n=G.UIT.R, config={align = "cm", minw = 2.8, minh = 1.6, r=0.15,colour = G.C.GREEN, button = 'reroll_shop', func = 'can_reroll', hover = true,shadow = true}, nodes = {
                                {n=G.UIT.R, config={align = "cm", padding = 0.07, focus_args = {button = 'x', orientation = 'cr'}, func = 'set_button_pip'}, nodes={
                                    {n=G.UIT.R, config={align = "cm", maxw = 1.3}, nodes={
                                        {n=G.UIT.T, config={text = localize('k_reroll'), scale = 0.4, colour = G.C.WHITE, shadow = true}},
                                    }},
                                    {n=G.UIT.R, config={align = "cm", maxw = 1.3, minw = 1}, nodes={
                                        {n=G.UIT.T, config={text = localize('$'), scale = 0.7, colour = G.C.WHITE, shadow = true}},
                                        {n=G.UIT.T, config={ref_table = G.GAME.current_round, ref_value = 'reroll_cost', scale = 0.75, colour = G.C.WHITE, shadow = true}},
                                    }}
                                }}
                            }},
                        }},
                        {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.L_BLACK, emboss = 0.05, minw = 8.2}, nodes={
                            {n=G.UIT.R, config={align = "cm"}, nodes=jokerRow},
                        }},
                    }},
                    {n=G.UIT.R, config={align = "cm", minh = 0.2}, nodes={}},
                    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
                        {n=G.UIT.C, config={align = "cm", padding = 0.15, r=0.2, colour = G.C.L_BLACK, emboss = 0.05}, nodes={
                            {n=G.UIT.C, config={align = "cm", padding = 0.2, r=0.2, colour = G.C.BLACK, maxh = G.shop_vouchers.T.h+0.4}, nodes={
                                {n=G.UIT.T, config={text = localize{type = 'variable', key = 'ante_x_voucher', vars = {G.GAME.round_resets.ante}}, scale = 0.45, colour = G.C.L_BLACK, vert = true}},
                                {n=G.UIT.O, config={object = G.shop_vouchers}},
                            }},
                        }},
                        {n=G.UIT.C, config={align = "cm", padding = 0.15, r=0.2, colour = G.C.L_BLACK, emboss = 0.05}, nodes={
                            {n=G.UIT.O, config={object = G.shop_booster}},
                        }},
                    }}
                }
                },

            }, false)
        }}
        return t
    end]]

    local UseConsumeable = Card.use_consumeable
    function Card:use_consumeable(area, copier)
        local consumableChangesNeeded = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.death_targets_random_card or G.GAME.selected_back.effect.config.spectral_cards_cannot_destroy_jokers or G.GAME.selected_back.effect.config.ectoplasm_cannot_change_hand_size or G.GAME.selected_back.effect.config.ouija_cannot_change_hand_size or G.GAME.selected_back.effect.config.spectral_seals_add_additional or G.GAME.selected_back.effect.config.no_spectral_destroy_cards or G.GAME.selected_back.effect.config.wraith_cannot_set_money_to_zero) or false

        if consumableChangesNeeded == false then
            UseConsumeable(self, area, copier)
            return
        end

        local deathChanges = (self.ability.consumeable.mod_conv or self.ability.consumeable.suit_conv) and self.ability.name == 'Death' and G.GAME.selected_back.effect.config.death_targets_random_card
        local noSpectralJokerKill = G.GAME.selected_back.effect.config.spectral_cards_cannot_destroy_jokers and (self.ability.name == 'Ankh' or self.ability.name == 'Hex')
        local noEctoplasmHandChange = G.GAME.selected_back.effect.config.ectoplasm_cannot_change_hand_size and self.ability.name == 'Ectoplasm'
        local noOuijaHandChange = G.GAME.selected_back.effect.config.ouija_cannot_change_hand_size and self.ability.name == 'Ouija'
        local noWraithDeleteMoney = G.GAME.selected_back.effect.config.wraith_cannot_set_money_to_zero and self.ability.name == 'Wraith'
        local noSpectralDestroyCards = G.GAME.selected_back.effect.config.no_spectral_destroy_cards and (self.ability.name == 'Familiar' or self.ability.name == 'Grim' or self.ability.name == 'Incantation' or self.ability.name == 'Immolate')
        local spectralSealsAddAdditional = G.GAME.selected_back.effect.config.spectral_seals_add_additional and (self.ability.name == 'Talisman' or self.ability.name == 'Deja Vu' or self.ability.name == 'Trance' or self.ability.name == 'Medium')
        local anyOverrides = deathChanges or noSpectralJokerKill or noEctoplasmHandChange or noOuijaHandChange or noWraithDeleteMoney or noSpectralDestroyCards or spectralSealsAddAdditional
        local used_tarot
        if anyOverrides then
            stop_use()
            if not copier then set_consumeable_usage(self) end
            if self.debuff then return nil end
            used_tarot = copier or self

            if self.ability.consumeable.max_highlighted then
                update_hand_text({immediate = true, nopulse = true, delay = 0}, {mult = 0, chips = 0, level = '', handname = ''})
            end
        end

        if noSpectralDestroyCards then
            if self.ability.name == 'Familiar' or self.ability.name == 'Grim' or self.ability.name == 'Incantation' then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound('tarot1')
                    used_tarot:juice_up(0.3, 0.5)
                    return true end }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.7,
                    func = function()
                        local cards = {}
                        for i=1, self.ability.extra do
                            cards[i] = true
                            local _suit, _rank = nil, nil
                            if self.ability.name == 'Familiar' then
                                _rank = pseudorandom_element({'J', 'Q', 'K'}, pseudoseed('familiar_create'))
                                _suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('familiar_create'))
                            elseif self.ability.name == 'Grim' then
                                _rank = 'A'
                                _suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('grim_create'))
                            elseif self.ability.name == 'Incantation' then
                                _rank = pseudorandom_element({'2', '3', '4', '5', '6', '7', '8', '9', 'T'}, pseudoseed('incantation_create'))
                                _suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('incantation_create'))
                            end
                            _suit = _suit or 'S'; _rank = _rank or 'A'
                            local cen_pool = {}
                            for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                                if v.key ~= 'm_stone' then
                                    cen_pool[#cen_pool+1] = v
                                end
                            end
                            create_playing_card({front = G.P_CARDS[_suit..'_'.._rank], center = pseudorandom_element(cen_pool, pseudoseed('spe_card'))}, G.hand, nil, i ~= 1, {G.C.SECONDARY_SET.Spectral})
                        end
                        playing_card_joker_effects(cards)
                        return true end }))
            elseif self.ability.name == 'Immolate' then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound('tarot1')
                    used_tarot:juice_up(0.3, 0.5)
                    return true end }))
                ease_dollars(self.ability.extra.dollars)
            end
        elseif noWraithDeleteMoney then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('timpani')
                local card = create_card('Joker', G.jokers, nil, 0.99, nil, nil, nil, 'wra')
                card:add_to_deck()
                G.jokers:emplace(card)
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            delay(0.6)
        elseif spectralSealsAddAdditional then
            local conv_card = G.hand.highlighted[1]
            G.E_MANAGER:add_event(Event({func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))

            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                conv_card:set_seal(self.ability.extra, nil, true)
                return true end }))

            delay(0.5)
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))

            local eligibleCards = {}
            for i = 1, #G.hand.cards do
                if G.hand.cards[i] ~= conv_card and G.hand.cards[i].seal == nil then
                    table.insert(eligibleCards, G.hand.cards[i])
                end
            end

            local randomCard
            if #eligibleCards > 0 then
                local randomIndex = math.random(#eligibleCards)
                randomCard = eligibleCards[randomIndex]
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()
                    randomCard:set_seal(self.ability.extra, nil, true)
                    return true end }))
            end
        elseif deathChanges then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.highlighted do
                local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)

            local leftmost = G.hand.highlighted[1]
            local rightmost = G.hand.highlighted[1]
            for i = 1, #G.hand.highlighted do
                if G.hand.highlighted[i].T.x < leftmost.T.x then
                    leftmost = G.hand.highlighted[i]
                elseif G.hand.highlighted[i].T.x > rightmost.T.x then
                    rightmost = G.hand.highlighted[i]
                end
            end

            local eligibleCards = {}
            for i = 1, #G.hand.cards do
                if G.hand.cards[i] ~= leftmost and G.hand.cards[i] ~= rightmost then
                    table.insert(eligibleCards, G.hand.cards[i])
                end
            end

            local randomCard
            if #eligibleCards > 0 then
                local randomIndex = math.random(#eligibleCards)
                randomCard = eligibleCards[randomIndex]
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
                    copy_card(rightmost, randomCard)
                    return true
                end}))
            end

            local percent = 0.85 + (1-0.999)/(#G.hand.highlighted-0.998)*0.3
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
                rightmost:flip()
                play_sound('tarot2', percent, 0.6)
                rightmost:juice_up(0.3, 0.3)
                return true end
            }))
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
                randomCard:flip()
                randomCard:flip()
                play_sound('tarot2', percent, 0.6)
                randomCard:juice_up(0.3, 0.3)
                return true end
            }))
            G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function()
                leftmost:flip()
                return true end
            }))

            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2,func = function() G.hand:unhighlight_all(); return true end }))
            delay(0.5)
        elseif noEctoplasmHandChange then
            local temp_pool = (self.ability.name == 'The Wheel of Fortune' and self.eligible_strength_jokers) or
                    ((self.ability.name == 'Ectoplasm' or self.ability.name == 'Hex') and self.eligible_editionless_jokers) or {}
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                local eligible_card = pseudorandom_element(temp_pool, pseudoseed(
                        (self.ability.name == 'The Wheel of Fortune' and 'wheel_of_fortune') or
                                (self.ability.name == 'Ectoplasm' and 'ectoplasm') or
                                (self.ability.name == 'Hex' and 'hex')
                ))
                local edition = {negative = true}
                eligible_card:set_edition(edition, true)
                check_for_unlock({type = 'have_edition'})
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
        elseif noOuijaHandChange then
            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                play_sound('tarot1')
                used_tarot:juice_up(0.3, 0.5)
                return true end }))
            for i=1, #G.hand.cards do
                local percent = 1.15 - (i-0.999)/(#G.hand.cards-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.cards[i]:flip();play_sound('card1', percent);G.hand.cards[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.2)
            local _rank = pseudorandom_element({'2','3','4','5','6','7','8','9','T','J','Q','K','A'}, pseudoseed('ouija'))
            for i=1, #G.hand.cards do
                G.E_MANAGER:add_event(Event({func = function()
                    local card = G.hand.cards[i]
                    local suit_prefix = string.sub(card.base.suit, 1, 1)..'_'
                    local rank_suffix =_rank
                    card:set_base(G.P_CARDS[suit_prefix..rank_suffix])
                    return true end }))
            end
            for i=1, #G.hand.cards do
                local percent = 0.85 + (i-0.999)/(#G.hand.cards-0.998)*0.3
                G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.cards[i]:flip();play_sound('tarot2', percent, 0.6);G.hand.cards[i]:juice_up(0.3, 0.3);return true end }))
            end
            delay(0.5)
        elseif noSpectralJokerKill then
            if self.ability.name == 'Ankh' then
                if noSpectralJokerKill == false then
                    local deletable_jokers = {}
                    for k, v in pairs(G.jokers.cards) do
                        if not v.ability.eternal then deletable_jokers[#deletable_jokers + 1] = v end
                    end
                    local _first_dissolve
                    G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.75, func = function()
                        for k, v in pairs(deletable_jokers) do
                            if v ~= chosen_joker then
                                v:start_dissolve(nil, _first_dissolve)
                                _first_dissolve = true
                            end
                        end
                        return true end }))
                end

                local chosen_joker = pseudorandom_element(G.jokers.cards, pseudoseed('ankh_choice'))
                G.E_MANAGER:add_event(Event({trigger = 'before', delay = 0.4, func = function()
                    local card = copy_card(chosen_joker, nil, nil, nil, chosen_joker.edition and chosen_joker.edition.negative)
                    card:start_materialize()
                    card:add_to_deck()
                    if card.edition and card.edition.negative then
                        card:set_edition(nil, true)
                    end
                    G.jokers:emplace(card)
                    return true end
                }))
            elseif self.ability.name == 'Hex' then
                local temp_pool =   (self.ability.name == 'The Wheel of Fortune' and self.eligible_strength_jokers) or
                        ((self.ability.name == 'Ectoplasm' or self.ability.name == 'Hex') and self.eligible_editionless_jokers) or {}
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    local eligible_card = pseudorandom_element(temp_pool, pseudoseed('hex'))
                    local edition = {polychrome = true}
                    eligible_card:set_edition(edition, true)
                    check_for_unlock({type = 'have_edition'})
                    used_tarot:juice_up(0.3, 0.5)
                    return true end
                }))
            end
        else
            return UseConsumeable(self, area, copier)
        end
    end

    local function nextVoucherKey(_from_tag)
        local _pool, _pool_key = get_current_pool('Voucher')
        if _from_tag then _pool_key = 'Voucher_fromtag' end
        local center = pseudorandom_element(_pool, pseudoseed(_pool_key))
        local it = 1
        while center == 'UNAVAILABLE' and it < 99 do
            it = it + 1
            center = pseudorandom_element(_pool, pseudoseed(_pool_key..'_resample'..it))
        end

        return center
    end
    local UpdateShop = Game.update_shop
    function Game:update_shop(dt)
        local shopChangesNeeded = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.booster_pack_slots ~= 2 or G.GAME.selected_back.effect.config.voucher_slots ~= 1 or G.GAME.selected_back.effect.config.one_free_card_in_shop or G.GAME.selected_back.effect.config.voucher_is_free or G.GAME.selected_back.effect.config.one_free_booster_in_shop or #G.GAME.selected_back.effect.config.bannedBoosterList >= Utils.runtimeConstants.boosterPacks or G.GAME.selected_back.effect.config.one_free_item_in_shop) or false
        if shopChangesNeeded == false then
            UpdateShop(self, dt)
            return
        end

        local boosterSlots = G.GAME.selected_back.effect.config.booster_pack_slots or 2
        local voucherSlots = G.GAME.selected_back.effect.config.voucher_slots or 1
        local freeItem
        if G.GAME.selected_back.effect.config.one_free_item_in_shop then
            local roll = math.random(1, 3)
            if roll == 1 then freeItem = 'card'
            elseif roll == 2 then freeItem = 'booster'
            else freeItem = 'voucher'
            end
        end

        local voucherIsFree = freeItem ~= nil and freeItem == 'voucher'
        if G.GAME.selected_back.effect.config.voucher_is_free then voucherIsFree = true end

        local oneFreeBooster = freeItem ~= nil and freeItem == 'booster'
        if G.GAME.selected_back.effect.config.one_free_booster_in_shop then oneFreeBooster = true end

        if not G.STATE_COMPLETE then
            stop_use()
            ease_background_colour_blind(G.STATES.SHOP)
            local shop_exists = not not G.shop
            G.shop = G.shop or UIBox{
                definition = G.UIDEF.shop(),
                config = {align='tmi', offset = {x=0,y=G.ROOM.T.y+11},major = G.hand, bond = 'Weak'}
            }
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.shop.alignment.offset.y = -5.3
                    G.shop.alignment.offset.x = 0
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        blockable = false,
                        func = function()
                            if math.abs(G.shop.T.y - G.shop.VT.y) < 3 then
                                G.ROOM.jiggle = G.ROOM.jiggle + 3
                                play_sound('cardFan2')
                                for i = 1, #G.GAME.tags do
                                    G.GAME.tags[i]:apply_to_run({type = 'shop_start'})
                                end
                                local nosave_shop = nil
                                if not shop_exists then

                                    if G.load_shop_jokers then
                                        nosave_shop = true
                                        G.shop_jokers:load(G.load_shop_jokers)
                                        for k, v in ipairs(G.shop_jokers.cards) do
                                            create_shop_card_ui(v)
                                            if v.ability.consumeable then v:start_materialize() end
                                            for _kk, vvv in ipairs(G.GAME.tags) do
                                                if vvv:apply_to_run({type = 'store_joker_modify', card = v}) then break end
                                            end
                                        end
                                        G.load_shop_jokers = nil
                                    else
                                        --CardUtils.setupBigJokerShop(false)
                                        for i = 1, G.GAME.shop.joker_max - #G.shop_jokers.cards do
                                            G.shop_jokers:emplace(create_card_for_shop(G.shop_jokers))
                                        end
                                    end

                                    if G.GAME.selected_back.effect.config.one_free_card_in_shop and #G.shop_jokers.cards > 0 then
                                        local rollIndex = math.random(1, #G.shop_jokers.cards)
                                        local chosen = G.shop_jokers.cards[rollIndex]
                                        if chosen ~= nil then
                                            chosen.ability.couponed = true
                                            chosen:set_cost()
                                        end
                                    end

                                    if freeItem ~= nil and freeItem == 'card' then
                                        local nonFree = {}
                                        for k,v in pairs(G.shop_jokers.cards) do
                                            if not v.ability.couponed then
                                                table.insert(nonFree, v)
                                            end
                                        end

                                        if #nonFree > 0 then
                                            local rollIndex = math.random(1, #nonFree)
                                            local chosen = nonFree[rollIndex]
                                            if chosen ~= nil then
                                                chosen.ability.couponed = true
                                                chosen:set_cost()
                                            end
                                        end
                                    end

                                    if G.load_shop_vouchers then
                                        nosave_shop = true
                                        G.shop_vouchers:load(G.load_shop_vouchers)
                                        for k, v in ipairs(G.shop_vouchers.cards) do
                                            create_shop_card_ui(v)
                                            v:start_materialize()
                                        end
                                        G.load_shop_vouchers = nil
                                    else
                                        if voucherSlots > 0 and G.GAME.current_round.voucher and G.P_CENTERS[G.GAME.current_round.voucher] then
                                            local card = Card(G.shop_vouchers.T.x + G.shop_vouchers.T.w/2,
                                                    G.shop_vouchers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.voucher],{bypass_discovery_center = true, bypass_discovery_ui = true})
                                            card.shop_voucher = true
                                            create_shop_card_ui(card, 'Voucher', G.shop_vouchers)
                                            card:start_materialize()
                                            if voucherIsFree then
                                                card.ability.couponed = true
                                                card:set_cost()
                                                card.cost = 0
                                            end
                                            G.shop_vouchers:emplace(card)
                                        end
                                    end


                                    if G.load_shop_booster then
                                        nosave_shop = true
                                        G.shop_booster:load(G.load_shop_booster)
                                        for k, v in ipairs(G.shop_booster.cards) do
                                            create_shop_card_ui(v)
                                            v:start_materialize()
                                        end
                                        G.load_shop_booster = nil
                                    else
                                        if boosterSlots > 0 then
                                            for i = 1, boosterSlots do
                                                G.GAME.current_round.used_packs = G.GAME.current_round.used_packs or {}
                                                if not G.GAME.current_round.used_packs[i] then
                                                    local pack = get_pack('shop_pack')
                                                    if pack == nil then
                                                        break
                                                    end
                                                    G.GAME.current_round.used_packs[i] = pack.key
                                                end

                                                if G.GAME.current_round.used_packs[i] ~= 'USED' then
                                                    local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                                                            G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
                                                    create_shop_card_ui(card, 'Booster', G.shop_booster)
                                                    card.ability.booster_pos = i
                                                    card:start_materialize()
                                                    if oneFreeBooster and i == 1 then
                                                        card.ability.couponed = true
                                                        card:set_cost()
                                                        card.cost = 0
                                                    end
                                                    G.shop_booster:emplace(card)
                                                end
                                            end
                                        end

                                        for i = 1, #G.GAME.tags do
                                            G.GAME.tags[i]:apply_to_run({type = 'voucher_add'})
                                        end
                                        for i = 1, #G.GAME.tags do
                                            G.GAME.tags[i]:apply_to_run({type = 'shop_final_pass'})
                                        end
                                    end

                                    if voucherSlots > 1 then
                                        for i = 1, (voucherSlots - 1) do
                                            G.ARGS.voucher_tag = G.ARGS.voucher_tag or {}
                                            local voucher_key = nextVoucherKey(true)
                                            G.ARGS.voucher_tag[voucher_key] = true
                                            G.shop_vouchers.config.card_limit = G.shop_vouchers.config.card_limit + 1
                                            local card = Card(G.shop_vouchers.T.x + G.shop_vouchers.T.w/2, G.shop_vouchers.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS[voucher_key],{bypass_discovery_center = true, bypass_discovery_ui = true})
                                            create_shop_card_ui(card, 'Voucher', G.shop_vouchers)
                                            card:start_materialize()
                                            G.shop_vouchers:emplace(card)
                                            G.ARGS.voucher_tag = nil
                                        end
                                    end
                                end

                                G.CONTROLLER:snap_to({node = G.shop:get_UIE_by_ID('next_round_button')})
                                if not nosave_shop then G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end})) end
                                return true
                            end
                        end}))
                    return true
                end
            }))
            G.STATE_COMPLETE = true
        end
        if self.buttons then self.buttons:remove(); self.buttons = nil end
    end

    local LevelUpHand = level_up_hand
    function level_up_hand(card, hand, instant, amount)
        local extraLevels = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and G.GAME.selected_back.effect.config.extra_hand_level_upgrades or 0
        amount = amount or 1
        if amount >= 0 and extraLevels > 0 then
            local totalLevels = amount + extraLevels
            if totalLevels > 5 then
                local iterations = math.min(3, totalLevels)
                local baseLevelsPerIteration = math.floor(totalLevels / iterations)
                local extraLevelsToDistribute = totalLevels % iterations
                for i = 1, iterations do
                    local currentIterationLevels = baseLevelsPerIteration
                    if i <= extraLevelsToDistribute then
                        currentIterationLevels = currentIterationLevels + 1
                    end
                    LevelUpHand(card, hand, instant, currentIterationLevels)
                end
            else
                for i = 1, totalLevels do
                    LevelUpHand(card, hand, instant, 1)
                end
            end
        else
            LevelUpHand(card, hand, instant, amount)
        end
    end

    local function getRerollPack(_key, _type)
        local cume, it, center = 0, 0, nil
        for k, v in ipairs(G.P_CENTER_POOLS['Booster']) do
            if (not _type or _type == v.kind) and not G.GAME.banned_keys[v.key] then cume = cume + (v.weight or 1 ) end
        end
        local seedString = (_key or 'pack_generic') .. G.GAME.round_resets.ante .. Utils.uuid()
        local poll = pseudorandom(pseudoseed(seedString)) * cume
        for k, v in ipairs(G.P_CENTER_POOLS['Booster']) do
            if not G.GAME.banned_keys[v.key] then
                if not _type or _type == v.kind then it = it + (v.weight or 1) end
                if it >= poll and it - (v.weight or 1) <= poll then center = v; break end
            end
        end
        return center
    end

    local RerollShop = G.FUNCS.reroll_shop
    G.FUNCS.reroll_shop = function(e)

        local isRerollOverrideNeeded = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.reroll_boosters or G.GAME.shop.joker_max > 4) or false
        if isRerollOverrideNeeded == false then
            return RerollShop(e)
        end

        stop_use()
        G.CONTROLLER.locks.shop_reroll = true
        if G.CONTROLLER:save_cardarea_focus('shop_jokers') then G.CONTROLLER.interrupt.focus = true end
        if G.GAME.current_round.reroll_cost > 0 then
            inc_career_stat('c_shop_dollars_spent', G.GAME.current_round.reroll_cost)
            inc_career_stat('c_shop_rerolls', 1)
            ease_dollars(-G.GAME.current_round.reroll_cost)
        end
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                local final_free = G.GAME.current_round.free_rerolls > 0
                G.GAME.current_round.free_rerolls = math.max(G.GAME.current_round.free_rerolls - 1, 0)
                G.GAME.round_scores.times_rerolled.amt = G.GAME.round_scores.times_rerolled.amt + 1

                calculate_reroll_cost(final_free)
                CardUtils.removeAllJokersFromShop()

                --[[if Utils.shopJokers ~= nil and Utils.shopJokers[Utils.currentShopJokerPage] ~= nil then
                    for i = #Utils.shopJokers[Utils.currentShopJokerPage], 1, -1 do
                        local c = Utils.shopJokers[Utils.currentShopJokerPage][i]
                        c:remove()
                        c = nil
                    end
                end]]

                if G.GAME.selected_back.effect.config.reroll_boosters then
                    for i = #G.shop_booster.cards,1,-1 do
                        local c = G.shop_booster:remove_card(G.shop_booster.cards[i])
                        c:remove()
                        c = nil
                    end
                end


                --save_run()

                play_sound('coin2')
                play_sound('other1')

                --[[if G.GAME.shop.joker_max > 4 then
                    Utils.resetShopJokerPages()
                    CardUtils.setupBigJokerShop(true)]]
                --else
                for i = 1, G.GAME.shop.joker_max - #G.shop_jokers.cards do
                    local new_shop_card = create_card_for_shop(G.shop_jokers)
                    G.shop_jokers:emplace(new_shop_card)
                    new_shop_card:juice_up()
                end
                --end

                if G.GAME.selected_back.effect.config.reroll_boosters then
                    local packs = G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.booster_pack_slots or 2
                    for i = 1, packs do
                        G.GAME.current_round.used_packs = {}
                        if not G.GAME.current_round.used_packs[i] then
                            G.GAME.current_round.used_packs[i] = getRerollPack('shop_pack').key
                        end

                        if G.GAME.current_round.used_packs[i] ~= 'USED' then
                            local card = Card(G.shop_booster.T.x + G.shop_booster.T.w/2,
                                    G.shop_booster.T.y, G.CARD_W*1.27, G.CARD_H*1.27, G.P_CARDS.empty, G.P_CENTERS[G.GAME.current_round.used_packs[i]], {bypass_discovery_center = true, bypass_discovery_ui = true})
                            create_shop_card_ui(card, 'Booster', G.shop_booster)
                            card.ability.booster_pos = i
                            card:start_materialize()
                            G.shop_booster:emplace(card)
                        end
                    end
                end
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.CONTROLLER.interrupt.focus = false
                        G.CONTROLLER.locks.shop_reroll = false
                        G.CONTROLLER:recall_cardarea_focus('shop_jokers')
                        for i = 1, #G.jokers.cards do
                            G.jokers.cards[i]:calculate_joker({reroll_shop = true})
                        end
                        return true
                    end
                }))
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({ func = function() save_run(); return true end}))
    end

    local SkipBooster = G.FUNCS.skip_booster
    G.FUNCS.skip_booster = function(e)
        SkipBooster(e)
        local isSkipBlindOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.gain_dollars_when_skip_booster ~= 0) or false
        if isSkipBlindOptionsEnabled == false then
            return
        end

        if G.GAME.selected_back.effect.config.gain_dollars_when_skip_booster ~= 0 then
            ease_dollars(G.GAME.selected_back.effect.config.gain_dollars_when_skip_booster)
        end
    end

    local IsFace = Card.is_face
    function Card:is_face(from_boss)

        local isSkipBlindOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.aces_are_faces or G.GAME.selected_back.effect.config.sevens_are_faces or G.GAME.selected_back.effect.config.stones_are_faces) or false
        if isSkipBlindOptionsEnabled == false then
            return IsFace(self, from_boss)
        end

        if self.debuff and not from_boss then return end

        local id = self:get_id()
        if id == 11 or id == 12 or id == 13 or next(find_joker("Pareidolia")) or (id == 14 and G.GAME.selected_back.effect.config.aces_are_faces) or (id == 7 and G.GAME.selected_back.effect.config.sevens_are_faces) or (G.GAME.selected_back.effect.config.stones_are_faces and CardUtils.isStone(self)) then
            return true
        end
    end

    local GetChipMult = Card.get_chip_mult
    function Card:get_chip_mult()
        local getChipMultOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.make_stones_lucky > 0 or G.GAME.selected_back.effect.config.make_sevens_lucky > 0 or G.GAME.selected_back.effect.config.triple_mult_cards_chance > 0 or G.GAME.selected_back.effect.config.disable_mult_cards_chance > 0) or false
        local sevenCheck = getChipMultOptionsEnabled and G.GAME.selected_back.effect.config.make_sevens_lucky > 0 and self:get_id() == 7
        local stoneCheck = getChipMultOptionsEnabled and G.GAME.selected_back.effect.config.make_stones_lucky > 0 and CardUtils.isStone(self)
        if getChipMultOptionsEnabled == false then
            return GetChipMult(self)
        end

        local isLucky = self.ability.effect == "Lucky Card"
        if isLucky == false and sevenCheck then
            local luckyRoll = math.random(1, 100)
            if G.GAME.selected_back.effect.config.make_sevens_lucky >= luckyRoll then
                isLucky = true
                self.ability.mult = 20
            end
        end
        if isLucky == false and stoneCheck then
            local luckyRoll = math.random(1, 100)
            if G.GAME.selected_back.effect.config.make_stones_lucky >= luckyRoll then
                isLucky = true
                self.ability.mult = 20
            end
        end


        if self.debuff then return 0 end
        if self.ability.set == 'Joker' then return 0 end
        if isLucky then
            if pseudorandom('lucky_mult') < G.GAME.probabilities.normal/5 then
                self.lucky_trigger = true
                return self.ability.mult
            else
                return 0
            end
        else
            if self.ability.effect == "Mult Card" and G.GAME.selected_back.effect.config.triple_mult_cards_chance > 0 then
                local roll = math.random(1, 100)
                if G.GAME.selected_back.effect.config.triple_mult_cards_chance >= roll then
                   return self.ability.mult * 3
                end
            end
            if self.ability.effect == "Mult Card" and G.GAME.selected_back.effect.config.disable_mult_cards_chance > 0 then
                local roll = math.random(1, 100)
                if G.GAME.selected_back.effect.config.disable_mult_cards_chance >= roll then
                    return 0
                end
            end
            return self.ability.mult
        end
    end

    local GPDollars = Card.get_p_dollars
    function Card:get_p_dollars()
        local isSkipBlindOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.chance_to_double_gold_seal > 0 or G.GAME.selected_back.effect.config.make_sevens_lucky > 0 or G.GAME.selected_back.effect.config.make_stones_lucky > 0 or G.GAME.selected_back.effect.config.chance_to_triple_gold_money > 0 or G.GAME.selected_back.effect.config.chance_to_disable_gold_money > 0) or false
        if isSkipBlindOptionsEnabled == false then
            return GPDollars(self)
        end

        if self.debuff then return 0 end

        local ret = 0

        if self.seal == 'Gold' then
            ret = ret + 3
            if G.GAME.selected_back.effect.config.chance_to_double_gold_seal then
                local roll = math.random(1, 100)
                if G.GAME.selected_back.effect.config.chance_to_double_gold_seal >= roll then
                    ret = ret + 3
                end
            end
        end

        if self.ability.p_dollars > 0 or (G.GAME.selected_back.effect.config.make_sevens_lucky and self:get_id() == 7) or (G.GAME.selected_back.effect.config.make_stones_lucky and CardUtils.isStone(self)) then
            local isLucky = self.ability.effect == "Lucky Card"
            if isLucky == false and G.GAME.selected_back.effect.config.make_sevens_lucky and self:get_id() == 7 then
                local luckyRoll = math.random(1, 100)
                if G.GAME.selected_back.effect.config.make_sevens_lucky >= luckyRoll then
                    isLucky = true
                    self.ability.p_dollars = 20
                end
            end
            if isLucky == false and G.GAME.selected_back.effect.config.make_stones_lucky and CardUtils.isStone(self) then
                local luckyRoll = math.random(1, 100)
                if G.GAME.selected_back.effect.config.make_stones_lucky >= luckyRoll then
                    isLucky = true
                    self.ability.p_dollars = 20
                end
            end
            if isLucky then
                if pseudorandom('lucky_money') < G.GAME.probabilities.normal/15 then
                    self.lucky_trigger = true
                    ret = ret +  self.ability.p_dollars
                end
            elseif self.ability.p_dollars > 0 then
                ret = ret + self.ability.p_dollars
            end
        end

        local tripledGold = false
        if self.ability.name == 'Gold Card' and G.GAME.selected_back.effect.config.chance_to_triple_gold_money > 0 and G.GAME.selected_back.effect.config.chance_to_triple_gold_money >= math.random(1, 100) then
            ret = ret + 6
            tripledGold = true
        end

        if self.ability.name == 'Gold Card' and G.GAME.selected_back.effect.config.chance_to_disable_gold_money > 0 and G.GAME.selected_back.effect.config.chance_to_disable_gold_money >= math.random(1, 100) then
            local minus = tripledGold and 9 or 3
            ret = ret - minus
        end

        if ret > 0 then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + ret
            G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
        end
        return ret
    end

    local CalculateSeal = Card.calculate_seal
    function Card:calculate_seal(context)

        local isSkipBlindOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.red_seal_silly_messages or G.GAME.selected_back.effect.config.extra_red_seal_repetitions > 0 or G.GAME.selected_back.effect.config.chance_for_two_purple_tarots > 0 or G.GAME.selected_back.effect.config.chance_to_disable_red_seal_retriggers > 0  or G.GAME.selected_back.effect.config.chance_purple_seal_rolls_spectral > 0 or G.GAME.selected_back.effect.config.purple_seal_switch_trigger) or false
        if isSkipBlindOptionsEnabled == false then
            return CalculateSeal(self, context)
        end

        local message = localize('k_again_ex')
        if G.GAME.selected_back.effect.config.red_seal_silly_messages then
            message = Utils.redSealMessages[math.random(#Utils.redSealMessages)]
        end

        local extraRepetitions = G.GAME.selected_back.effect.config.extra_red_seal_repetitions or 0
        if G.GAME.selected_back.effect.config.chance_to_disable_red_seal_retriggers > 0 and G.GAME.selected_back.effect.config.chance_to_disable_red_seal_retriggers >= math.random(1, 100) then
            extraRepetitions = -1
        end

        if self.debuff then return nil end
        if context.repetition then
            if self.seal == 'Red' then
                return {
                    message = message,
                    repetitions = 1 + extraRepetitions,
                    card = self
                }
            end
        end
        if context.discard then
            if self.seal == 'Purple' then
                local amount = 1
                local bufferAmount = 0
                if G.GAME.selected_back.effect.config.chance_for_two_purple_tarots > 0 and G.GAME.selected_back.effect.config.chance_for_two_purple_tarots >= math.random(1, 100) then
                    amount = 2
                    bufferAmount = 1
                end

                if #G.consumeables.cards + G.GAME.consumeable_buffer + bufferAmount < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + amount
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                            for i = 1, amount do
                                local _card
                                if G.GAME.selected_back.effect.config.chance_purple_seal_rolls_spectral > 0 and G.GAME.selected_back.effect.config.chance_purple_seal_rolls_spectral > math.random(1, 100) then
                                    _card = create_card("Spectral", G.consumeables, nil, nil, true, true, nil, 'ar2')
                                else
                                    _card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, '8ba')
                                end
                                _card:add_to_deck()
                                G.consumeables:emplace(_card)
                            end
                            G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                    card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})
                    if G.GAME.selected_back.effect.config.purple_seal_switch_trigger then
                        local seal_type = pseudorandom(pseudoseed('stdsealtype'..G.GAME.round_resets.ante))
                        if seal_type > 0.66 then
                            self:set_seal("Red")
                        elseif seal_type > 0.33 then
                            self:set_seal("Gold")
                        else
                            self:set_seal("Blue")
                        end
                    end
                end
            end
        end
    end

    local GetEndOfRoundEffect = Card.get_end_of_round_effect
    function Card:get_end_of_round_effect(context)
        local isSkipBlindOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.blue_seal_switch_trigger or G.GAME.selected_back.effect.config.blue_seal_always_most_played or G.GAME.selected_back.effect.config.chance_for_negative_joker_on_blue_seal_trigger > 0) or false
        if isSkipBlindOptionsEnabled == false then
            return GetEndOfRoundEffect(self, context)
        end

        if self.debuff then return {} end
        local ret = {}
        if self.ability.h_dollars > 0 then
            ret.h_dollars = self.ability.h_dollars
            ret.card = self
        end
        if self.seal == 'Blue' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then

            local forced_key
            if G.GAME.selected_back.effect.config.blue_seal_always_most_played then
                local _planet, _hand, _tally = nil, nil, 0
                for k, v in ipairs(G.handlist) do
                    if G.GAME.hands[v].visible and G.GAME.hands[v].played > _tally then
                        _hand = v
                        _tally = G.GAME.hands[v].played
                    end
                end
                if _hand then
                    for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                        if v.config.hand_type == _hand then
                            _planet = v.key
                        end
                    end
                end
                forced_key = _planet
            end

            local card_type = 'Planet'
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = (function()
                    local _card
                    if forced_key == nil and G.GAME.last_hand_played then
                        local _planet = 0
                        for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                            if v.config.hand_type == G.GAME.last_hand_played then
                                _planet = v.key
                            end
                        end
                        _card = create_card(card_type,G.consumeables, nil, nil, nil, nil, _planet, 'blusl')
                    elseif forced_key ~= nil then
                        _card = create_card(card_type,G.consumeables, nil, nil, nil, nil, forced_key, 'blusl')
                    end

                    if _card ~= nil then
                        _card:add_to_deck()
                        G.consumeables:emplace(_card)
                        G.GAME.consumeable_buffer = 0
                    end
                    return true
                end)}))
            card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet})
            ret.effect = true

            if G.GAME.selected_back.effect.config.blue_seal_switch_trigger then
                local seal_type = pseudorandom(pseudoseed('stdsealtype'..G.GAME.round_resets.ante))
                if seal_type > 0.66 then
                    self:set_seal("Red")
                elseif seal_type > 0.33 then
                    self:set_seal("Gold")
                else
                    self:set_seal("Purple")
                end
            end
            if G.GAME.selected_back.effect.config.chance_for_negative_joker_on_blue_seal_trigger > 0 and G.GAME.selected_back.effect.config.chance_for_negative_joker_on_blue_seal_trigger >= math.random(1, 100) then
                CardUtils.receiveRandomNegativeJoker()
            end
        end
        return ret
    end

    local function find_most_played_hands()
        local hand_play_counts = {}
        local max_play_count = 0
        for _, hand in ipairs(G.handlist) do
            local play_count = G.GAME.hands[hand].played
            if play_count > 0 then
                hand_play_counts[hand] = play_count
                max_play_count = math.max(max_play_count, play_count)
            end
        end

        -- Filter hands that are played as frequently as the max but exclude if all hands are equally played or not played
        local most_played_hands = {}
        if max_play_count > 0 then
            for hand, count in pairs(hand_play_counts) do
                if count == max_play_count then
                    most_played_hands[hand] = true
                end
            end
        end
        return most_played_hands, max_play_count
    end

    local OpenCard = Card.open
    function Card:open()

        local isSkipBlindOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.spectral_cards_in_arcana or G.GAME.selected_back.effect.config.always_telescoping or G.GAME.selected_back.effect.config.never_telescoping or G.GAME.selected_back.effect.config.tarot_cards_in_spectral or G.GAME.selected_back.effect.config.tarot_cards_in_celestial or G.GAME.selected_back.effect.config.planet_cards_in_arcana or G.GAME.selected_back.effect.config.planet_cards_in_spectral or G.GAME.selected_back.effect.config.spectral_cards_in_celestial
                or G.GAME.selected_back.effect.config.chance_for_free_booster > 0 or G.GAME.selected_back.effect.config.extra_arcana_pack_cards > 0 or G.GAME.selected_back.effect.config.extra_spectral_pack_cards > 0 or G.GAME.selected_back.effect.config.extra_celestial_pack_cards > 0 or G.GAME.selected_back.effect.config.extra_standard_pack_cards > 0 or G.GAME.selected_back.effect.config.extra_buffoon_pack_cards > 0
                or G.GAME.selected_back.effect.config.extra_booster_pack_choices > 0 or (G.GAME.selected_back.effect.config.standard_pack_edition_rate and G.GAME.selected_back.effect.config.standard_pack_edition_rate ~= 2) or (G.GAME.selected_back.effect.config.standard_pack_enhancement_rate and G.GAME.selected_back.effect.config.standard_pack_enhancement_rate ~= 40) or (G.GAME.selected_back.effect.config.standard_pack_seal_rate and G.GAME.selected_back.effect.config.standard_pack_seal_rate ~= 20)) or false
        local baseGamePack = self.ability ~= nil and self.ability.set == "Booster" and (self.ability.name:find('Arcana') or self.ability.name:find('Celestial') or self.ability.name:find('Spectral') or self.ability.name:find('Standard') or self.ability.name:find('Buffoon'))
        if isSkipBlindOptionsEnabled == false or baseGamePack == nil or baseGamePack == false then
            return OpenCard(self)
        end

        if self.ability.set == "Booster" then
            stop_use()
            G.STATE_COMPLETE = false
            self.opening = true

            if not self.config.center.discovered then
                discover_card(self.config.center)
            end
            self.states.hover.can = false

            if self.ability.name:find('Arcana') then
                G.STATE = G.STATES.TAROT_PACK
                G.GAME.pack_size = self.ability.extra
                if G.GAME.selected_back.effect.config.extra_arcana_pack_cards > 0 then
                    G.GAME.pack_size = G.GAME.pack_size + G.GAME.selected_back.effect.config.extra_arcana_pack_cards
                end
            elseif self.ability.name:find('Celestial') then
                G.STATE = G.STATES.PLANET_PACK
                G.GAME.pack_size = self.ability.extra
                if G.GAME.selected_back.effect.config.extra_celestial_pack_cards > 0 then
                    G.GAME.pack_size = G.GAME.pack_size + G.GAME.selected_back.effect.config.extra_celestial_pack_cards
                end
            elseif self.ability.name:find('Spectral') then
                G.STATE = G.STATES.SPECTRAL_PACK
                G.GAME.pack_size = self.ability.extra
                if G.GAME.selected_back.effect.config.extra_spectral_pack_cards > 0 then
                    G.GAME.pack_size = G.GAME.pack_size + G.GAME.selected_back.effect.config.extra_spectral_pack_cards
                end
            elseif self.ability.name:find('Standard') then
                G.STATE = G.STATES.STANDARD_PACK
                G.GAME.pack_size = self.ability.extra
                if G.GAME.selected_back.effect.config.extra_standard_pack_cards > 0 then
                    G.GAME.pack_size = G.GAME.pack_size + G.GAME.selected_back.effect.config.extra_standard_pack_cards
                end
            elseif self.ability.name:find('Buffoon') then
                G.STATE = G.STATES.BUFFOON_PACK
                G.GAME.pack_size = self.ability.extra
                if G.GAME.selected_back.effect.config.extra_buffoon_pack_cards > 0 then
                    G.GAME.pack_size = G.GAME.pack_size + G.GAME.selected_back.effect.config.extra_buffoon_pack_cards
                end
            end

            local packSize = G.GAME.pack_size

            G.GAME.pack_choices = self.config.center.config.choose or 1
            if G.GAME.selected_back.effect.config.extra_booster_pack_choices > 0 then
                G.GAME.pack_choices = G.GAME.pack_choices + G.GAME.selected_back.effect.config.extra_booster_pack_choices
            end

            if G.GAME.pack_choices > packSize then G.GAME.pack_choices = packSize end

            if self.cost > 0 then
                local skip = false
                if G.GAME.selected_back.effect.config.chance_for_free_booster > 0 then
                    skip = G.GAME.selected_back.effect.config.chance_for_free_booster >= math.random(1, 100)
                end

                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
                    if skip == false then
                        inc_career_stat('c_shop_dollars_spent', self.cost)
                    end
                    self:juice_up()
                    return true end
                }))
                if skip == false then
                    ease_dollars(-self.cost)
                end
            else
                delay(0.2)
            end

            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                self:explode()
                local pack_cards = {}

                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1.3*math.sqrt(G.SETTINGS.GAMESPEED), blockable = false, blocking = false, func = function()

                    for i = 1, packSize do
                        local card
                        if self.ability.name:find('Arcana') then
                            if (G.GAME.used_vouchers.v_omen_globe or G.GAME.selected_back.effect.config.spectral_cards_in_arcana) and pseudorandom('omen_globe') > 0.8 then
                                card = create_card("Spectral", G.pack_cards, nil, nil, true, true, nil, 'ar2')
                            elseif G.GAME.selected_back.effect.config.planet_cards_in_arcana and pseudorandom('omen_globe') > 0.8 then
                                card = create_card("Planet", G.pack_cards, nil, nil, true, true, nil, 'pl1')
                            else
                                card = create_card("Tarot", G.pack_cards, nil, nil, true, true, nil, 'ar1')
                            end
                        elseif self.ability.name:find('Celestial') then
                            if (G.GAME.used_vouchers.v_telescope or G.GAME.selected_back.effect.config.always_telescoping) and i == 1 then
                                local _planet, _hand, _tally = nil, nil, 0
                                for k, v in ipairs(G.handlist) do
                                    if G.GAME.hands[v].visible and G.GAME.hands[v].played > _tally then
                                        _hand = v
                                        _tally = G.GAME.hands[v].played
                                    end
                                end
                                if _hand then
                                    for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                                        if v.config.hand_type == _hand then
                                            _planet = v.key
                                        end
                                    end
                                end
                                card = create_card("Planet", G.pack_cards, nil, nil, true, true, _planet, 'pl1')
                            elseif G.GAME.selected_back.effect.config.never_telescoping then
                                local most_played_hands, _ = find_most_played_hands()
                                local isPlanet = true
                                repeat
                                    if G.GAME.selected_back.effect.config.tarot_cards_in_celestial and pseudorandom('omen_globe') > 0.8 then
                                        card = create_card("Tarot", G.pack_cards, nil, nil, true, true, nil, 'ar1')
                                        isPlanet = false
                                    elseif G.GAME.selected_back.effect.config.spectral_cards_in_celestial and pseudorandom('omen_globe') > 0.8 then
                                        card = create_card("Spectral", G.pack_cards, nil, nil, true, true, nil, 'ar2')
                                        isPlanet = false
                                    else
                                        card = create_card("Planet", G.pack_cards, nil, nil, true, true, nil, 'pl1')
                                    end
                                until not isPlanet or not most_played_hands[card.config.center.hand_type] or not card.config.center.hand_type
                            else
                                if G.GAME.selected_back.effect.config.tarot_cards_in_celestial and pseudorandom('omen_globe') > 0.8 then
                                    card = create_card("Tarot", G.pack_cards, nil, nil, true, true, nil, 'ar1')
                                elseif G.GAME.selected_back.effect.config.spectral_cards_in_celestial and pseudorandom('omen_globe') > 0.8 then
                                    card = create_card("Spectral", G.pack_cards, nil, nil, true, true, nil, 'ar2')
                                else
                                    card = create_card("Planet", G.pack_cards, nil, nil, true, true, nil, 'pl1')
                                end
                            end
                        elseif self.ability.name:find('Spectral') then
                            if G.GAME.selected_back.effect.config.tarot_cards_in_spectral and pseudorandom('omen_globe') > 0.8 then
                                card = create_card("Tarot", G.pack_cards, nil, nil, true, true, nil, 'ar1')
                            elseif G.GAME.selected_back.effect.config.planet_cards_in_spectral and pseudorandom('omen_globe') > 0.8 then
                                card = create_card("Planet", G.pack_cards, nil, nil, true, true, nil, 'pl1')
                            else
                                card = create_card("Spectral", G.pack_cards, nil, nil, true, true, nil, 'spe')
                            end
                        elseif self.ability.name:find('Standard') then
                            local enhancement_rate = (G.GAME.selected_back.effect.config.standard_pack_enhancement_rate or 4) / 100
                            card = create_card((enhancement_rate >= pseudorandom(pseudoseed('stdset'..G.GAME.round_resets.ante))) and "Enhanced" or "Base", G.pack_cards, nil, nil, nil, true, nil, 'sta')
                            local edition_rate = G.GAME.selected_back.effect.config.standard_pack_edition_rate or 2
                            local edition = poll_edition('standard_edition'..G.GAME.round_resets.ante, edition_rate, true)
                            card:set_edition(edition)
                            local seal_rate = (G.GAME.selected_back.effect.config.standard_pack_seal_rate or 20) / 100
                            local seal_poll = pseudorandom(pseudoseed('stdseal'..G.GAME.round_resets.ante))
                            if seal_rate >= seal_poll then
                                local seal_type = pseudorandom(pseudoseed('stdsealtype'..G.GAME.round_resets.ante))
                                if seal_type > 0.75 then card:set_seal('Red')
                                elseif seal_type > 0.5 then card:set_seal('Blue')
                                elseif seal_type > 0.25 then card:set_seal('Gold')
                                else card:set_seal('Purple')
                                end
                            end
                        elseif self.ability.name:find('Buffoon') then
                            card = create_card("Joker", G.pack_cards, nil, nil, true, true, nil, 'buf')
                        end

                        if card ~= nil then
                            card.T.x = self.T.x
                            card.T.y = self.T.y
                            card:start_materialize({G.C.WHITE, G.C.WHITE}, nil, 1.5*G.SETTINGS.GAMESPEED)
                            pack_cards[i] = card
                        end
                    end
                    return true
                end}))

                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1.3*math.sqrt(G.SETTINGS.GAMESPEED), blockable = false, blocking = false, func = function()
                    if G.pack_cards then
                        if G.pack_cards and G.pack_cards.VT.y < G.ROOM.T.h then
                            for k, v in ipairs(pack_cards) do
                                G.pack_cards:emplace(v)
                            end
                            return true
                        end
                    end
                end}))

                for i = 1, #G.jokers.cards do
                    G.jokers.cards[i]:calculate_joker({open_booster = true, card = self})
                end

                if G.GAME.modifiers.inflation then
                    G.GAME.inflation = G.GAME.inflation + 1
                    G.E_MANAGER:add_event(Event({func = function()
                        for k, v in pairs(G.I.CARD) do
                            if v.set_cost then v:set_cost() end
                        end
                        return true end }))
                end

                return true end }))
        end
    end

    local UpdateCelestialPack = Game.update_celestial_pack
    function Game:update_celestial_pack(dt)

        local isSkipBlindOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.tarot_cards_in_celestial or G.GAME.selected_back.effect.config.spectral_cards_in_celestial) or false
        if isSkipBlindOptionsEnabled == false then
            return UpdateCelestialPack(self, dt)
        end

        if self.buttons then self.buttons:remove(); self.buttons = nil end
        if self.shop then G.shop.alignment.offset.y = G.ROOM.T.y+11 end

        if not G.STATE_COMPLETE then
            G.STATE_COMPLETE = true
            G.CONTROLLER.interrupt.focus = true
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    ease_background_colour_blind(G.STATES.PLANET_PACK)
                    G.booster_pack_stars = Particles(1, 1, 0,0, {
                        timer = 0.07,
                        scale = 0.1,
                        initialize = true,
                        lifespan = 15,
                        speed = 0.1,
                        padding = -4,
                        attach = G.ROOM_ATTACH,
                        colours = {G.C.WHITE, HEX('a7d6e0'), HEX('fddca0')},
                        fill = true
                    })
                    G.booster_pack_meteors = Particles(1, 1, 0,0, {
                        timer = 2,
                        scale = 0.05,
                        lifespan = 1.5,
                        speed = 4,
                        attach = G.ROOM_ATTACH,
                        colours = {G.C.WHITE},
                        fill = true
                    })
                    G.booster_pack = UIBox{
                        definition = create_UIBox_celestial_pack(),
                        config = {
                            align="tmi",
                            offset = {x=0,y=G.ROOM.T.y + 9},
                            major = G.hand,
                            bond = 'Weak'
                        }
                    }
                    G.booster_pack.alignment.offset.y = -2.2
                    G.ROOM.jiggle = G.ROOM.jiggle + 3
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        func = function()
                            G.FUNCS.draw_from_deck_to_hand()

                            G.E_MANAGER:add_event(Event({
                                trigger = 'after',
                                delay = 0.5,
                                func = function()
                                    G.CONTROLLER:recall_cardarea_focus('pack_cards')
                                    return true
                                end}))
                            return true
                        end
                    }))
                    return true
                end
            }))
        end
    end

    local CreateCard = create_card
    function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)

        local isCreateCardOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.allow_duplicate_jokers or G.GAME.selected_back.effect.config.eternal_rate ~= 30 or G.GAME.selected_back.effect.config.rental_rate ~= 30 or G.GAME.selected_back.effect.config.perishable_rate ~= 30) or false
        if isCreateCardOptionsEnabled == false then
            return CreateCard(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
        end

        area = area or G.jokers
        local center = G.P_CENTERS.b_red

        --should pool be skipped with a forced key
        if not forced_key and soulable and (not G.GAME.banned_keys['c_soul']) then
            if (_type == 'Tarot' or _type == 'Spectral' or _type == 'Tarot_Planet') and not (G.GAME.used_jokers['c_soul'] and not next(find_joker("Showman")))  then
                if pseudorandom('soul_'.._type..G.GAME.round_resets.ante) > 0.997 then
                    forced_key = 'c_soul'
                end
            end
            if (_type == 'Planet' or _type == 'Spectral') and not (G.GAME.used_jokers['c_black_hole'] and not next(find_joker("Showman")))  then
                if pseudorandom('soul_'.._type..G.GAME.round_resets.ante) > 0.997 then
                    forced_key = 'c_black_hole'
                end
            end
        end

        if _type == 'Base' then
            forced_key = 'c_base'
        end

        if forced_key and not G.GAME.banned_keys[forced_key] then
            center = G.P_CENTERS[forced_key]
            _type = (center.set ~= 'Default' and center.set or _type)
        else
            local _pool, _pool_key = get_current_pool(_type, _rarity, legendary, key_append)
            center = pseudorandom_element(_pool, pseudoseed(_pool_key))
            local it = 1
            while center == 'UNAVAILABLE' do
                it = it + 1
                center = pseudorandom_element(_pool, pseudoseed(_pool_key..'_resample'..it))
            end

            center = G.P_CENTERS[center]
        end

        local front = ((_type=='Base' or _type == 'Enhanced') and pseudorandom_element(G.P_CARDS, pseudoseed('front'..(key_append or '')..G.GAME.round_resets.ante))) or nil

        local card = Card(area.T.x + area.T.w/2, area.T.y, G.CARD_W, G.CARD_H, front, center,
                {bypass_discovery_center = area==G.shop_jokers or area == G.pack_cards or area == G.shop_vouchers or (G.shop_demo and area==G.shop_demo) or area==G.jokers or area==G.consumeables,
                 bypass_discovery_ui = area==G.shop_jokers or area == G.pack_cards or area==G.shop_vouchers or (G.shop_demo and area==G.shop_demo),
                 discover = area==G.jokers or area==G.consumeables,
                 bypass_back = G.GAME.selected_back.pos})
        if card.ability.consumeable and not skip_materialize then card:start_materialize() end

        if _type == 'Joker' then
            if G.GAME.modifiers.all_eternal then
                card:set_eternal(true)
            end
            if (area == G.shop_jokers) or (area == G.pack_cards) then
                local eternalRate = G.GAME.selected_back.effect.config.eternal_rate or 30
                local perishRate = G.GAME.selected_back.effect.config.perishable_rate or 30
                local rentalRate = G.GAME.selected_back.effect.config.rental_rate or 30
                local isEternal = false
                if G.GAME.modifiers.enable_eternals_in_shop and (100 * pseudorandom('etperpoll'..G.GAME.round_resets.ante)) <= eternalRate then
                    card:set_eternal(true)
                    isEternal = true
                end
                if isEternal == false and G.GAME.modifiers.enable_perishables_in_shop and (100 * pseudorandom('ssjp'..G.GAME.round_resets.ante)) <= perishRate then
                    card:set_perishable(true)
                end
                if G.GAME.modifiers.enable_rentals_in_shop and (100 * pseudorandom('ssjr'..G.GAME.round_resets.ante)) <= rentalRate then
                    card:set_rental(true)
                end
            end

            local edition = poll_edition('edi'..(key_append or '')..G.GAME.round_resets.ante)
            card:set_edition(edition)
        end
        return card
    end

    local GetCurrentPool = get_current_pool
    function get_current_pool(_type, _rarity, _legendary, _append)

        local isSkipBlindOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.allow_soul or G.GAME.selected_back.effect.config.allow_black_hole or G.GAME.selected_back.effect.config.allow_duplicate_jokers or G.GAME.selected_back.effect.config.allow_legendary_jokers_everywhere or #G.GAME.selected_back.effect.config.bannedJokerList > 0 or #G.GAME.selected_back.effect.config.bannedVoucherList > 0 or #G.GAME.selected_back.effect.config.bannedTarotList > 0 or #G.GAME.selected_back.effect.config.bannedPlanetList > 0 or #G.GAME.selected_back.effect.config.bannedSpectralList > 0 or #G.GAME.selected_back.effect.config.bannedTagList > 0) or false
        if isSkipBlindOptionsEnabled == false then
            return GetCurrentPool(_type, _rarity, _legendary, _append)
        end

        --create the pool
        G.ARGS.TEMP_POOL = EMPTY(G.ARGS.TEMP_POOL)
        local _pool, _starting_pool, _pool_key, _pool_size = G.ARGS.TEMP_POOL, nil, '', 0

        if _type == 'Joker' then
            local rarity = _rarity or pseudorandom('rarity'..G.GAME.round_resets.ante..(_append or ''))
            if G.GAME.selected_back.effect.config.allow_legendary_jokers_everywhere then
                rarity = ((_legendary or rarity > 0.97) and 4) or (rarity > 0.92 and 3) or (rarity > 0.69 and 2) or 1
            else
                rarity = (_legendary and 4) or (rarity > 0.95 and 3) or (rarity > 0.7 and 2) or 1
            end
            _starting_pool, _pool_key = G.P_JOKER_RARITY_POOLS[rarity], 'Joker'..rarity..((not _legendary and _append) or '')
        else _starting_pool, _pool_key = G.P_CENTER_POOLS[_type], _type..(_append or '')
        end


        --cull the pool
        for k, v in ipairs(_starting_pool) do

            local hasJoker = G.GAME.used_jokers[v.key] and not G.GAME.selected_back.effect.config.allow_duplicate_jokers
            -- local legendCheck = v.rarity == 4 and not G.GAME.selected_back.effect.config.allow_legendary_jokers_everywhere

            local add
            if _type == 'Enhanced' then
                add = true
            elseif _type == 'Demo' then
                if v.pos and v.config then add = true end
            elseif _type == 'Tag' then
                if #G.GAME.selected_back.effect.config.bannedTagList > 0 then
                    add = true
                elseif (not v.requires or (G.P_CENTERS[v.requires] and G.P_CENTERS[v.requires].discovered)) and (not v.min_ante or v.min_ante <= G.GAME.round_resets.ante) then
                    add = true
                end
            elseif not (hasJoker and not next(find_joker("Showman"))) and (v.unlocked ~= false or v.rarity == 4) then
                if v.set == 'Voucher' then
                    if not G.GAME.used_vouchers[v.key] then
                        local include = true
                        if v.requires then
                            for kk, vv in pairs(v.requires) do
                                if not G.GAME.used_vouchers[vv] then
                                    include = false
                                end
                            end
                        end
                        if G.shop_vouchers and G.shop_vouchers.cards then
                            for kk, vv in ipairs(G.shop_vouchers.cards) do
                                if vv.config.center.key == v.key then include = false end
                            end
                        end
                        if include then
                            add = true
                        end
                    end
                elseif v.set == 'Planet' then
                    if (not v.config.softlock or G.GAME.hands[v.config.hand_type].played > 0) then
                        add = true
                    end
                elseif v.enhancement_gate then
                    add = nil
                    for kk, vv in pairs(G.playing_cards) do
                        if vv.config.center.key == v.enhancement_gate then
                            add = true
                        end
                    end
                else
                    add = true
                end
                if v.name == 'Black Hole' then
                    add = G.GAME.selected_back.effect.config.allow_black_hole
                end
                if v.name == 'The Soul' then
                    add = G.GAME.selected_back.effect.config.allow_soul
                end
            end

            if v.no_pool_flag and G.GAME.pool_flags[v.no_pool_flag] then add = nil end
            if v.yes_pool_flag and not G.GAME.pool_flags[v.yes_pool_flag] then add = nil end

            if add and not G.GAME.banned_keys[v.key] then
                _pool[#_pool + 1] = v.key
                _pool_size = _pool_size + 1
            else
                _pool[#_pool + 1] = 'UNAVAILABLE'
            end
        end

        --if pool is empty
        if _pool_size == 0 then
            _pool = EMPTY(G.ARGS.TEMP_POOL)
            if _type == 'Tarot' or _type == 'Tarot_Planet' then _pool[#_pool + 1] = "c_strength"
            elseif _type == 'Planet' then _pool[#_pool + 1] = "c_pluto"
            elseif _type == 'Spectral' then _pool[#_pool + 1] = "c_incantation"
            elseif _type == 'Joker' then _pool[#_pool + 1] = "j_joker"
            elseif _type == 'Demo' then _pool[#_pool + 1] = "j_joker"
            elseif _type == 'Voucher' then _pool[#_pool + 1] = "v_blank"
            elseif _type == 'Tag' then _pool[#_pool + 1] = "tag_handy"
            else _pool[#_pool + 1] = "j_joker"
            end
        end

        return _pool, _pool_key..(not _legendary and G.GAME.round_resets.ante or '')
    end

    local createUiBoxBlindTag = create_UIBox_blind_tag
    function create_UIBox_blind_tag(blind_choice, run_info)

        local isSkipBlindOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.skip_blind_disabled_chance_small_blind or G.GAME.selected_back.effect.config.skip_blind_disabled_chance_big_blind or G.GAME.selected_back.effect.config.skip_blind_disabled_chance_any) or false
        if isSkipBlindOptionsEnabled == false then
            return createUiBoxBlindTag(blind_choice, run_info)
        end

        local smallDefeated = blind_choice == 'Small' and G.GAME.selected_back.effect.config.skip_blind_disabled_chance_small_blind and G.GAME.selected_back.effect.config.skip_blind_disabled_chance_small_blind > 0
        local bigDefeated = blind_choice == 'Big' and G.GAME.selected_back.effect.config.skip_blind_disabled_chance_big_blind and G.GAME.selected_back.effect.config.skip_blind_disabled_chance_big_blind > 0
        local anyDefeated = G.GAME.selected_back.effect.config.skip_blind_disabled_chance_any and G.GAME.selected_back.effect.config.skip_blind_disabled_chance_any > 0
        local skipBlindDisabled = false

        if bigDefeated then
            local roll = math.random(1, 100)
            if roll <= G.GAME.selected_back.effect.config.skip_blind_disabled_chance_big_blind then
                skipBlindDisabled = true
            end
        elseif smallDefeated then
            local roll = math.random(1, 100)
            if roll <= G.GAME.selected_back.effect.config.skip_blind_disabled_chance_small_blind then
                skipBlindDisabled = true
            end
        end

        if skipBlindDisabled == false and anyDefeated then
            local roll = math.random(1, 100)
            if roll <= G.GAME.selected_back.effect.config.skip_blind_disabled_chance_any then
                skipBlindDisabled = true
            end
        end

        if skipBlindDisabled == false then
            return createUiBoxBlindTag(blind_choice, run_info)
        end

        if G.GAME.selected_back.effect.config.chance_for_five_dollars_on_skip_disable > 0 then
            if G.GAME.selected_back.effect.config.chance_for_five_dollars_on_skip_disable >= math.random(1, 100) then
                ease_dollars(5)
            end
        end

        if G.GAME.selected_back.effect.config.chance_for_fifteen_dollars_on_skip_disable > 0 then
            if G.GAME.selected_back.effect.config.chance_for_fifteen_dollars_on_skip_disable >= math.random(1, 100) then
                ease_dollars(15)
            end
        end

        if G.GAME.selected_back.effect.config.chance_for_negative_joker_on_skip_disable > 0 then
            if G.GAME.selected_back.effect.config.chance_for_negative_joker_on_skip_disable >= math.random(1, 100) then
                CardUtils.receiveRandomNegativeJoker()
            end
        end

        return nil
    end

    local CashOut = G.FUNCS.cash_out
    G.FUNCS.cash_out = function(e)
        local isSkipShopOptionsEnabled = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and (G.GAME.selected_back.effect.config.skip_shop_chance_small_blind or G.GAME.selected_back.effect.config.skip_shop_chance_big_blind or G.GAME.selected_back.effect.config.skip_shop_chance_boss or G.GAME.selected_back.effect.config.skip_shop_chance_any) or false
        if isSkipShopOptionsEnabled then
            local smallDefeated = G.GAME.round_resets.blind_states.Small == 'Defeated' and G.GAME.selected_back.effect.config.skip_shop_chance_small_blind and G.GAME.selected_back.effect.config.skip_shop_chance_small_blind > 0
            local bigDefeated = G.GAME.round_resets.blind_states.Big == 'Defeated' and G.GAME.selected_back.effect.config.skip_shop_chance_big_blind and G.GAME.selected_back.effect.config.skip_shop_chance_big_blind > 0
            local bossDefeated = G.GAME.round_resets.blind_states.Boss == 'Defeated' and G.GAME.selected_back.effect.config.skip_shop_chance_boss and G.GAME.selected_back.effect.config.skip_shop_chance_boss > 0
            local anyDefeated = G.GAME.selected_back.effect.config.skip_shop_chance_any and G.GAME.selected_back.effect.config.skip_shop_chance_any > 0
            local canWinNegativeJoker = G.GAME.selected_back.effect.config.chance_for_random_negative_joker_on_shop_skip and G.GAME.selected_back.effect.config.chance_for_random_negative_joker_on_shop_skip > 0
            local canWinTwentyDollars = G.GAME.selected_back.effect.config.chance_for_twenty_dollars_on_shop_skip and G.GAME.selected_back.effect.config.chance_for_twenty_dollars_on_shop_skip > 0
            local skipShop = false
            if bossDefeated then
                local roll = math.random(1, 100)
                if roll <= G.GAME.selected_back.effect.config.skip_shop_chance_boss then
                    skipShop = true
                    G.GAME.round_resets.blind_ante = G.GAME.round_resets.ante
                    G.GAME.round_resets.blind_tags.Small = get_next_tag_key()
                    G.GAME.round_resets.blind_tags.Big = get_next_tag_key()
                end
            elseif bigDefeated then
                local roll = math.random(1, 100)
                if roll <= G.GAME.selected_back.effect.config.skip_shop_chance_big_blind then
                    skipShop = true
                end
            elseif smallDefeated then
                local roll = math.random(1, 100)
                if roll <= G.GAME.selected_back.effect.config.skip_shop_chance_small_blind then
                    skipShop = true
                end
            end

            if skipShop == false and anyDefeated then
                local roll = math.random(1, 100)
                if roll <= G.GAME.selected_back.effect.config.skip_shop_chance_any then
                    skipShop = true
                end
            end

            if skipShop == false then
                CashOut(e)
                return
            end

            if canWinNegativeJoker then
                if G.GAME.selected_back.effect.config.chance_for_random_negative_joker_on_shop_skip >= math.random(1, 100) then
                    CardUtils.receiveRandomNegativeJoker()
                end
            end

            if canWinTwentyDollars then
                if G.GAME.selected_back.effect.config.chance_for_twenty_dollars_on_shop_skip >= math.random(1, 100) then
                    ease_dollars(20)
                end
            end

            stop_use()
            if G.round_eval then
                e.config.button = nil
                G.round_eval.alignment.offset.y = G.ROOM.T.y + 15
                G.round_eval.alignment.offset.x = 0
                G.deck:shuffle('cashout'..G.GAME.round_resets.ante)
                G.deck:hard_set_T()
                delay(0.3)
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        if G.round_eval then
                            G.round_eval:remove()
                            G.round_eval = nil
                        end
                        G.GAME.current_round.jokers_purchased = 0
                        G.GAME.current_round.discards_left = math.max(0, G.GAME.round_resets.discards + G.GAME.round_bonus.discards)
                        G.GAME.current_round.hands_left = (math.max(1, G.GAME.round_resets.hands + G.GAME.round_bonus.next_hands))
                        G.STATE = G.STATES.BLIND_SELECT
                        G.GAME.shop_free = nil
                        G.GAME.shop_d6ed = nil
                        G.STATE_COMPLETE = false
                        return true
                    end
                }))
                ease_dollars(G.GAME.current_round.dollars)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        G.GAME.previous_round.dollars = G.GAME.dollars
                        return true
                    end
                }))
                play_sound("coin7")
                G.VIBRATION = G.VIBRATION + 1
            end
            ease_chips(0)
            if G.GAME.round_resets.blind_states.Boss == 'Defeated' then
                G.GAME.round_resets.blind_ante = G.GAME.round_resets.ante
                G.GAME.round_resets.blind_tags.Small = get_next_tag_key()
                G.GAME.round_resets.blind_tags.Big = get_next_tag_key()
            end
            delay(0.6)
        else
            CashOut(e)
            return
        end
    end

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
                return true
            end
        }))
    end

    local getBlindAmount = get_blind_amount
    function get_blind_amount(ante)
        local isModifyingBlindScaling = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and G.GAME.selected_back.effect.config.customDeck and G.GAME.selected_back.effect.config.blind_scaling and G.GAME.selected_back.effect.config.blind_scaling ~= 1 or false
        local mod = 1
        if isModifyingBlindScaling then
            mod = G.GAME.selected_back.effect.config.blind_scaling
        end
        return math.floor(getBlindAmount(ante) * mod)
    end

    local EndRound = end_round
    function end_round()
        -- Utils.resetShopJokerPages()
        EndRound()

        local deck = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config or nil
        if deck.customDeck then
            if G.jokers and G.jokers.cards and #G.jokers.cards >0 then

                if G.GAME.blind and G.GAME.blind:get_type() == 'Boss' and G.GAME.round_resets.ante == 4 and deck.destroy_random_joker_after_ante_four > 0  then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            local roll = math.random(1, 100)
                            if deck.destroy_random_joker_after_ante_four >= roll then
                                CardUtils.destroyRandomJoker()
                            end
                            return true
                        end
                    }))
                end

                if deck.random_sell_value_increase then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            local list = G.jokers.cards
                            local rand = list[math.random(1, #list)]
                            if rand.set_cost then
                                rand.ability.extra_value = (rand.ability.extra_value or 0) + deck.random_sell_value_increase
                                rand:juice_up()
                                rand:set_cost()
                            end
                            return true
                        end
                    }))
                end

                if deck.random_sell_value_decrease then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.2,
                        func = function()
                            local list = G.jokers.cards
                            local secondList = {}
                            for k,v in pairs(list) do
                                if v.ability.extra_value > 0 then
                                    table.insert(secondList, v)
                                end
                            end

                            local rand
                            if #secondList > 0 then
                                rand = secondList[math.random(1, #secondList)]
                            else
                                rand = list[math.random(1, #list)]
                            end

                            if rand and rand.set_cost then
                                rand.ability.extra_value = (rand.ability.extra_value or 0) - deck.random_sell_value_decrease
                                if rand.ability.extra_value < 0 then
                                    rand.ability.extra_value = 0
                                end
                                rand:juice_up()
                                rand:set_cost()
                            end
                            return true
                        end
                    }))
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
            local dollarsToModify = 0
            if deck.effect.config.enhanced_dollars_per_round and deck.effect.config.enhanced_dollars_per_round ~= 0 then
                local enhancedCards = 0
                for k,v in pairs(G.playing_cards) do
                    if v.config.center ~= G.P_CENTERS.c_base then
                        enhancedCards = enhancedCards + 1
                    end
                end
                if enhancedCards > 0 then
                    dollarsToModify = dollarsToModify + (enhancedCards * deck.effect.config.enhanced_dollars_per_round)
                    --[[if deck.effect.config.enhanced_dollars_per_round > 0 then
                        Utils.addDollarAmountAtEndOfRound(enhancedCards * deck.effect.config.enhanced_dollars_per_round, "Enhanced Cards ($1 each)")
                        G.GAME.current_round.dollars = G.GAME.current_round.dollars + (enhancedCards * deck.effect.config.enhanced_dollars_per_round)
                    else]]
                        -- ease_dollars(enhancedCards * deck.effect.config.enhanced_dollars_per_round, true)
                    -- end
                end
            end

            if deck.effect.config.negative_joker_money and deck.effect.config.negative_joker_money ~= 0 then
                local negativeJokers = 0
                for k,v in pairs(G.jokers.cards) do
                    if v.edition and v.edition.negative then
                        negativeJokers = negativeJokers + 1
                    end
                end

                if negativeJokers > 0 then
                    dollarsToModify = dollarsToModify + (negativeJokers * deck.effect.config.negative_joker_money)
                    --[[if deck.effect.config.negative_joker_money > 0 then
                        Utils.addDollarAmountAtEndOfRound(negativeJokers * deck.effect.config.negative_joker_money, "Negative Jokers ($1 each)")
                        G.GAME.current_round.dollars = G.GAME.current_round.dollars + (negativeJokers * deck.effect.config.negative_joker_money)
                    else]]
                        -- ease_dollars(negativeJokers * deck.effect.config.negative_joker_money, true)
                    -- end
                end
            end

            if dollarsToModify ~= 0 then
                ease_dollars(dollarsToModify, true)
            end
        end

    end

    local SetCost = Card.set_cost
    function Card:set_cost()
        local fullPriced = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and (self.ability.set == "Joker" and G.GAME.selected_back.effect.config.full_price_jokers) or ((self.ability.set == 'Planet' or self.ability.set == 'Tarot' or self.ability.set == 'Spectral') and G.GAME.selected_back.effect.config.full_price_consumables)
        local scaleBoosterCost = G.GAME and G.GAME.selected_back and G.GAME.selected_back.effect and G.GAME.selected_back.effect.config and self.ability.set == 'Booster' and G.GAME.selected_back.effect.config.booster_ante_scaling and type(G.GAME.selected_back.effect.config.booster_ante_scaling == 'number') and G.GAME.selected_back.effect.config.booster_ante_scaling > 0
        self.extra_cost = 0 + G.GAME.inflation
        if self.edition then
            self.extra_cost = self.extra_cost + (self.edition.holo and 3 or 0) + (self.edition.foil and 2 or 0) +
                    (self.edition.polychrome and 5 or 0) + (self.edition.negative and 5 or 0)
        end
        self.cost = math.max(1, math.floor((self.base_cost + self.extra_cost + 0.5)*(100-G.GAME.discount_percent)/100))
        if self.ability.set == 'Booster' and (G.GAME.modifiers.booster_ante_scaling or scaleBoosterCost) then
            if scaleBoosterCost then
                self.cost = self.cost + ((G.GAME.round_resets.ante - 1) * G.GAME.selected_back.effect.config.booster_ante_scaling)
            elseif G.GAME.modifiers.booster_ante_scaling == true then
                self.cost = self.cost + G.GAME.round_resets.ante - 1
            end
        end
        if self.ability.set == 'Booster' and (not G.SETTINGS.tutorial_complete) and G.SETTINGS.tutorial_progress and (not G.SETTINGS.tutorial_progress.completed_parts['shop_1']) then
            self.cost = self.cost + 3
        end
        if (self.ability.set == 'Planet' or (self.ability.set == 'Booster' and self.ability.name:find('Celestial'))) and #find_joker('Astronomer') > 0 then self.cost = 0 end
        if self.ability.rental then self.cost = 1 end
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
            local totalDollars = 0
            if deck.effect.config.broken_glass_money and deck.effect.config.broken_glass_money ~= 0 then
                totalDollars = totalDollars + deck.effect.config.broken_glass_money
            end
            if deck.effect.config.gain_ten_dollars_glass_break_chance and deck.effect.config.gain_ten_dollars_glass_break_chance > 0 then
                local roll = math.random(1, 100)
                if deck.effect.config.gain_ten_dollars_glass_break_chance >= roll then
                    totalDollars = totalDollars + 10

                end
            end

            if totalDollars ~= 0 then
                ease_dollars(totalDollars, true)
            end

            if deck.effect.config.destroy_joker_on_broken_glass > 0 and deck.effect.config.destroy_joker_on_broken_glass >= math.random(1, 100) then
                CardUtils.destroyRandomJoker()
            end

            if deck.effect.config.negative_joker_for_broken_glass > 0 and deck.effect.config.negative_joker_for_broken_glass >= math.random(1, 100) then
                CardUtils.receiveRandomNegativeJoker()
            end

            if deck.effect.config.replace_broken_glass_with_random_cards_chance and deck.effect.config.replace_broken_glass_with_random_cards_chance > 0 then
                local roll = math.random(1, 100)
                if deck.effect.config.replace_broken_glass_with_random_cards_chance >= roll then

                    local randomProto, key = CardUtils.generateCardProto({
                        rank = "Random",
                        suit = "Random",
                        edition = "Random",
                        enhancement = "Random",
                        seal = "Random",
                        copies = 1
                    })
                    local card = CardUtils.cardProtoToCardObject(randomProto, key, G.play.T.x + G.play.T.w/2, G.play.T.y)

                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                            card:start_materialize({G.C.SECONDARY_SET.Enhanced})
                            G.play:emplace(card)
                            table.insert(G.playing_cards, card)
                            return true
                        end
                    }))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            return true
                        end}))
                    draw_card(G.play,G.deck, 90,'up', nil)
                end
            end

            if deck.effect.config.replace_broken_glass_with_stones_chance and deck.effect.config.replace_broken_glass_with_stones_chance > 0 then
                local roll = math.random(1, 100)
                if deck.effect.config.replace_broken_glass_with_stones_chance >= roll then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local front = pseudorandom_element(G.P_CARDS, pseudoseed('marb_fr'))
                            G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                            local card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, front, G.P_CENTERS.m_stone, {playing_card = G.playing_card})
                            card:start_materialize({G.C.SECONDARY_SET.Enhanced})
                            G.play:emplace(card)
                            table.insert(G.playing_cards, card)
                            return true
                        end
                    }))
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            G.deck.config.card_limit = G.deck.config.card_limit + 1
                            return true
                        end}))
                    draw_card(G.play,G.deck, 90,'up', nil)
                end
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
            if Utils.getCurrentEditingDeck().config.custom_cards_set == false then
                Utils.getCurrentEditingDeck().config.custom_cards_set = true
            end

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
                    added = CardUtils.addItemToDeck({ voucher = true, ref = 'customVoucherList', addCard = self.config.center.key })
                elseif GUI.OpenStartingItemConfig.openItemType == 'joker' then
                    added = CardUtils.addItemToDeck({ joker = true, ref = 'customJokerList', addCard = { id = self.config.center.key, key = self.config.center.key, copies = GUI.OpenStartingItemConfig.copies, eternal = GUI.OpenStartingItemConfig.eternal, pinned = GUI.OpenStartingItemConfig.pinned, edition = GUI.OpenStartingItemConfig.edition, perishable = GUI.OpenStartingItemConfig.perishable, rental = GUI.OpenStartingItemConfig.rental } })
                elseif GUI.OpenStartingItemConfig.openItemType == 'tarot' then
                    added = CardUtils.addItemToDeck({ tarot = true, ref = 'customTarotList', addCard = { key = self.config.center.key, copies = GUI.OpenStartingItemConfig.copies, edition = GUI.OpenStartingItemConfig.edition }})
                elseif GUI.OpenStartingItemConfig.openItemType == 'planet' then
                    added = CardUtils.addItemToDeck({ planet = true, ref = 'customPlanetList', addCard = { key = self.config.center.key, copies = GUI.OpenStartingItemConfig.copies, edition = GUI.OpenStartingItemConfig.edition }})
                elseif GUI.OpenStartingItemConfig.openItemType == 'spectral' then
                    added = CardUtils.addItemToDeck({ spectral = true, ref = 'customSpectralList', addCard = { key = self.config.center.key, copies = GUI.OpenStartingItemConfig.copies, edition = GUI.OpenStartingItemConfig.edition }})
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
        elseif GUI.BannedItemsOpen then

            -- Banning item by clicking
            if GUI.OpenBannedItemConfig.openItemType ~= nil then
                local added = false
                if GUI.OpenBannedItemConfig.openItemType == 'voucher' then
                    added = CardUtils.banItem({ voucher = true, ref = 'bannedVoucherList', addCard = self.config.center.key})
                elseif GUI.OpenBannedItemConfig.openItemType == 'joker' then
                    added = CardUtils.banItem({ joker = true, ref = 'bannedJokerList', addCard = self.config.center.key})
                elseif GUI.OpenBannedItemConfig.openItemType == 'tarot' then
                    added = CardUtils.banItem({ tarot = true, ref = 'bannedTarotList', addCard = self.config.center.key})
                elseif GUI.OpenBannedItemConfig.openItemType == 'planet' then
                    added = CardUtils.banItem({ planet = true, ref = 'bannedPlanetList', addCard = self.config.center.key})
                elseif GUI.OpenBannedItemConfig.openItemType == 'spectral' then
                    added = CardUtils.banItem({ spectral = true, ref = 'bannedSpectralList', addCard = self.config.center.key})
                elseif GUI.OpenBannedItemConfig.openItemType == 'booster' then
                    added = CardUtils.banItem({ booster = true, ref = 'bannedBoosterList', addCard = self.config.center.key})
                end

                if added then
                    self:start_materialize(nil, true)
                    self:flip()
                end

            -- Unban individual item by clicking
            else
                if self.uuid and self.uuid.type == 'voucher' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedVoucherList) do
                        if v == self.uuid.key then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.bannedVoucherList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllBannedItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Banned Items[Vouchers]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'joker' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedJokerList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.bannedJokerList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllBannedItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Banned Items[Jokers]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'tarot' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedTarotList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.bannedTarotList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllBannedItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Banned Items[Tarots]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'planet' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedPlanetList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.bannedPlanetList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllBannedItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Banned Items[Planets]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'spectral' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedSpectralList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.bannedSpectralList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllBannedItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Banned Items[Spectrals]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
                    end
                elseif self.uuid and self.uuid.type == 'booster' then
                    local removeIndex
                    for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedBoosterList) do
                        if v.key == self.uuid.key and v.uuid == self.uuid.uuid then
                            removeIndex = k
                            break
                        end
                    end

                    if removeIndex then
                        table.remove(Utils.getCurrentEditingDeck().config.bannedBoosterList, removeIndex)
                    end

                    self:remove()

                    local memoryBefore = Utils.checkMemory()
                    GUI.updateAllBannedItemsAreas()

                    if Utils.runMemoryChecks then
                        local memoryAfter = collectgarbage("count")
                        local diff = memoryAfter - memoryBefore
                        Utils.log("MEMORY CHECK (UpdateDynamicAreas - Banned Items[Boosters]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
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
            if config.discard_cost and type(config.discard_cost == 'number') and config.discard_cost ~= 0 and config.discard_cost ~= nil then
                G.GAME.modifiers.discard_cost = config.discard_cost
            end
            G.GAME.modifiers.all_eternal = config.all_eternal
            G.GAME.modifiers.debuff_played_cards = config.debuff_played_cards
            G.GAME.edition_rate = config.edition_rate

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

            if G.GAME.stake >= 7 or (G.GAME.stake < 7 and config.enable_perishables_in_shop) then
                G.GAME.modifiers.enable_perishables_in_shop = true
            else
                G.GAME.modifiers.enable_perishables_in_shop = false
            end

            if G.GAME.stake >= 8 or (G.GAME.stake < 8 and config.enable_rentals_in_shop) then
                G.GAME.modifiers.enable_rentals_in_shop = true
            else
                G.GAME.modifiers.enable_rentals_in_shop = false
            end

            --[[if config.booster_ante_scaling and type(config.booster_ante_scaling == 'boolean') then
                if G.GAME.stake >= 7 or (G.GAME.stake < 7 and config.booster_ante_scaling) then
                    G.GAME.modifiers.booster_ante_scaling = true
                else
                    G.GAME.modifiers.booster_ante_scaling = false
                end
            end]]

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

            if config.negative_fifty_dollars_allowed then
                G.GAME.bankrupt_at = -50
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
            if self and self.effect and self.effect.config and self.effect.config.tag_on_win_config then
                for k,v in pairs(self.effect.config.tag_on_win_config) do
                    if v.chance > 0 then
                        local tagRoll = v.chance == 100 and 0 or math.random(1, 100)
                        if tagRoll <= v.chance then
                            G.E_MANAGER:add_event(Event({
                                func = (function()
                                    Utils.addTag(v.key)
                                    play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                                    play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                                    return true
                                end)
                            }))
                        end
                    end
                end
            end
        end


        if self.effect.config.balance_chips and args.context == 'blind_amount' then
            return
        end

        if args.context == 'final_scoring_step' then
            --[[if self.effect.config.chip_reduction_percent and self.effect.config.chip_reduction_percent > 0 and self.effect.config.chip_reduction_percent < 100 then
                Utils.log("Reducing chips by percentage: " .. tostring(self.effect.config.chip_reduction_percent) .. ', chips=' .. tostring(chips) .. ', args.chips=' .. tostring(args.chips))
                local mod = self.effect.config.chip_reduction_percent / 100
                local reduce = 1 - mod
                local chip = chips or args.chips
                chips = chip * reduce
                args.chips = chips
                Utils.log("Reduced chips by percentage: " .. Utils.tableToString({ mod = mod, reduce = reduce, chip = chip, chips = chips, argChips = args.chips }))
            end

            if self.effect.config.mult_reduction_percent and self.effect.config.mult_reduction_percent > 0 and self.effect.config.mult_reduction_percent < 100 then
                Utils.log("Reducing Mult by percentage: " .. tostring(self.effect.config.mult_reduction_percent))
                local mod = self.effect.config.mult_reduction_percent / 100
                local reduce = 1 - mod
                local mul = mult or args.mult
                mult = mul * reduce
                args.mult = mult
                Utils.log("Reduced Mult by percentage: " .. Utils.tableToString({ mod = mod, reduce = reduce, mul = mul, mult = mult, argMult = args.mult }))
            end]]

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
        Utils.configureEmptyBlind()
        local saveTable = args.savetext or nil
        local deck = self.GAME.viewed_back

        if deck and deck.effect and deck.effect.config and deck.effect.config.customDeck and not saveTable then
            sendTraceMessage("Setting starting items", "DeckCreatorLog")
            args = args or {}
            args.challenge = {}
            args.challenge.jokers = {}
            args.challenge.consumables = {}
            args.challenge.restrictions = {}
            args.challenge.restrictions.banned_cards = {}
            args.challenge.restrictions.banned_tags = {}
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
            for k,v in pairs(deck.effect.config.bannedJokerList) do
                table.insert(args.challenge.restrictions.banned_cards, {id = v.key })
            end
            for k,v in pairs(deck.effect.config.bannedTarotList) do
                table.insert(args.challenge.restrictions.banned_cards, {id = v.key })
            end
            for k,v in pairs(deck.effect.config.bannedPlanetList) do
                table.insert(args.challenge.restrictions.banned_cards, {id = v.key })
            end
            for k,v in pairs(deck.effect.config.bannedSpectralList) do
                table.insert(args.challenge.restrictions.banned_cards, {id = v.key })
            end
            for k,v in pairs(deck.effect.config.bannedBoosterList) do
                table.insert(args.challenge.restrictions.banned_cards, {id = v.key })
            end
            for k,v in pairs(deck.effect.config.bannedVoucherList) do
                table.insert(args.challenge.restrictions.banned_cards, {id = v })
            end
            for k,v in pairs(deck.effect.config.bannedTagList) do
                table.insert(args.challenge.restrictions.banned_tags, {id = v.key })
            end

            if G.GAME.stake < 6 and (deck.effect.config.blind_scaling == 2 or deck.effect.config.blind_scaling == 3) then
                G.GAME.modifiers.scaling = deck.effect.config.blind_scaling
            end

        end

        local originalResult = GameStartRun(self, args)

        -- re-set deck var after original function modifies
        -- theres a bug here, somewhere
        deck = self.GAME.selected_back

        if deck.effect.config.customDeck then
            args = args or {}
            args.challenge = args.challenge or {}
            args.challenge.consumables = args.challenge.consumables or {}
            if not saveTable then
                for k, v in ipairs(args.challenge.consumables) do
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            add_joker(v.id, v.edition, k ~= 1)
                            return true
                        end
                    }))
                end
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


            if not saveTable then
                if deck.effect.config.custom_cards_set then
                    sendTraceMessage("Playing custom deck", "DeckCreatorLog")
                    CardUtils.initializeCustomCardList(deck)
                else
                    sendTraceMessage("Playing normal deck", "DeckCreatorLog")
                    local config = deck.effect.config
                    local randomizeRanks = config.randomize_ranks
                    local randomizeSuits = config.randomize_suits
                    local noNumbered = config.no_numbered_cards
                    local noAces = config.no_aces
                    local poly = config.random_polychrome_cards
                    local holo = config.random_holographic_cards
                    local foil = config.random_foil_cards
                    local edition = config.random_edition_cards
                    local bonus = config.random_bonus_cards
                    local glass = config.random_glass_cards
                    local lucky = config.random_lucky_cards
                    local steel = config.random_steel_cards
                    local gold = config.random_gold_cards
                    local stone = config.random_stone_cards
                    local wild = config.random_wild_cards
                    local mult = config.random_mult_cards
                    local enhance = config.random_enhancement_cards
                    if randomizeRanks or randomizeSuits or noNumbered or noAces or poly > 0 or holo > 0 or foil > 0 or edition > 0 or bonus > 0 or glass > 0 or lucky > 0 or gold > 0 or steel > 0 or stone > 0 or wild > 0 or mult > 0 or enhance > 0 then
                        config.customCardList = CardUtils.standardCardSet()
                        CardUtils.initializeCustomCardList(deck)
                    end
                end
            end

            if deck.effect.config.multiply_probabilities ~= 1 then
                for k, v in pairs(G.GAME.probabilities) do
                    G.GAME.probabilities[k] = v * deck.effect.config.multiply_probabilities
                end
            end
            if deck.effect.config.divide_probabilities ~= 1 then
                for k, v in pairs(G.GAME.probabilities) do
                    G.GAME.probabilities[k] = v / deck.effect.config.divide_probabilities
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

            if not saveTable then
                for k,v in pairs(deck.effect.config.customTagList) do
                    Utils.addTag(v.key)
                end
            end
        end

        return originalResult
    end

    local MainMenu = Game.main_menu
    function Game:main_menu(change_context)
        MainMenu(self, change_context)
        G.P_BLINDS['bl_empty'] = nil
    end

    local GetNewBoss = get_new_boss
    function get_new_boss()
        local deck = G.GAME.selected_back
        if deck and deck.effect and deck.effect.config and deck.effect.config.customDeck and deck.effect.config.bannedBlindList and #deck.effect.config.bannedBlindList > 0 then
            G.GAME.perscribed_bosses = G.GAME.perscribed_bosses or {
            }
            if G.GAME.perscribed_bosses and G.GAME.perscribed_bosses[G.GAME.round_resets.ante] then
                local ret_boss = G.GAME.perscribed_bosses[G.GAME.round_resets.ante]
                G.GAME.perscribed_bosses[G.GAME.round_resets.ante] = nil
                G.GAME.bosses_used[ret_boss] = G.GAME.bosses_used[ret_boss] + 1
                return ret_boss
            end
            if G.FORCE_BOSS then
                return G.FORCE_BOSS
            end

            local eligible_bosses = {}
            local bossCount = 0
            for k, v in pairs(G.P_BLINDS) do

                local skip = false
                for x,y in pairs(deck.effect.config.bannedBlindList) do
                    if (y.key == v.name) then
                        skip = true
                        break
                    end
                end

                if not v.boss or skip or v.name == 'The Empty' then

                elseif not v.boss.showdown and (v.boss.min <= math.max(1, G.GAME.round_resets.ante) and ((math.max(1, G.GAME.round_resets.ante))%G.GAME.win_ante ~= 0 or G.GAME.round_resets.ante < 2)) then
                    eligible_bosses[k] = true
                    bossCount = bossCount + 1
                elseif v.boss.showdown and (G.GAME.round_resets.ante)%G.GAME.win_ante == 0 and G.GAME.round_resets.ante >= 2 then
                    eligible_bosses[k] = true
                    bossCount = bossCount + 1
                end
            end

            local min_use = 100
            for k, v in pairs(G.GAME.bosses_used) do
                if eligible_bosses[k] then
                    eligible_bosses[k] = v
                    if eligible_bosses[k] <= min_use then
                        min_use = eligible_bosses[k]
                    end
                end
            end
            for k, v in pairs(eligible_bosses) do
                if eligible_bosses[k] then
                    if eligible_bosses[k] > min_use then
                        eligible_bosses[k] = nil
                    end
                end
            end

            if bossCount < 1 then
                if G.P_BLINDS['bl_empty'] == nil then
                    Utils.configureEmptyBlind()
                end
                return "bl_empty"
            end

            local _, boss = pseudorandom_element(eligible_bosses, pseudoseed('boss'))
            G.GAME.bosses_used[boss] = G.GAME.bosses_used[boss] + 1
            return boss
        else
            local standardOutput = GetNewBoss()
            repeat
                standardOutput = GetNewBoss()
            until standardOutput ~= 'bl_empty'
            return standardOutput
        end
    end

    function create_UIBox_your_collection_blinds(exit)
        local blind_matrix = {
            {},{},{}, {}, {}, {}
        }
        local blind_tab = {}
        for k, v in pairs(G.P_BLINDS) do
            if v.name ~= 'The Empty' then
                blind_tab[#blind_tab+1] = v
            end
        end

        local blinds_per_row = math.ceil(#blind_tab/6)
        table.sort(blind_tab, function (a, b) return a.order < b.order end)

        local blinds_to_be_alerted = {}
        for k, v in ipairs(blind_tab) do
            local discovered = v.discovered
            local atlas = 'blind_chips'
            if v.atlas then
                atlas = v.atlas
            end
            local temp_blind = AnimatedSprite(0,0,1.3,1.3, G.ANIMATION_ATLAS[atlas], discovered and v.pos or G.b_undiscovered.pos)
            temp_blind:define_draw_steps({
                {shader = 'dissolve', shadow_height = 0.05},
                {shader = 'dissolve'}
            })
            if k == 1 then
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = (function()
                        G.CONTROLLER:snap_to{node = temp_blind}
                        return true
                    end)
                }))
            end
            temp_blind.float = true
            temp_blind.states.hover.can = true
            temp_blind.states.drag.can = false
            temp_blind.states.collide.can = true
            temp_blind.config = {blind = v, force_focus = true}
            if discovered and not v.alerted then
                blinds_to_be_alerted[#blinds_to_be_alerted+1] = temp_blind
            end
            temp_blind.hover = function()
                if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
                    if not temp_blind.hovering and temp_blind.states.visible then
                        temp_blind.hovering = true
                        temp_blind.hover_tilt = 3
                        temp_blind:juice_up(0.05, 0.02)
                        play_sound('chips1', math.random()*0.1 + 0.55, 0.12)
                        temp_blind.config.h_popup = create_UIBox_blind_popup(v, discovered)
                        temp_blind.config.h_popup_config ={align = 'cl', offset = {x=-0.1,y=0},parent = temp_blind}
                        Node.hover(temp_blind)
                        if temp_blind.children.alert then
                            temp_blind.children.alert:remove()
                            temp_blind.children.alert = nil
                            temp_blind.config.blind.alerted = true
                            G:save_progress()
                        end
                    end
                end
                temp_blind.stop_hover = function() temp_blind.hovering = false; Node.stop_hover(temp_blind); temp_blind.hover_tilt = 0 end
            end

            local row = math.ceil((k - 1) / blinds_per_row + 0.001)
            table.insert(blind_matrix[row], {
                n = G.UIT.C,
                config = { align = "cm", padding = 0.1 },
                nodes = {
                    ((k - blinds_per_row) % (2 * blinds_per_row) == 1) and { n = G.UIT.B, config = { h = 0.2, w = 0.5 } } or
                            nil,
                    { n = G.UIT.O, config = { object = temp_blind, focus_with_object = true } },
                    ((k - blinds_per_row) % (2 * blinds_per_row) == 0) and { n = G.UIT.B, config = { h = 0.2, w = 0.5 } } or
                            nil,
                }
            })
        end

        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = (function()
                for _, v in ipairs(blinds_to_be_alerted) do
                    v.children.alert = UIBox{
                        definition = create_UIBox_card_alert(),
                        config = { align="tri", offset = {x = 0.1, y = 0.1}, parent = v}
                    }
                    v.children.alert.states.collide.can = false
                end
                return true
            end)
        }))

        local ante_amounts = {}
        for i = 1, math.min(16, math.max(16, G.PROFILES[G.SETTINGS.profile].high_scores.furthest_ante.amt)) do
            local spacing = 1 - math.min(20, math.max(15, G.PROFILES[G.SETTINGS.profile].high_scores.furthest_ante.amt))*0.06
            if spacing > 0 and i > 1 then
                ante_amounts[#ante_amounts+1] = {n=G.UIT.R, config={minh = spacing}, nodes={}}
            end
            local blind_chip = Sprite(0,0,0.2,0.2,G.ASSET_ATLAS["ui_"..(G.SETTINGS.colourblind_option and 2 or 1)], {x=0, y=0})
            blind_chip.states.drag.can = false
            ante_amounts[#ante_amounts+1] = {n=G.UIT.R, config={align = "cm", padding = 0.03}, nodes={
                {n=G.UIT.C, config={align = "cm", minw = 0.7}, nodes={
                    {n=G.UIT.T, config={text = i, scale = 0.4, colour = G.C.FILTER, shadow = true}},
                }},
                {n=G.UIT.C, config={align = "cr", minw = 2.8}, nodes={
                    {n=G.UIT.O, config={object = blind_chip}},
                    {n=G.UIT.C, config={align = "cm", minw = 0.03, minh = 0.01}, nodes={}},
                    {n=G.UIT.T, config={text =number_format(get_blind_amount(i)), scale = 0.4, colour = i <= G.PROFILES[G.SETTINGS.profile].high_scores.furthest_ante.amt and G.C.RED or G.C.JOKER_GREY, shadow = true}},
                }}
            }}
        end

        local t = create_UIBox_generic_options({ back_func = exit or 'your_collection', contents = {
            {n=G.UIT.C, config={align = "cm", r = 0.1, colour = G.C.BLACK, padding = 0.1, emboss = 0.05}, nodes={
                {n=G.UIT.C, config={align = "cm", r = 0.1, colour = G.C.L_BLACK, padding = 0.1, force_focus = true, focus_args = {nav = 'tall'}}, nodes={
                    {n=G.UIT.R, config={align = "cm", padding = 0.05}, nodes={
                        {n=G.UIT.C, config={align = "cm", minw = 0.7}, nodes={
                            {n=G.UIT.T, config={text = localize('k_ante_cap'), scale = 0.4, colour = lighten(G.C.FILTER, 0.2), shadow = true}},
                        }},
                        {n=G.UIT.C, config={align = "cr", minw = 2.8}, nodes={
                            {n=G.UIT.T, config={text = localize('k_base_cap'), scale = 0.4, colour = lighten(G.C.RED, 0.2), shadow = true}},
                        }}
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes=ante_amounts}
                }},
                {n=G.UIT.C, config={align = "cm"}, nodes={
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        {n=G.UIT.R, config={align = "cm"}, nodes=blind_matrix[1]},
                        {n=G.UIT.R, config={align = "cm"}, nodes=blind_matrix[2]},
                        {n=G.UIT.R, config={align = "cm"}, nodes=blind_matrix[3]},
                        {n=G.UIT.R, config={align = "cm"}, nodes=blind_matrix[4]},
                        {n=G.UIT.R, config={align = "cm"}, nodes=blind_matrix[5]},
                        {n=G.UIT.R, config={align = "cm"}, nodes=blind_matrix[6]},
                    }}
                }}
            }}
        }})
        return t
    end

    local KeyPress = G.CONTROLLER.key_press
    function G.CONTROLLER:key_press(key)
        KeyPress(self, key)
        if key == 'escape' then
            GUI.CloseAllOpenFlags()
            GUI.ManageDecksConfig.manageDecksOpen = false
            GUI.addCard = GUI.resetAddCard()
        end
        if key == '`' and Utils.mode ~= 'PROD' then
            if G.DEBUG == true then G.DEBUG = false
            elseif G.DEBUG == false then G.DEBUG = true
            end
        end
    end

    local MouseClick = love.mousepressed
    function love.mousepressed(x, y, button, isTouch, presses)
        MouseClick(x, y, button, isTouch, presses)
        if Utils.hoveredTagBanItemsAddToBanKey ~= nil then
            local added = CardUtils.banItem({ tag = true, ref = 'bannedTagList', addCard = Utils.hoveredTagBanItemsAddToBanKey })
            if added and Utils.hoveredTagBanItemsAddToBanSprite ~= nil then
                Utils.hoveredTagBanItemsAddToBanSprite:juice_up()
            end
        elseif Utils.hoveredTagStartingItemsAddToItemsKey ~= nil then
            local added = CardUtils.addItemToDeck({ tag = true, ref = 'customTagList', addCard = { key = Utils.hoveredTagStartingItemsAddToItemsKey, copies = GUI.OpenStartingItemConfig.copies } })
            if added and Utils.hoveredTagStartingItemsAddToItemsSprite ~= nil then
                Utils.hoveredTagStartingItemsAddToItemsSprite:juice_up()
            end
        elseif Utils.hoveredBlindBanItemsAddToBanKey ~= nil then
            local added = CardUtils.banItem({ blind = true, ref = 'bannedBlindList', addCard = Utils.hoveredBlindBanItemsAddToBanKey })
            if added and Utils.hoveredBlindBanItemsAddToBanSprite ~= nil then
                Utils.hoveredBlindBanItemsAddToBanSprite:juice_up()
                Utils.hoveredBlindBanItemsAddToBanSprite.scale_mag = math.min(Utils.hoveredBlindBanItemsAddToBanSprite.scale.x/0.85,Utils.hoveredBlindBanItemsAddToBanSprite.scale.y/0.85)
                Utils.hoveredBlindBanItemsAddToBanSprite:set_sprite_pos(Utils.hoveredBlindBanItemsAddToBanSprite.config.pos)
            end
        elseif Utils.hoveredTagStartingItemsRemoveKey ~= nil and Utils.hoveredTagStartingItemsRemoveUUID ~= nil then
            local removeIndex
            for k,v in pairs(Utils.getCurrentEditingDeck().config.customTagList) do
                if v.key == Utils.hoveredTagStartingItemsRemoveKey and v.uuid == Utils.hoveredTagStartingItemsRemoveUUID then
                    removeIndex = k
                    break
                end
            end

            if removeIndex then
                table.remove(Utils.getCurrentEditingDeck().config.customTagList, removeIndex)
            end

            if Utils.hoveredTagStartingItemsRemoveSprite then
                Utils.hoveredTagStartingItemsRemoveSprite:remove()
            end

            local memoryBefore = Utils.checkMemory()
            GUI.updateAllStartingItemsAreas()
            Utils.hoveredTagStartingItemsRemoveKey = nil
            Utils.hoveredTagStartingItemsRemoveUUID = nil

            if Utils.runMemoryChecks then
                local memoryAfter = collectgarbage("count")
                local diff = memoryAfter - memoryBefore
                Utils.log("MEMORY CHECK (UpdateDynamicAreas - Starting Items[Tags]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
            end
        elseif Utils.hoveredTagBanItemsRemoveKey ~= nil then
            local removeIndex
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedTagList) do
                if v.key == Utils.hoveredTagBanItemsRemoveKey then
                    removeIndex = k
                    break
                end
            end

            if removeIndex then
                table.remove(Utils.getCurrentEditingDeck().config.bannedTagList, removeIndex)
            end

            if Utils.hoveredTagBanItemsRemoveSprite then
                Utils.hoveredTagBanItemsRemoveSprite:remove()
            end

            local memoryBefore = Utils.checkMemory()
            GUI.updateAllBannedItemsAreas()
            Utils.hoveredTagBanItemsRemoveKey = nil

            if Utils.runMemoryChecks then
                local memoryAfter = collectgarbage("count")
                local diff = memoryAfter - memoryBefore
                Utils.log("MEMORY CHECK (UpdateDynamicAreas - Banned Items[Tags]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
            end
        elseif Utils.hoveredBlindBanItemsRemoveKey ~= nil then
            local removeIndex
            for k,v in pairs(Utils.getCurrentEditingDeck().config.bannedBlindList) do
                if v.key == Utils.hoveredBlindBanItemsRemoveKey then
                    removeIndex = k
                    break
                end
            end

            if removeIndex then
                table.remove(Utils.getCurrentEditingDeck().config.bannedBlindList, removeIndex)
            end

            if Utils.hoveredBlindBanItemsRemoveSprite then
                Utils.hoveredBlindBanItemsRemoveSprite:remove()
            end

            local memoryBefore = Utils.checkMemory()
            GUI.updateAllBannedItemsAreas()
            Utils.hoveredBlindBanItemsRemoveKey = nil

            if Utils.runMemoryChecks then
                local memoryAfter = collectgarbage("count")
                local diff = memoryAfter - memoryBefore
                Utils.log("MEMORY CHECK (UpdateDynamicAreas - Banned Items[Blinds]): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
            end
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
