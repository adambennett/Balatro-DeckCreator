local Persistence = require "Persistence"
local Utils = require "Utils"
local CustomDeck = require "CustomDeck"
local Helper = require "GuiElementHelper"
local CardUtils = require "CardUtils"

local GUI = {}

function GUI.registerGlobals()
    G.FUNCS.DeckCreatorModuleOpenGithub = function()
        love.system.openURL("https://github.com/adambennett/Balatro-DeckCreator")
    end

    G.FUNCS.DeckCreatorModuleAddCard = function()

        local newCardName = GUI.addCard.rank .. " of " .. GUI.addCard.suit
        local rank = GUI.addCard.rank
        if rank == 10 then rank = "T" end
        local key = GUI.addCard.suitKey .. "_" .. rank
        local newCard = {
            name = newCardName ,
            value = GUI.addCard.rank,
            suit = GUI.addCard.suit,
            pos = {x=0,y=1},
            edition = GUI.addCard.edition,
            editionKey = GUI.addCard.editionKey,
            enhancement = GUI.addCard.enhancement,
            enhancementKey = GUI.addCard.enhancementKey,
            seal = GUI.addCard.seal
        }

        local counter = 1
        for i = 1, GUI.addCard.copies do
            if Utils.customDeckList[#Utils.customDeckList].config.customCardList[key] == nil then
                Utils.customDeckList[#Utils.customDeckList].config.customCardList[key] = newCard
            else
                while Utils.customDeckList[#Utils.customDeckList].config.customCardList[key .. "_" .. counter] ~= nil do
                    counter = counter + 1
                end
                Utils.customDeckList[#Utils.customDeckList].config.customCardList[key .. "_" .. counter] = newCard
            end
        end

        Utils.customDeckList[#Utils.customDeckList].config.custom_cards_set = true
        G.FUNCS:exit_overlay_menu()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Base Deck")
        })
    end

    G.FUNCS.DeckCreatorModuleOpenAddCardToDeck = function ()
        G.FUNCS:exit_overlay_menu()
        G.FUNCS.overlay_menu({
            definition = GUI.createAddCardsMenu()
        })
    end

    G.FUNCS.DeckCreatorModuleDeleteAllCardsFromBaseDeck = function()
        Utils.customDeckList[#Utils.customDeckList].config.customCardList = {}
        Utils.customDeckList[#Utils.customDeckList].config.custom_cards_set = true
        G.FUNCS:exit_overlay_menu()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Base Deck")
        })
    end

    G.FUNCS.DeckCreatorModuleAddCardChangeRank = function(args)
        GUI.addCard.rank = args.to_val
    end
    G.FUNCS.DeckCreatorModuleAddCardChangeSuit = function(args)
        GUI.addCard.suit = args.to_val
        GUI.addCard.suitKey = string.sub(args.to_val, 1, 1)
    end
    G.FUNCS.DeckCreatorModuleAddCardChangeEdition = function(args)
        GUI.addCard.edition = args.to_val
        GUI.addCard.editionKey = string.lower(args.to_val)
    end
    G.FUNCS.DeckCreatorModuleAddCardChangeEnhancement = function(args)
        GUI.addCard.enhancement = args.to_val
        GUI.addCard.enhancementKey = "m_" .. string.lower(args.to_val)
    end
    G.FUNCS.DeckCreatorModuleAddCardChangeSeal = function(args)
        GUI.addCard.seal = args.to_val
    end
    G.FUNCS.DeckCreatorModuleAddCardChangeCopies = function(args)
        GUI.addCard.copies = args.to_val
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

    G.FUNCS.DeckCreatorModuleBackToModsScreen = function()
        CardUtils.resetToMainMenuState()
        G.FUNCS.mods_button()
    end

    G.FUNCS.DeckCreatorModuleOpenCreateDeck = function()
        G.SETTINGS.paused = true

        Utils.addDeckToList(CustomDeck:blankDeck())

        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Main Menu")
        })
    end

    G.FUNCS.DeckCreatorModuleReopenBaseDeck = function()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Base Deck")
        })
    end

    G.FUNCS.DeckCreatorModuleSaveDeck = function()

        Utils.log("Saving new custom deck: " .. Utils.customDeckList[#Utils.customDeckList].name)

        local desc1 = Utils.customDeckList[#Utils.customDeckList].descLine1
        local desc2 = Utils.customDeckList[#Utils.customDeckList].descLine2
        local desc3 = Utils.customDeckList[#Utils.customDeckList].descLine3
        local desc4 = Utils.customDeckList[#Utils.customDeckList].descLine4

        if desc1 == "" and desc2 == "" and desc3 == "" and desc4 == "" then
            desc1 = "Custom Deck"
            desc2 = "created at"
            desc3 = "{C:attention}" .. Utils.timestamp() .. "{}"
        end

        Utils.log("Deck description initialized: " .. desc1 .. " " .. desc2 .. " " .. desc3 .. " " .. desc4)

        local newDeck = CustomDeck:fullNew(
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
                Utils.customDeckList[#Utils.customDeckList].config.flipped_cards,
                Utils.customDeckList[#Utils.customDeckList].config.customCardList,
                Utils.customDeckList[#Utils.customDeckList].config.custom_cards_set
        )
        Utils.log("newDeck initialized\n" .. Utils.tableToString(newDeck))

        Utils.customDeckList[#Utils.customDeckList] = newDeck
        Utils.customDeckList[#Utils.customDeckList]:register()
        Utils.log("newDeck registered")

        SMODS.injectDecks()
        Utils.log("All custom decks injected")

        Persistence.saveAllDecks()
        Utils.log("All custom decks saved successfully. Returning to main menu")

        CardUtils.resetToMainMenuState()
        G.FUNCS:exit_overlay_menu()
    end
end

function GUI.registerCreateDeckButton()
    SMODS.registerUIElement("DeckCreatorModule", {
        {
             n = G.UIT.R,
             config = {
                 padding = 0.5,
                 align = "cm"
             },
             nodes = {
                 UIBox_button({
                     label = {" Create Deck "},
                     shadow = true,
                     scale = 0.75 * 0.5,
                     colour = G.C.BOOSTER,
                     button = "DeckCreatorModuleOpenCreateDeck",
                     minh = 0.8,
                     minw = 8
                 })
             }
        },
        {
             n = G.UIT.R,
             config = {
                 padding = 0.1,
                 align = "cm"
             },
             nodes = {
                 UIBox_button({
                     label = {" Source Code "},
                     shadow = true,
                     scale = 0.75 * 0.5,
                     colour = G.C.BOOSTER,
                     button = "DeckCreatorModuleOpenGithub",
                     minh = 0.8,
                     minw = 8
                 })
             }
        }
    })
end


function GUI.resetAddCard()
    return {
        rank = 2,
        suit = "Hearts",
        suitKey = "H",
        edition = "None",
        enhancement = "None",
        editionKey = "",
        enhancementKey = "",
        seal = "None",
        copies = 1
    }
end

GUI.addCard = GUI.resetAddCard()

function GUI.createAddCardsMenu()
    GUI.addCard = GUI.resetAddCard()
    return (create_UIBox_generic_options({
        back_func = "DeckCreatorModuleReopenBaseDeck",
        contents = {
            {
                n = G.UIT.R,
                config = {
                    padding = 0,
                    align = "cm"
                },
                nodes = {
                    Helper.createMultiRowTabs({
                        tabRows = {
                            {
                                tabs = {
                                    {
                                        label = " Add Card ",
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
                                                                    Helper.createOptionSelector({label = "Rank", scale = 0.8, options = Utils.ranks(), opt_callback = 'DeckCreatorModuleAddCardChangeRank', current_option = (
                                                                            GUI.addCard.rank
                                                                    )}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    Helper.createOptionSelector({label = "Edition", scale = 0.8, options = Utils.editions(false), opt_callback = 'DeckCreatorModuleAddCardChangeEdition', current_option = (
                                                                            GUI.addCard.edition
                                                                    )}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    Helper.createOptionSelector({label = "Seal", scale = 0.8, options = Utils.seals(), opt_callback = 'DeckCreatorModuleAddCardChangeSeal', current_option = (
                                                                            GUI.addCard.seal
                                                                    )}),
                                                                }
                                                            }
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
                                                                    Helper.createOptionSelector({label = "Suit", scale = 0.8, options = Utils.suits(), opt_callback = 'DeckCreatorModuleAddCardChangeSuit', current_option = (
                                                                            GUI.addCard.suit
                                                                    )}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    Helper.createOptionSelector({label = "Enhancement", scale = 0.8, options = Utils.enhancements(), opt_callback = 'DeckCreatorModuleAddCardChangeEnhancement', current_option = (
                                                                            GUI.addCard.enhancement
                                                                    )}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    Helper.createOptionSelector({label = "Number of Copies", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 999), opt_callback = 'DeckCreatorModuleAddCardChangeCopies', current_option = (
                                                                            GUI.addCard.copies
                                                                    ), multiArrows = true }),
                                                                }
                                                            }
                                                        }
                                                    },
                                                }
                                            })
                                            table.insert(modNodes, {
                                                n = G.UIT.R,
                                                config = {
                                                    align = 'cm',
                                                    padding = 0.1,
                                                    minh = 0.8
                                                },
                                                nodes = {
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            padding = 0.3,
                                                            align = "cm"
                                                        },
                                                        nodes = {
                                                            UIBox_button({
                                                                label = {" Add "},
                                                                shadow = true,
                                                                scale = 0.75 * 0.5,
                                                                colour = G.C.BOOSTER,
                                                                button = "DeckCreatorModuleAddCard",
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
                                                    minw = 8,
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
                                    }
                                }
                            }
                        },
                        snap_to_nav = true,
                        colour = G.C.BOOSTER,
                    })
                }
            }
        }
    }))
end

function GUI.createDecksMenu(chosen)
    chosen = chosen or "Main Menu"
    return (create_UIBox_generic_options({
        back_func = "DeckCreatorModuleBackToModsScreen",
        contents = {
            {
                n = G.UIT.R,
                config = {
                    padding = 0,
                    align = "cm"
                },
                nodes = {
                    Helper.createMultiRowTabs({
                        tabRows = {
                            {
                                tabs = {
                                    {
                                        label = " Main Menu ",
                                        chosen = chosen == "Main Menu",
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
                                                            padding = 0.05,
                                                            minw = 4  -- Adjust the width as needed
                                                        },
                                                        nodes = {
                                                            {
                                                                n=G.UIT.R,
                                                                config={align = "cm"},
                                                                nodes={{n=G.UIT.T, config={text = "Deck Name", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}}
                                                            }
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = {
                                                            align = "cm",
                                                            padding = 0.1,
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
                                                    ), multiArrows = true, minorArrows = true }),

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
                                                                scale = 0.75 * 0.5,
                                                                colour = G.C.BOOSTER,
                                                                button = "DeckCreatorModuleSaveDeck",
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
                                                    minw = 8,
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
                                        chosen = chosen == "General",
                                        tab_definition_function = function()
                                            return {
                                                n = G.UIT.ROOT,
                                                config = {
                                                    emboss = 0.05,
                                                    minh = 6,
                                                    r = 0.1,
                                                    minw = 8,
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
                                        chosen = chosen == "Money",
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
                                                                  ), multiArrows = true, minorArrows = true }),
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
                                        chosen = chosen == "Hands & Discards",
                                        tab_definition_function = function()
                                            return {
                                                n = G.UIT.ROOT,
                                                config = {
                                                    emboss = 0.05,
                                                    minh = 6,
                                                    r = 0.1,
                                                    minw = 8,
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
                                                    ), multiArrows = true, minorArrows = true, doubleArrowsOnly = true }),
                                                }
                                            }
                                        end
                                    },
                                    {

                                        label = " Appearance Rates ",
                                        chosen = chosen == "Appearance Rates",
                                        tab_definition_function = function()
                                            return {
                                                n = G.UIT.ROOT,
                                                config = {
                                                    emboss = 0.05,
                                                    minh = 6,
                                                    r = 0.1,
                                                    minw = 8,
                                                    align = "cm",
                                                    padding = 0.2,
                                                    colour = G.C.BLACK
                                                },
                                                nodes = {
                                                    Helper.createOptionSelector({label = "Joker Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeJokerRate', current_option = (
                                                            Utils.customDeckList[#Utils.customDeckList].config.joker_rate
                                                    ), multiArrows = true, minorArrows = true }),
                                                    Helper.createOptionSelector({label = "Tarot Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeTarotRate', current_option = (
                                                            Utils.customDeckList[#Utils.customDeckList].config.tarot_rate
                                                    ), multiArrows = true, minorArrows = true }),
                                                    Helper.createOptionSelector({label = "Planet Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangePlanetRate', current_option = (
                                                            Utils.customDeckList[#Utils.customDeckList].config.planet_rate
                                                    ), multiArrows = true, minorArrows = true }),
                                                    Helper.createOptionSelector({label = "Spectral Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeSpectralRate', current_option = (
                                                            Utils.customDeckList[#Utils.customDeckList].config.spectral_rate
                                                    ), multiArrows = true, minorArrows = true }),
                                                    Helper.createOptionSelector({label = "Playing Card Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangePlayingCardRate', current_option = (
                                                            Utils.customDeckList[#Utils.customDeckList].config.playing_card_rate
                                                    ), multiArrows = true, minorArrows = true })
                                                }
                                            }
                                        end
                                    },
                                }
                            },
                            {
                                tabs = {
                                    {

                                        label = " Gameplay ",
                                        chosen = chosen == "Gameplay",
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
                                                                    create_toggle({label = "Double Tag on Boss win", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'double_tag'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Balance Chips and Mult", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'balance_chips'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "All Jokers Eternal", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'all_eternal'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Boosters cost $1 more per Ante", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'booster_ante_scaling'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Hold -1 cards in hand per $5", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'minus_hand_size_per_X_dollar'}),
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
                                                                    create_toggle({label = "1 in 4 cards are drawn face down", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'flipped_cards'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "All played cards become debuffed after scoring", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'debuff_played_cards'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Eternal Jokers appear in shop", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'enable_eternals_in_shop'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Chips cannot exceed current $", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'chips_dollar_cap'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Raise prices by $1 on every purchase", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'inflation'}),
                                                                }
                                                            },
                                                        }
                                                    }
                                                }
                                            }
                                        end
                                    },
                                    {

                                        label = " Base Deck ",
                                        chosen = chosen == "Base Deck",
                                        tab_definition_function = function()
                                            return {
                                                n = G.UIT.ROOT,
                                                config = {
                                                    emboss = 0.05,
                                                    minh = 6,
                                                    r = 0.1,
                                                    minw = 8,
                                                    align = "cm",
                                                    padding = 0.2,
                                                    colour = G.C.BLACK
                                                },
                                                nodes = {
                                                    Helper.view_deck()
                                                }
                                            }
                                        end
                                    },
                                    {

                                        label = " Deck Mods ",
                                        chosen = chosen == "Deck Mods",
                                        tab_definition_function = function()
                                            return {
                                                n = G.UIT.ROOT,
                                                config = {
                                                    emboss = 0.05,
                                                    minh = 6,
                                                    r = 0.1,
                                                    minw = 8,
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
                                    },
                                    {

                                        label = " Starting Items ",
                                        chosen = chosen == "Starting Items",
                                        tab_definition_function = function()
                                            return {
                                                n = G.UIT.ROOT,
                                                config = {
                                                    emboss = 0.05,
                                                    minh = 6,
                                                    r = 0.1,
                                                    minw = 8,
                                                    align = "cm",
                                                    padding = 0.2,
                                                    colour = G.C.BLACK
                                                },
                                                nodes = {

                                                }
                                            }
                                        end
                                    },
                                    {

                                        label = " Banned Items ",
                                        chosen = chosen == "Banned Items",
                                        tab_definition_function = function()
                                            return {
                                                n = G.UIT.ROOT,
                                                config = {
                                                    emboss = 0.05,
                                                    minh = 6,
                                                    r = 0.1,
                                                    minw = 8,
                                                    align = "cm",
                                                    padding = 0.2,
                                                    colour = G.C.BLACK
                                                },
                                                nodes = {

                                                }
                                            }
                                        end
                                    }
                                }
                            }
                        },
                        snap_to_nav = true,
                        colour = G.C.BOOSTER,
                    })
                }
            }
        }
    }))
end

return GUI
