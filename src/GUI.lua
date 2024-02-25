local GUI = {}

local Persistence = require "Persistence"
local Utils = require "Utils"
local CustomDeck = require "CustomDeck"

local Selected = resetSelected()

function resetSelected()
    return {
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
end

function GUI.registerGlobals()
    G.FUNCS.DeckEditModuleOpenGithub = function()
        love.system.openURL("https://github.com/adambennett/Balatro-DeckEditModule")
    end

    G.FUNCS.DeckCreatorModuleChangeEditionCount = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.edition_count = args.to_val
        Selected.edition_count = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeJokerSlots = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.joker_slot = args.to_val
        Selected.joker_slot = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeConsumableSlots = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.consumable_slot = args.to_val
        Selected.consumable_slot = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeAnteScaling = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.ante_scaling = args.to_val
        Selected.ante_scaling = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeSpectralRate = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.spectral_rate = args.to_val
        Selected.spectral_rate = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeDollars = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.dollars = args.to_val
        Selected.dollars = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeDollarsPerHand = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.extra_hand_bonus = args.to_val
        Selected.extra_hand_bonus = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeDollarsPerDiscard = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.extra_discard_bonus = args.to_val
        Selected.extra_discard_bonus = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeRerollCost = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.reroll_cost = args.to_val
        Selected.reroll_cost = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeRerollDiscount = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.reroll_discount = args.to_val
        Selected.reroll_discount = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeNumHands = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.hands = args.to_val
        Selected.hands = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeNumDiscards = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.discards = args.to_val
        Selected.discards = args.to_val + 1
    end

    G.FUNCS.DeckCreatorModuleChangeHandSize = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.hand_size = args.to_val
        Selected.hand_size = args.to_val
    end

    G.FUNCS.DeckEditModuleOpenCreateDeck = function()
        G.SETTINGS.paused = true

        Selected = resetSelected()
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

        local newDeck = CustomDeck:fullNew(
                Utils.customDeckList[#Utils.customDeckList].name,
                Utils.customDeckList[#Utils.customDeckList].name,
                {x = 1, y = 3},
                {name = Utils.customDeckList[#Utils.customDeckList].name, text = {
                    [1] = desc1, [2] = desc2, [3] = desc3, [4] = desc4
                }},
                Utils.customDeckList[#Utils.customDeckList].config.dollars,
                Utils.customDeckList[#Utils.customDeckList].config.hand_size,
                Utils.customDeckList[#Utils.customDeckList].config.discards,
                Utils.customDeckList[#Utils.customDeckList].config.hands,
                Utils.customDeckList[#Utils.customDeckList].config.reroll_cost,
                Utils.customDeckList[#Utils.customDeckList].config.reroll_discount,
                Utils.customDeckList[#Utils.customDeckList].config.joker_slot,
                Utils.customDeckList[#Utils.customDeckList].config.ante_scaling,
                Utils.customDeckList[#Utils.customDeckList].config.consumable_slot,
                Utils.customDeckList[#Utils.customDeckList].config.extra_hand_bonus,
                Utils.customDeckList[#Utils.customDeckList].config.extra_discard_bonus,
                Utils.customDeckList[#Utils.customDeckList].config.spectral_rate,
                Utils.customDeckList[#Utils.customDeckList].config.randomize_rank_suit,
                Utils.customDeckList[#Utils.customDeckList].config.remove_faces,
                Utils.customDeckList[#Utils.customDeckList].config.no_interest,
                Utils.customDeckList[#Utils.customDeckList].config.edition,
                Utils.customDeckList[#Utils.customDeckList].config.double_tag,
                Utils.customDeckList[#Utils.customDeckList].config.balance_chips,
                Utils.customDeckList[#Utils.customDeckList].config.edition_count)

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

                                            -- Description Line 1
                                            --[[{
                                                n = G.UIT.R,
                                                config = {
                                                    padding = 0.3,
                                                    align = "cm",
                                                    minw = 4  -- Adjust the width as needed
                                                },
                                                nodes = {
                                                    create_text_input({
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
                                                    create_text_input({
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
                                                    create_text_input({
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
                                                    create_text_input({
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
                                            minw = 6,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            create_option_cycle({label = "Joker Slots", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeJokerSlots', current_option = (
                                                    Selected.joker_slot or 6
                                            )}),
                                            create_option_cycle({label = "Consumable Slots", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeConsumableSlots', current_option = (
                                                    Selected.consumable_slot or 3
                                            )}),
                                            create_option_cycle({label = "Ante Scaling", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeAnteScaling', current_option = (
                                                    Selected.ante_scaling or 2
                                            )}),
                                            create_option_cycle({label = "Spectral Rate", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeSpectralRate', current_option = (
                                                    Selected.spectral_rate or 2
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
                                            minw = 6,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            create_option_cycle({label = "Starting Dollars", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeDollars', current_option = (
                                                    Selected.dollars or 5
                                            )}),
                                            create_option_cycle({label = "Dollars per Hand", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeDollarsPerHand', current_option = (
                                                    Selected.extra_hand_bonus or 2
                                            )}),
                                            create_option_cycle({label = "Dollars per Discard", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeDollarsPerDiscard', current_option = (
                                                    Selected.extra_discard_bonus or 1
                                            )}),
                                            create_option_cycle({label = "Reroll Cost", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeRerollCost', current_option = (
                                                    Selected.reroll_cost or 6
                                            )}),
                                            create_option_cycle({label = "Reroll Discount", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeRerollDiscount', current_option = (
                                                    Selected.reroll_discount or 1
                                            )}),
                                            create_toggle({label = "No Interest", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'no_interest'})
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
                                            minw = 6,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            create_option_cycle({label = "# of Hands", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 10), opt_callback = 'DeckCreatorModuleChangeNumHands', current_option = (
                                                    Selected.hands or 5
                                            )}),
                                            create_option_cycle({label = "# of Discards", scale = 0.8, options = Utils.generateIntegerList(), opt_callback = 'DeckCreatorModuleChangeNumDiscards', current_option = (
                                                    Selected.discards or 4
                                            )}),
                                            create_option_cycle({label = "Hand Size", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 10), opt_callback = 'DeckCreatorModuleChangeHandSize', current_option = (
                                                    Selected.hand_size or 8
                                            )}),
                                        }
                                    }
                                end
                            },
                            {

                                label = " Flags ",
                                tab_definition_function = function()
                                    return {
                                        n = G.UIT.ROOT,
                                        config = {
                                            emboss = 0.05,
                                            minh = 6,
                                            r = 0.1,
                                            minw = 6,
                                            align = "cm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = {
                                            create_toggle({label = "Edition", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'edition'}),
                                            create_option_cycle({label = "Edition Count", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 10), opt_callback = 'DeckCreatorModuleChangeEditionCount', current_option = (
                                                    Selected.edition_count or 1
                                            )}),
                                            create_toggle({label = "No Face Cards", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'remove_faces'}),
                                            create_toggle({label = "Randomize Ranks and Suits", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomize_rank_suit'}),
                                            create_toggle({label = "Double Tag on Boss Win", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'double_tag'}),
                                            create_toggle({label = "Balance Chips and Mult", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'balance_chips'}),
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
