local GUI = {}

local Persistence = require "Persistence"
local Utils = require "Utils"
local CustomDeck = require "CustomDeck"
local Helper = require "GuiElementHelper"

function GUI.registerGlobals()
    G.FUNCS.DeckEditModuleOpenGithub = function()
        love.system.openURL("https://github.com/adambennett/Balatro-DeckCreator")
    end

    G.FUNCS.DeckCreatorModuleChangeDiscardCost = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.discard_cost = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDiscountPercent = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.discount_percent = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeShopSlots = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.shop_slots = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeInterestCap = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.interest_cap = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeInterestAmount = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.interest_amount = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeWinAnte = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.win_ante = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDeckBackIndex = function(args)
        local current_option_index = 1
        for i, option in ipairs(CustomDeck.getAllDeckBackNames()) do
            if option == args.to_val then
                current_option_index = i
                break
            end
        end
        Utils.customDeckList[#Utils.customDeckList].config.deck_back_index = current_option_index
    end

    G.FUNCS.DeckCreatorModuleChangeEditionCount = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.edition_count = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeJokerSlots = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.joker_slot = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeConsumableSlots = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.consumable_slot = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeAnteScaling = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.ante_scaling = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeJokerRate = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.joker_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeTarotRate = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.tarot_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangePlanetRate = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.planet_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeSpectralRate = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.spectral_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangePlayingCardRate = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.playing_card_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDollars = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.dollars = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDollarsPerHand = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.extra_hand_bonus = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDollarsPerDiscard = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.extra_discard_bonus = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeRerollCost = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.reroll_cost = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeNumHands = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.hands = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeNumDiscards = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.discards = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeHandSize = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.hand_size = args.to_val
    end

    G.FUNCS.DeckEditModuleOpenCreateDeck = function()
        G.SETTINGS.paused = true

        Utils.addDeckToList(CustomDeck:blankDeck())

        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu()
        })
    end

    G.FUNCS.DeckEditModuleSaveDeck = function()

        local desc1 = Utils.customDeckList[#Utils.customDeckList].descLine1
        local desc2 = Utils.customDeckList[#Utils.customDeckList].descLine2
        local desc3 = Utils.customDeckList[#Utils.customDeckList].descLine3
        local desc4 = Utils.customDeckList[#Utils.customDeckList].descLine4

        if desc1 == "" and desc2 == "" and desc3 == "" and desc4 == "" then
            desc1 = "Custom Deck"
            desc2 = "created at"
            desc3 = "{C:attention}" .. Utils.timestamp() .. "{}"
        end

        local newDeck = CustomDeck:fullNew(
                Utils.customDeckList[#Utils.customDeckList].name,
                Utils.customDeckList[#Utils.customDeckList].name,
                {name = Utils.customDeckList[#Utils.customDeckList].name, text = {
                    [1] = desc1, [2] = desc2, [3] = desc3, [4] = desc4
                }},
                Utils.customDeckList[#Utils.customDeckList].config.dollars,
                Utils.customDeckList[#Utils.customDeckList].config.hand_size,
                Utils.customDeckList[#Utils.customDeckList].config.discards,
                Utils.customDeckList[#Utils.customDeckList].config.hands,
                Utils.customDeckList[#Utils.customDeckList].config.reroll_cost,
                Utils.customDeckList[#Utils.customDeckList].config.joker_slot,
                Utils.customDeckList[#Utils.customDeckList].config.ante_scaling,
                Utils.customDeckList[#Utils.customDeckList].config.consumable_slot,
                Utils.customDeckList[#Utils.customDeckList].config.extra_hand_bonus,
                Utils.customDeckList[#Utils.customDeckList].config.extra_discard_bonus,
                Utils.customDeckList[#Utils.customDeckList].config.joker_rate,
                Utils.customDeckList[#Utils.customDeckList].config.tarot_rate,
                Utils.customDeckList[#Utils.customDeckList].config.planet_rate,
                Utils.customDeckList[#Utils.customDeckList].config.spectral_rate,
                Utils.customDeckList[#Utils.customDeckList].config.playing_card_rate,
                Utils.customDeckList[#Utils.customDeckList].config.randomize_rank_suit,
                Utils.customDeckList[#Utils.customDeckList].config.remove_faces,
                Utils.customDeckList[#Utils.customDeckList].config.interest_amount,
                Utils.customDeckList[#Utils.customDeckList].config.interest_cap,
                Utils.customDeckList[#Utils.customDeckList].config.discount_percent,
                Utils.customDeckList[#Utils.customDeckList].config.edition,
                Utils.customDeckList[#Utils.customDeckList].config.double_tag,
                Utils.customDeckList[#Utils.customDeckList].config.balance_chips,
                Utils.customDeckList[#Utils.customDeckList].config.edition_count,
                Utils.customDeckList[#Utils.customDeckList].config.deck_back_index,
                Utils.customDeckList[#Utils.customDeckList].config.win_ante,
                Utils.customDeckList[#Utils.customDeckList].config.inflation,
                Utils.customDeckList[#Utils.customDeckList].config.shop_slots,
                Utils.customDeckList[#Utils.customDeckList].config.all_polychrome,
                Utils.customDeckList[#Utils.customDeckList].config.all_holo,
                Utils.customDeckList[#Utils.customDeckList].config.all_foil,
                Utils.customDeckList[#Utils.customDeckList].config.all_bonus,
                Utils.customDeckList[#Utils.customDeckList].config.all_mult,
                Utils.customDeckList[#Utils.customDeckList].config.all_wild,
                Utils.customDeckList[#Utils.customDeckList].config.all_glass,
                Utils.customDeckList[#Utils.customDeckList].config.all_steel,
                Utils.customDeckList[#Utils.customDeckList].config.all_stone,
                Utils.customDeckList[#Utils.customDeckList].config.all_gold,
                Utils.customDeckList[#Utils.customDeckList].config.all_lucky,
                Utils.customDeckList[#Utils.customDeckList].config.enable_eternals_in_shop,
                Utils.customDeckList[#Utils.customDeckList].config.booster_ante_scaling,
                Utils.customDeckList[#Utils.customDeckList].config.chips_dollar_cap,
                Utils.customDeckList[#Utils.customDeckList].config.discard_cost,
                Utils.customDeckList[#Utils.customDeckList].config.minus_hand_size_per_X_dollar,
                Utils.customDeckList[#Utils.customDeckList].config.all_eternal,
                Utils.customDeckList[#Utils.customDeckList].config.debuff_played_cards,
                Utils.customDeckList[#Utils.customDeckList].config.flipped_cards
        )

        Utils.customDeckList[#Utils.customDeckList] = newDeck
        Utils.customDeckList[#Utils.customDeckList]:register()

        SMODS.injectDecks()

        Persistence.saveAllDecks()

        G.FUNCS:exit_overlay_menu()
    end
end

function GUI.registerCreateDeckButton()
    SMODS.registerUIElement("DeckCreatorModule", {{
         n = G.UIT.R,
         config = {
             padding = 0.5,
             align = "cm"
         },
         nodes = {
             UIBox_button({
                 label = {" Create Deck "},
                 shadow = true,
                 scale = scale,
                 colour = G.C.BOOSTER,
                 button = "DeckEditModuleOpenCreateDeck",
                 minh = 0.8,
                 minw = 8
             })
         }
    }})
end

function GUI.createDecksMenu()
    return (create_UIBox_generic_options({
        back_func = "mods_button",
        contents = {
            {
                n = G.UIT.R,
                config = {
                    padding = 0,
                    align = "cm"
                },
                nodes = {
                    create_tabs({
                        snap_to_nav = true,
                        colour = G.C.BOOSTER,
                        tabs = {
                            {
                                label = " Main Menu ",
                                chosen = true,
                                tab_definition_function = function()
                                    local modNodes = {}

                                    table.insert(modNodes, {
                                        n = G.UIT.R,
                                        config = {
                                            align = 'cm',
                                            padding = 0.1,
                                            minh = 0.8
                                        },
                                        nodes = {
                                            -- Deck Name
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    align = "cm",
                                                    minw = 4  -- Adjust the width as needed
                                                },
                                                nodes = {
                                                    create_text_input({
                                                        -- id = "deckName",
                                                        w = 4,  -- Width of the text input
                                                        max_length = 25,  -- Max length of deck name
                                                        prompt_text = "Custom Deck",  -- Prompt text for input
                                                        ref_table = Utils.customDeckList[#Utils.customDeckList],  -- Table to store the inputted value
                                                        ref_value = 'name',  -- Key in ref_table where input is stored
                                                        extended_corpus = true,
                                                        keyboard_offset = 1,
                                                        callback = function(val) end
                                                    }),
                                                }
                                            },
                                            Helper.createOptionSelector({label = "Card Back", scale = 0.8, options = CustomDeck.getAllDeckBackNames(), opt_callback = 'DeckCreatorModuleChangeDeckBackIndex', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.deck_back_index
                                            )}),
                                            Helper.createOptionSelector({label = "Winning Ante", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 50), opt_callback = 'DeckCreatorModuleChangeWinAnte', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.win_ante
                                            ), multiArrows = true}),

                                            -- Description Line 1
                                            --[[{
                                                n = G.UIT.R,
                                                config = {
                                                    padding = 0.3,
                                                    align = "cm",
                                                    minw = 4  -- Adjust the width as needed
                                                },
                                                nodes = {
                                                    Helper.createTextInput({
                                                        id = "desc1",
                                                        w = 4,  -- Width of the text input
                                                        max_length = 25,  -- Max length of deck name
                                                        prompt_text = "Description line 1",  -- Prompt text for input
                                                        ref_table = Utils.customDeckList[#Utils.customDeckList],  -- Table to store the inputted value
                                                        ref_value = 'descLine1',  -- Key in ref_table where input is stored
                                                        extended_corpus = true,
                                                        keyboard_offset = 2,
                                                        callback = function(val) end
                                                    }),
                                                }
                                            },

                                            -- Description Line 2
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    padding = 0.3,
                                                    align = "cm",
                                                    minw = 4  -- Adjust the width as needed
                                                },
                                                nodes = {
                                                    Helper.createTextInput({
                                                        id = "desc2",
                                                        w = 4,  -- Width of the text input
                                                        max_length = 25,  -- Max length of deck name
                                                        prompt_text = "Description line 2",  -- Prompt text for input
                                                        ref_table = Utils.customDeckList[#Utils.customDeckList],  -- Table to store the inputted value
                                                        ref_value = 'descLine2',  -- Key in ref_table where input is stored
                                                        extended_corpus = true,
                                                        keyboard_offset = 3,
                                                        callback = function(val) end
                                                    }),
                                                }
                                            },

                                            -- Description Line 3
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    padding = 0.3,
                                                    align = "cm",
                                                    minw = 4  -- Adjust the width as needed
                                                },
                                                nodes = {
                                                    Helper.createTextInput({
                                                        id = "desc3",
                                                        w = 4,  -- Width of the text input
                                                        max_length = 25,  -- Max length of deck name
                                                        prompt_text = "Description line 3",  -- Prompt text for input
                                                        ref_table = Utils.customDeckList[#Utils.customDeckList],  -- Table to store the inputted value
                                                        ref_value = 'descLine3',  -- Key in ref_table where input is stored
                                                        extended_corpus = true,
                                                        keyboard_offset = 4,
                                                        callback = function(val) end
                                                    }),
                                                }
                                            },

                                            -- Description Line 4
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    padding = 0.3,
                                                    align = "cm",
                                                    minw = 4  -- Adjust the width as needed
                                                },
                                                nodes = {
                                                    Helper.createTextInput({
                                                        id = "desc4",
                                                        w = 4,  -- Width of the text input
                                                        max_length = 25,  -- Max length of deck name
                                                        prompt_text = "Description line 4",  -- Prompt text for input
                                                        ref_table = Utils.customDeckList[#Utils.customDeckList],  -- Table to store the inputted value
                                                        ref_value = 'descLine4',  -- Key in ref_table where input is stored
                                                        extended_corpus = true,
                                                        keyboard_offset = 5,
                                                        callback = function(val) end
                                                    }),
                                                }
                                            },]]

                                            -- Save Deck
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    padding = 0.3,
                                                    align = "cm"
                                                },
                                                nodes = {
                                                    UIBox_button({
                                                        label = {" Save Deck "},
                                                        shadow = true,
                                                        scale = scale,
                                                        colour = G.C.BOOSTER,
                                                        button = "DeckEditModuleSaveDeck",
                                                        minh = 0.8,
                                                        minw = 8
                                                    })
                                                }
                                            }
                                        }
                                    })

                                    return {
                                        n = G.UIT.ROOT,
                                        config = {
                                            emboss = 0.05,
                                            minh = 6,
                                            r = 0.1,
                                            minw = 10,
                                            align = "tm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = {
                                                    r = 0.1,
                                                    align = "cm",
                                                    padding = 0.2,
                                                },
                                                nodes = modNodes
                                            }
                                        }
                                    }
                                end
                            },
                            {

                                label = " General ",
                                tab_definition_function = function()
                                    return {
                                        n = G.UIT.ROOT,
                                        config = {
                                            emboss = 0.05,
                                            minh = 6,
                                            r = 0.1,
                                            minw = 10,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            Helper.createOptionSelector({label = "Joker Slots", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeJokerSlots', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.joker_slot
                                            ), multiArrows = true }),
                                            Helper.createOptionSelector({label = "Consumable Slots", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeConsumableSlots', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.consumable_slot
                                            ), multiArrows = true }),
                                            Helper.createOptionSelector({label = "Ante Scaling", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 3), opt_callback = 'DeckCreatorModuleChangeAnteScaling', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.ante_scaling
                                            )}),
                                            Helper.createOptionSelector({label = "Shop Slots", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 5), opt_callback = 'DeckCreatorModuleChangeShopSlots', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.shop_slots
                                            )})
                                        }
                                    }
                                end
                            },
                            {

                                label = " Money ",
                                tab_definition_function = function()
                                    return {
                                        n = G.UIT.ROOT,
                                        config = {
                                            emboss = 0.05,
                                            minh = 6,
                                            r = 0.1,
                                            minw = 16,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            {
                                              n = G.UIT.C,
                                              config = { align = "cm", minw = 3, padding = 0.2, r = 0.1, colour = G.C.CLEAR },
                                              nodes = {
                                                  {
                                                      n = G.UIT.R,
                                                      config = {
                                                          align = "cm",
                                                          padding = 0.1
                                                      },
                                                      nodes = {
                                                          Helper.createOptionSelector({label = "Starting Dollars", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeDollars', current_option = (
                                                                  Utils.customDeckList[#Utils.customDeckList].config.dollars
                                                          ), multiArrows = true })
                                                      }
                                                  },
                                                  {
                                                      n = G.UIT.R,
                                                      config = {
                                                          align = "cm",
                                                          padding = 0.1
                                                      },
                                                      nodes = {
                                                          Helper.createOptionSelector({label = "Dollars per Hand", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeDollarsPerHand', current_option = (
                                                                  Utils.customDeckList[#Utils.customDeckList].config.extra_hand_bonus
                                                          ), multiArrows = true }),
                                                      }
                                                  },
                                                  {
                                                      n = G.UIT.R,
                                                      config = {
                                                          align = "cm",
                                                          padding = 0.1
                                                      },
                                                      nodes = {
                                                          Helper.createOptionSelector({label = "Interest Amount", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeInterestAmount', current_option = (
                                                                  Utils.customDeckList[#Utils.customDeckList].config.interest_amount
                                                          ), multiArrows = true }),
                                                      }
                                                  },
                                                  {
                                                      n = G.UIT.R,
                                                      config = {
                                                          align = "cm",
                                                          padding = 0.1
                                                      },
                                                      nodes = {
                                                          Helper.createOptionSelector({label = "Discount Percent", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeInterestCap', current_option = (
                                                                  Utils.customDeckList[#Utils.customDeckList].config.discount_percent
                                                          ), multiArrows = true }),
                                                      }
                                                  },
                                              }
                                            },
                                            {
                                                n = G.UIT.C,
                                                config = { align = "cm", minw = 3, padding = 0.2, r = 0.1, colour = G.C.CLEAR },
                                                nodes = {
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            Helper.createOptionSelector({label = "Reroll Cost", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRerollCost', current_option = (
                                                                    Utils.customDeckList[#Utils.customDeckList].config.reroll_cost
                                                            ), multiArrows = true }),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            Helper.createOptionSelector({label = "Dollars per Discard", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeDollarsPerDiscard', current_option = (
                                                                    Utils.customDeckList[#Utils.customDeckList].config.extra_discard_bonus
                                                            ), multiArrows = true }),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            Helper.createOptionSelector({label = "Interest Cap", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeInterestCap', current_option = (
                                                                    Utils.customDeckList[#Utils.customDeckList].config.interest_cap
                                                            ), multiArrows = true }),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            Helper.createOptionSelector({label = "Discard Cost", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeDiscardCost', current_option = (
                                                                    Utils.customDeckList[#Utils.customDeckList].config.discard_cost
                                                            ), multiArrows = true }),
                                                        }
                                                    },
                                                }
                                            }
                                        }
                                    }
                                end
                            },
                            {

                                label = " Hands & Discards ",
                                tab_definition_function = function()
                                    return {
                                        n = G.UIT.ROOT,
                                        config = {
                                            emboss = 0.05,
                                            minh = 6,
                                            r = 0.1,
                                            minw = 10,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            Helper.createOptionSelector({label = "Number of Hands", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeNumHands', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.hands
                                            ), multiArrows = true}),
                                            Helper.createOptionSelector({label = "Number of Discards", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeNumDiscards', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.discards
                                            ), multiArrows = true }),
                                            Helper.createOptionSelector({label = "Hand Size", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 25), opt_callback = 'DeckCreatorModuleChangeHandSize', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.hand_size
                                            )}),
                                        }
                                    }
                                end
                            },
                            {

                                label = " Appearance Rates ",
                                tab_definition_function = function()
                                    return {
                                        n = G.UIT.ROOT,
                                        config = {
                                            emboss = 0.05,
                                            minh = 6,
                                            r = 0.1,
                                            minw = 10,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            Helper.createOptionSelector({label = "Joker Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeJokerRate', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.joker_rate
                                            ), multiArrows = true }),
                                            Helper.createOptionSelector({label = "Tarot Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeTarotRate', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.tarot_rate
                                            ), multiArrows = true }),
                                            Helper.createOptionSelector({label = "Planet Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangePlanetRate', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.planet_rate
                                            ), multiArrows = true }),
                                            Helper.createOptionSelector({label = "Spectral Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeSpectralRate', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.spectral_rate
                                            ), multiArrows = true }),
                                            Helper.createOptionSelector({label = "Playing Card Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangePlayingCardRate', current_option = (
                                                    Utils.customDeckList[#Utils.customDeckList].config.playing_card_rate
                                            ), multiArrows = true })
                                        }
                                    }
                                end
                            },
                            {

                                label = " Gameplay ",
                                tab_definition_function = function()
                                    return {
                                        n = G.UIT.ROOT,
                                        config = {
                                            emboss = 0.05,
                                            minh = 6,
                                            r = 0.1,
                                            minw = 10,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            create_toggle({label = "Double Tag on Boss win", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'double_tag'}),
                                            create_toggle({label = "Balance Chips and Mult", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'balance_chips'}),
                                            create_toggle({label = "All Jokers Eternal", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_eternal'}),
                                            create_toggle({label = "Eternal Jokers appear in shop", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'enable_eternals_in_shop'}),
                                            create_toggle({label = "Boosters cost $1 more per Ante", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'booster_ante_scaling'}),
                                            create_toggle({label = "Chips cannot exceed current $", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'chips_dollar_cap'}),
                                            create_toggle({label = "Hold -1 cards in hand per $5", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'minus_hand_size_per_X_dollar'}),
                                            create_toggle({label = "Raise prices by $1 on every purchase", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'inflation'}),
                                            create_toggle({label = "1 in 4 cards are drawn face down", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'flipped_cards'}),
                                            create_toggle({label = "All played cards become debuffed after scoring", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'debuff_played_cards'}),
                                        }
                                    }
                                end
                            },
                            {

                                label = " Deck Mods ",
                                tab_definition_function = function()
                                    return {
                                        n = G.UIT.ROOT,
                                        config = {
                                            emboss = 0.05,
                                            minh = 6,
                                            r = 0.1,
                                            minw = 10,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.C,
                                                config = { align = "cm", minw = 3, padding = 0.2, r = 0.1, colour = G.C.CLEAR },
                                                nodes = {
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "No Face Cards", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'remove_faces'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Polychrome", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_polychrome'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Foil", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_foil'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Mult", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_mult'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Glass", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_glass'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Stone", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_stone'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Lucky", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_lucky'}),
                                                        }
                                                    },
                                                }
                                            },
                                            {
                                                n = G.UIT.C,
                                                config = { align = "cm", minw = 3, padding = 0.2, r = 0.1, colour = G.C.CLEAR },
                                                nodes = {
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "Randomize Ranks and Suits", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomize_rank_suit'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Holo", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_holo'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Bonus", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_bonus'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Wild", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_wild'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Steel", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_steel'}),
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1
                                                        },
                                                        nodes = {
                                                            create_toggle({label = "All Cards Gold", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_gold'}),
                                                        }
                                                    },
                                                }
                                            },
                                        }
                                    }
                                end
                            }
                        }
                    })
                }
            }
        }
    }))
end

return GUI
