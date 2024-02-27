local Persistence = require "Persistence"
local GUI = require "GUI"
local Helper = require "GuiElementHelper"
local Utils = require "Utils"
local CardUtils = require "CardUtils"

local DeckCreator = {}

function DeckCreator.LoadCustomDecks()
    GUI.registerGlobals()
    GUI.registerCreateDeckButton()
    Helper.registerGlobals()
    Persistence.loadAllDeckLists()

    G.FUNCS.LogDebug = function(message)
        Utils.log(message)
    end

    G.FUNCS.LogTableToString = function(table)
        Utils.log(Utils.tableToString(table))
    end

    local BackApply_to_runRef = Back.apply_to_run
    function Back.apply_to_run(arg)
        BackApply_to_runRef(arg)

        if arg.effect.config.customDeck then

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
        end

        return originalResult
    end
end

return DeckCreator
