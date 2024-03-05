local Persistence = require "Persistence"
local Utils = require "Utils"
local CustomDeck = require "CustomDeck"
local Helper = require "GuiElementHelper"
local CardUtils = require "CardUtils"

local GUI = {}

GUI.DynamicUIManager = {}
GUI.DeckCreatorOpen = false
GUI.StartingItemsOpen = false
GUI.openTab = nil
GUI.openItemType = nil

function GUI.CloseAllOpenFlags()
    GUI.DeckCreatorOpen = false
    GUI.StartingItemsOpen = false
    GUI.openItemType = nil
end

function GUI.setOpenTab(tab)
    GUI.openTab = tab
    GUI.CloseAllOpenFlags()
    Utils.log("Switched DeckCreator tab: " .. tab)
    if tab == "Base Deck" then
        GUI.DeckCreatorOpen = true
    elseif tab == "Starting Items" then
        GUI.StartingItemsOpen = true
    end
end

function GUI.registerGlobals()
    G.FUNCS.DeckCreatorModuleOpenGithub = function()
        love.system.openURL("https://github.com/adambennett/Balatro-DeckCreator")
    end

    G.FUNCS.DeckCreatorModuleUpdateNewMods = function(args)
        if not args or not args.cycle_config then return end
        GUI.DynamicUIManager.updateDynamicAreas({
            ["modsList"] = GUI.dynamicNewMods(args.cycle_config.current_option)
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicDeckEditorAreaCards = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["dynamicDeckEditorAreaCards"] = GUI.dynamicDeckEditorAreaCards()
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicDeckEditorAreaDeckTables = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["dynamicDeckEditorAreaDeckTables"] = GUI.dynamicDeckEditorAreaDeckTables()
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicStartingItemsAreaCards = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["dynamicStartingItemsAreaCards"] = GUI.dynamicStartingItemsAreaCards()
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicStartingItemsAreaDeckTables = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["dynamicStartingItemsAreaDeckTables"] = GUI.dynamicStartingItemsAreaDeckTables()
        })
    end

    G.FUNCS.DeckCreatorModuleAddCard = function()
        CardUtils.addCardToDeck({ addCard = GUI.addCard, deck_list = Utils.customDeckList})
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

    G.FUNCS.DeckCreatorModuleOpenAddItemToDeck = function ()
        GUI.openItemType = nil
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu({
            definition = GUI.createSelectItemTypeMenu()
        })
    end

    G.FUNCS.DeckCreatorModuleAddVoucherMenu = function()
        GUI.openItemType = 'voucher'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addVoucherMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleGenerateCard = function()
        local addCard = {
            rank = "Random",
            suit = "Random",
            edition = "Random",
            enhancement = "Random",
            seal = "Random",
            copies = 1
        }
        CardUtils.addCardToDeck({ addCard = addCard, deck_list = Utils.customDeckList})
        Utils.customDeckList[#Utils.customDeckList].config.custom_cards_set = true
        GUI.updateAllDeckEditorAreas()
    end

    G.FUNCS.DeckCreatorModuleGenerateItem = function()
        CardUtils.addItemToDeck({ isRandomType = true, deck_list = Utils.customDeckList})
        Utils.customDeckList[#Utils.customDeckList].config.custom_cards_set = true
        GUI.updateAllStartingItemsAreas()
    end

    G.FUNCS.DeckCreatorModuleDeleteAllCardsFromBaseDeck = function()
        for j = 1, #Helper.deckEditorAreas do
            for i = #Helper.deckEditorAreas[j].cards,1, -1 do
                local c = Helper.deckEditorAreas[j]:remove_card(Helper.deckEditorAreas[j].cards[i])
                c:remove()
                c = nil
            end
        end
        Utils.customDeckList[#Utils.customDeckList].config.customCardList = {}
        Utils.customDeckList[#Utils.customDeckList].config.custom_cards_set = true
        if G.playing_cards and #G.playing_cards > 0 then
            for j = 1, #G.playing_cards do
                local c = G.playing_cards[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        G.playing_cards = {}
        GUI.updateAllDeckEditorAreas()
    end

    G.FUNCS.DeckCreatorModuleDeleteAllStartingItemsFromBaseDeck = function()
        for j = 1, #Helper.deckEditorAreas do
            for i = #Helper.deckEditorAreas[j].cards,1, -1 do
                local c = Helper.deckEditorAreas[j]:remove_card(Helper.deckEditorAreas[j].cards[i])
                c:remove()
                c = nil
            end
        end
        Utils.customDeckList[#Utils.customDeckList].config.customVoucherList = {}
        Utils.customDeckList[#Utils.customDeckList].config.custom_vouchers_set = true
        if CardUtils.startingItems.vouchers and #CardUtils.startingItems.vouchers > 0 then
            for j = 1, #CardUtils.startingItems.vouchers do
                local c = CardUtils.startingItems.vouchers[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.startingItems.vouchers = {}
        GUI.updateAllStartingItemsAreas()
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

    G.FUNCS.DeckCreatorModuleChangeCopyFromDeck = function(args)
        Utils.customDeckList[#Utils.customDeckList].config.copy_deck_config = args.to_val
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
        GUI.CloseAllOpenFlags()
        G.FUNCS:exit_overlay_menu()
        G.FUNCS.overlay_menu({
            definition = create_UIBox_mods(arg_736_0)
        })
    end

    G.FUNCS.DeckCreatorModuleOpenCreateDeck = function()
        G.SETTINGS.paused = true

        Utils.addDeckToList(CustomDeck:blankDeck())
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Base Deck")
        })
        G.FUNCS:exit_overlay_menu()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Main Menu")
        })
    end

    G.FUNCS.DeckCreatorModuleReopenBaseDeck = function()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Base Deck")
        })
    end

    G.FUNCS.DeckCreatorModuleReopenStartingItems = function()
        GUI.openItemType = nil
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Starting Items")
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
                Utils.customDeckList[#Utils.customDeckList].config.uuid,
                Utils.customDeckList[#Utils.customDeckList].config.copy_deck_config,
                Utils.customDeckList[#Utils.customDeckList].config.customCardList,
                Utils.customDeckList[#Utils.customDeckList].config.custom_cards_set,
                Utils.customDeckList[#Utils.customDeckList].config.customJokerList,
                Utils.customDeckList[#Utils.customDeckList].config.custom_jokers_set,
                Utils.customDeckList[#Utils.customDeckList].config.customConsumableList,
                Utils.customDeckList[#Utils.customDeckList].config.custom_consumables_set,
                Utils.customDeckList[#Utils.customDeckList].config.customVoucherList,
                Utils.customDeckList[#Utils.customDeckList].config.custom_vouchers_set
        )
        Utils.log("newDeck initialized\n" .. Utils.tableToString(newDeck))
        Utils.customDeckList[#Utils.customDeckList] = newDeck

        Persistence.refreshDeckList()
        Utils.log("All custom decks re-injected")

        Persistence.saveAllDecks()
        GUI.CloseAllOpenFlags()
        Utils.log("All custom decks saved successfully. Returning to main menu")

        G.FUNCS:exit_overlay_menu()
    end
end

function GUI.registerModMenuUI()
    if not SMODS.BalamodMode then
        SMODS.registerUIElement("ADeckCreatorModule", {
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
            },

            --[[{
                n = G.UIT.R,
                config = {
                    padding = 0.1,
                    align = "cm"
                },
                nodes = {
                    UIBox_button({
                        label = {" New Mods Menu "},
                        shadow = true,
                        scale = 0.75 * 0.5,
                        colour = G.C.BOOSTER,
                        button = "DeckCreatorModuleNewModsMenu",
                        minh = 0.8,
                        minw = 8
                    })
                }
            }]]
        })
    end
end

function GUI.resetAddCard()
    return {
        rank = 2,
        suit = "Clubs",
        suitKey = "C",
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
    return create_UIBox_generic_options({
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
                                                                    Helper.createOptionSelector({label = "Rank", scale = 0.8, options = Utils.ranks(true), opt_callback = 'DeckCreatorModuleAddCardChangeRank', current_option = (
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
                                                                    Helper.createOptionSelector({label = "Edition", scale = 0.8, options = Utils.editions(false, true), opt_callback = 'DeckCreatorModuleAddCardChangeEdition', current_option = (
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
                                                                    Helper.createOptionSelector({label = "Seal", scale = 0.8, options = Utils.seals(true), opt_callback = 'DeckCreatorModuleAddCardChangeSeal', current_option = (
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
                                                                    Helper.createOptionSelector({label = "Suit", scale = 0.8, options = Utils.suits(true), opt_callback = 'DeckCreatorModuleAddCardChangeSuit', current_option = (
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
                                                                    Helper.createOptionSelector({label = "Enhancement", scale = 0.8, options = Utils.enhancements(true), opt_callback = 'DeckCreatorModuleAddCardChangeEnhancement', current_option = (
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
                                                                    Helper.createOptionSelector({label = "Number of Copies", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 99), opt_callback = 'DeckCreatorModuleAddCardChangeCopies', current_option = (
                                                                            GUI.addCard.copies
                                                                    ), multiArrows = true, minorArrows = true }),
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
    })
end

function GUI.createDecksMenu(chosen)
    chosen = chosen or "Main Menu"
    return create_UIBox_generic_options({
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
                                            GUI.setOpenTab("Main Menu")
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
                                            GUI.setOpenTab("General")
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
                                                    )}),
                                                    Helper.createOptionSelector({label = "Copy Deck Properties", scale = 0.8, options = Utils.allDeckNames(), opt_callback = 'DeckCreatorModuleChangeCopyFromDeck', current_option = (
                                                            Utils.customDeckList[#Utils.customDeckList].config.copy_deck_config
                                                    ) }),
                                                }
                                            }
                                        end
                                    },
                                    {

                                        label = " Money ",
                                        chosen = chosen == "Money",
                                        tab_definition_function = function()
                                            GUI.setOpenTab("Money")
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
                                            GUI.setOpenTab("Hands & Discards")
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
                                            GUI.setOpenTab("Appearance Rates")
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
                                    }
                                }
                            },
                            {
                                tabs = {
                                    {

                                        label = " Base Deck ",
                                        chosen = chosen == "Base Deck",
                                        tab_definition_function = function()
                                            GUI.setOpenTab("Base Deck")
                                            return GUI.DynamicUIManager.initTab({
                                                updateFunctions = {
                                                    dynamicDeckEditorAreaCards = G.FUNCS.DeckCreatorModuleUpdateDynamicDeckEditorAreaCards,
                                                    dynamicDeckEditorAreaDeckTables = G.FUNCS.DeckCreatorModuleUpdateDynamicDeckEditorAreaDeckTables
                                                },
                                                staticPageDefinition = GUI.deckEditorPageStatic()
                                            })
                                        end
                                    },
                                    {
                                        label = " Starting Items ",
                                        chosen = chosen == "Starting Items",
                                        tab_definition_function = function()
                                            GUI.setOpenTab("Starting Items")
                                            return GUI.DynamicUIManager.initTab({
                                                updateFunctions = {
                                                    dynamicStartingItemsAreaCards = G.FUNCS.DeckCreatorModuleUpdateDynamicStartingItemsAreaCards,
                                                    dynamicStartingItemsAreaDeckTables = G.FUNCS.DeckCreatorModuleUpdateDynamicStartingItemsAreaDeckTables
                                                },
                                                staticPageDefinition = GUI.startingItemsPageStatic()
                                            })
                                        end
                                    },
                                    {

                                        label = " Banned Items ",
                                        chosen = chosen == "Banned Items",
                                        tab_definition_function = function()
                                            GUI.setOpenTab("Banned Items")
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

                                        label = " Static Mods ",
                                        chosen = chosen == "Static Mods",
                                        tab_definition_function = function()
                                            GUI.setOpenTab("Static Mods")
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
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Gain $1 per round for each\nof your Enhanced cards", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'one_dollar_for_each_enhanced_card'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Gain $10 when a Glass card breaks", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'ten_dollars_for_broken_glass'}),
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
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Lose $1 per round for each Negative Joker", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'lose_one_dollar_per_negative_joker'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Receive random Negative Joker when a Glass card breaks", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'negative_joker_for_broken_glass'}),
                                                                }
                                                            },
                                                        }
                                                    }
                                                }
                                            }
                                        end
                                    },
                                    {

                                        label = " Dynamic Mods ",
                                        chosen = chosen == "Dynamic Mods",
                                        tab_definition_function = function()
                                            GUI.setOpenTab("Dynamic Mods")
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
                                                                    create_toggle({label = "Increase Starting Money ($0 - $100)", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomize_money_big'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Scramble All Money Settings", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomize_money'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Scramble Appearance Rate Settings", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomize_appearance_rates'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Randomize Suits", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomize_suits'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Start with 2 Random Jokers", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'two_random_jokers'}),
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
                                                                    create_toggle({label = "No Numbered Cards", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'no_numbered_cards'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Scramble Number of Hands & Discards", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomize_hands_discards'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Increase Starting Money ($0 - $20)", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomize_money_small'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Random Starting Items", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'random_starting_items'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Randomly Enable Gameplay Settings", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomly_enable_gameplay'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Randomize Ranks", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'randomize_ranks'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Start with 1 Random Voucher", ref_table = Utils.customDeckList[#Utils.customDeckList].config, ref_value = 'one_random_voucher'}),
                                                                }
                                                            },
                                                        }
                                                    },
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
    })
end

function GUI.createSelectItemTypeMenu()
    return create_UIBox_generic_options({
        back_func = 'DeckCreatorModuleReopenStartingItems',
        contents = {
            {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes={
                UIBox_button({button = 'your_collection_jokers', label = {localize('b_jokers')}, count = G.DISCOVER_TALLIES.jokers,  minw = 5, minh = 1.7, scale = 0.6, id = 'your_collection_jokers'}),
                UIBox_button({button = 'your_collection_tags', label = {localize('b_tags')}, count = G.DISCOVER_TALLIES.tags, minw = 5, id = 'your_collection_tags'}),
                UIBox_button({button = 'DeckCreatorModuleAddVoucherMenu', label = {localize('b_vouchers')}, count = G.DISCOVER_TALLIES.vouchers, minw = 5, id = 'your_collection_vouchers'}),
                {n=G.UIT.R, config={align = "cm", padding = 0.1, r=0.2, colour = G.C.BLACK}, nodes={
                    {n=G.UIT.C, config={align = "cm", maxh=2.9}, nodes={
                        {n=G.UIT.T, config={text = localize('k_cap_consumables'), scale = 0.45, colour = G.C.L_BLACK, vert = true, maxh=2.2}},
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes={
                        UIBox_button({button = 'your_collection_tarots', label = {localize('b_tarot_cards')}, count = G.DISCOVER_TALLIES.tarots, minw = 4, id = 'your_collection_tarots', colour = G.C.SECONDARY_SET.Tarot}),
                        UIBox_button({button = 'your_collection_planets', label = {localize('b_planet_cards')}, count = G.DISCOVER_TALLIES.planets, minw = 4, id = 'your_collection_planets', colour = G.C.SECONDARY_SET.Planet}),
                        UIBox_button({button = 'your_collection_spectrals', label = {localize('b_spectral_cards')}, count = G.DISCOVER_TALLIES.spectrals, minw = 4, id = 'your_collection_spectrals', colour = G.C.SECONDARY_SET.Spectral}),
                    }}
                }}
            }}
        }
    })
end

function GUI.DynamicUIManager.initTab(args)
    local updateFunctions = args.updateFunctions
    local staticPageDefinition = args.staticPageDefinition

    for _, updateFunction in pairs(updateFunctions) do
        G.E_MANAGER:add_event(Event({func = function()
            updateFunction{cycle_config = {current_option = 1}}
            return true
        end}))
    end
    return GUI.DynamicUIManager.generateBaseNode(staticPageDefinition)
end

function GUI.DynamicUIManager.generateBaseNode(staticPageDefinition)
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
            staticPageDefinition
        }
    }
end

function GUI.DynamicUIManager.updateDynamicAreas(uiDefinitions)
    for id, uiDefinition in pairs(uiDefinitions) do
        local dynamicArea = G.OVERLAY_MENU:get_UIE_by_ID(id)
        if dynamicArea and dynamicArea.config.object then
            dynamicArea.config.object:remove()
            dynamicArea.config.object = UIBox{
                definition = uiDefinition,
                config = {offset = {x=0, y=0}, align = 'cm', parent = dynamicArea}
            }
        end
    end
end

function GUI.deckEditorPageStatic()
    return {
        n=G.UIT.ROOT,
        config={align = "cm", colour = G.C.CLEAR},
        nodes= {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.05 },
                nodes = {
                    {n=G.UIT.C, config={align = "cm", padding = 0.0}, nodes={
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.05 },
                            nodes = {}
                        },
                        {n=G.UIT.R, config={align = "cm", padding = 0.1, minh = 7.5, minw = 4.5}, nodes={
                            {n=G.UIT.O, config={id = 'dynamicDeckEditorAreaCards', object = Moveable()}},
                        }},
                    }},
                    {n=G.UIT.C, config={align = "cm", minh = 7.5, minw = 12}, nodes={
                        {n=G.UIT.O, config={id = 'dynamicDeckEditorAreaDeckTables', object = Moveable()}},
                    }},
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.05 },
                nodes = {
                    {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                        UIBox_button({
                            label = {" Add Card "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleOpenAddCardToDeck",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                        UIBox_button({
                            label = {" Generate Card "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleGenerateCard",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                        UIBox_button({
                            label = {" Remove All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleDeleteAllCardsFromBaseDeck",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                }
            }
    }}
end

function GUI.dynamicDeckEditorAreaCards()

    if GUI.openTab ~= "Base Deck" then
        return {
            n=G.UIT.C,
            config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
            nodes={}
        }
    end

    local flip_col = G.C.WHITE
    local deckList = Utils.customDeckList[#Utils.customDeckList].config.customCardList
    CardUtils.getCardsFromCustomCardList(deckList)
    remove_nils(G.playing_cards)
    Helper.calculateDeckEditorSums()

    -- local currentDeckName = Utils.customDeckList[#Utils.customDeckList].name

    --[[local boxText = { "Click any card", "to remove it", "from your deck"}
    local empty = true
    local t = {}

    for k,v in ipairs(boxText) do
        t[#t+1] = {
            n=G.UIT.R,
            config={align = "cm", maxw = 0.7*5 },
            nodes={
                { n=G.UIT.T, config={text = v, scale = 0.3, colour = G.C.UI.TEXT_DARK } }
            }
        }
    end

    local descFromRows = {
        n=G.UIT.R,
        config={align = "cm", colour = empty and G.C.CLEAR or G.C.UI.BACKGROUND_WHITE, r = 0.1, padding = 0.04, minw = 2, minh = 0.6, emboss = not empty and 0.05 or nil, filler = true},
        nodes={
            {
                n=G.UIT.R,
                config={align = "cm", padding = 0.03},
                nodes=t
            }
        }
    }

    local backGeneratedUI = {
        n=G.UIT.ROOT,
        config={align = "cm", minw = 0.7*5, minh = 0.7*1.5, id = currentDeckName, colour = G.C.CLEAR},
        nodes={
            descFromRows
        }
    }
    Utils.log("Base Deck content:\n" .. Utils.tableToString(backGeneratedUI))]]

    return {
        n=G.UIT.C,
        config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
        nodes={
            {
                n=G.UIT.C,
                config={align = "cm", padding = 0.1},
                nodes={
                    --[[{ n = G.UIT.R, config = { align = "cm", r = 0.1, colour = G.C.L_BLACK, emboss = 0.05, padding = 0.15 }, nodes = {
                        { n = G.UIT.R, config = { align = "cm" }, nodes = {
                            { n = G.UIT.O, config = { object = DynaText({ string = currentDeckName, colours = { G.C.WHITE }, bump = true, rotate = true, shadow = true, scale = 0.6 - string.len(currentDeckName) * 0.01 }) } },
                        } },
                        { n = G.UIT.R, config = { align = "cm", r = 0.1, padding = 0.1, minw = 2.5, minh = 1.3, colour = G.C.WHITE, emboss = 0.05 }, nodes = {
                            { n = G.UIT.O, config = { object = UIBox {
                                definition = backGeneratedUI,
                                config = { offset = { x = 0, y = 0 } }
                            } } }
                        } }
                    } },]]
                    { n = G.UIT.R, config = { align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5 }, nodes = {
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.07 }, nodes = {
                            { n = G.UIT.O, config = { object = DynaText({ string = { { string = localize('k_base_cards'), colour = G.C.RED }, Helper.sums.modded and { string = localize('k_effective'), colour = G.C.BLUE } or nil }, colours = { G.C.RED }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4 }) } }
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            tally_sprite({ x = 1, y = 0 }, { { string = Helper.sums.ace_tally, colour = flip_col }, { string = Helper.sums.mod_ace_tally, colour = G.C.BLUE } }, { localize('k_aces') }), --Aces
                            tally_sprite({ x = 2, y = 0 }, { { string = Helper.sums.face_tally, colour = flip_col }, { string = Helper.sums.mod_face_tally, colour = G.C.BLUE } }, { localize('k_face_cards') }), --Face
                            tally_sprite({ x = 3, y = 0 }, { { string = Helper.sums.num_tally, colour = flip_col }, { string = Helper.sums.mod_num_tally, colour = G.C.BLUE } }, { localize('k_numbered_cards') }), --Numbers
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            tally_sprite({ x = 3, y = 1 }, { { string = Helper.sums.suit_tallies['Spades'], colour = flip_col }, { string = Helper.sums.mod_suit_tallies['Spades'], colour = G.C.BLUE } }, { localize('Spades', 'suits_plural') }),
                            tally_sprite({ x = 0, y = 1 }, { { string = Helper.sums.suit_tallies['Hearts'], colour = flip_col }, { string = Helper.sums.mod_suit_tallies['Hearts'], colour = G.C.BLUE } }, { localize('Hearts', 'suits_plural') }),
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            tally_sprite({ x = 2, y = 1 }, { { string = Helper.sums.suit_tallies['Clubs'], colour = flip_col }, { string = Helper.sums.mod_suit_tallies['Clubs'], colour = G.C.BLUE } }, { localize('Clubs', 'suits_plural') }),
                            tally_sprite({ x = 1, y = 1 }, { { string = Helper.sums.suit_tallies['Diamonds'], colour = flip_col }, { string = Helper.sums.mod_suit_tallies['Diamonds'], colour = G.C.BLUE } }, { localize('Diamonds', 'suits_plural') }),
                        } },
                    } }
                }
            },
            {
                n=G.UIT.C,
                config={align = "cm"},
                nodes=Helper.sums.rank_cols
            },
            {
                n=G.UIT.B,
                config={w = 0.1, h = 0.1}
            },
        }
    }
end

function GUI.flushDeckEditorAreas()

    for k,v in pairs(CardUtils.allCardsEverMade) do
        if v then
            v:remove()
            v = nil
        end
    end
    CardUtils.allCardsEverMade = {}

    if Helper.deckEditorAreas and #Helper.deckEditorAreas > 0 then
        for j = 1, #Helper.deckEditorAreas do
            Helper.deckEditorAreas[j]:remove()
        end
    end
    Helper.deckEditorAreas = {}
end

function GUI.dynamicDeckEditorAreaDeckTables()

    GUI.flushDeckEditorAreas()
    if GUI.openTab ~= "Base Deck" then
        return {
            n=G.UIT.ROOT,
            config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 11.4, minh = 4.2},
            nodes={}
        }
    end

    local deckList = Utils.customDeckList[#Utils.customDeckList].config.customCardList
    CardUtils.getCardsFromCustomCardList(deckList)

    local deck_tables = {}
    local SUITS = {
        S = {},
        H = {},
        C = {},
        D = {},
    }
    local suit_map = {'S', 'H', 'C', 'D'}

    local FakeBlind = {}
    function FakeBlind:debuff_card(arg) end
    remove_nils(G.playing_cards)
    G.VIEWING_DECK = true
    G.GAME.blind = FakeBlind

    table.sort(G.playing_cards, function (a, b) return a:get_nominal('suit') > b:get_nominal('suit') end )

    for k, v in ipairs(G.playing_cards) do
        table.insert(SUITS[string.sub(v.base.suit, 1, 1)], v)
    end

    local xy = GUI.openTab == 'Base Deck' and 0 or 9999

    for j = 1, 4 do
        if SUITS[suit_map[j]][1] then
            table.sort(SUITS[suit_map[j]], function(a,b) return a:get_nominal() > b:get_nominal() end )
            local view_deck = CardArea(
                        xy,xy,
                        5.5*G.CARD_W,
                        0.42*G.CARD_H,
                        {card_limit = #SUITS[suit_map[j]], type = 'title_2', view_deck = true, highlight_limit = 0, card_w = G.CARD_W*0.5, draw_layers = {'card'}})

            table.insert(Helper.deckEditorAreas, view_deck)
            table.insert(deck_tables,
                    {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                        {n=G.UIT.O, config={object = view_deck}}
                    }}
            )

            for i = 1, #SUITS[suit_map[j]] do
                if SUITS[suit_map[j]][i] then
                    local _scale = 0.7
                    local copy = copy_card(SUITS[suit_map[j]][i], nil, _scale)
                    copy.uuid = SUITS[suit_map[j]][i].uuid
                    copy.greyed = nil
                    copy.T.x = view_deck.T.x + view_deck.T.w/2
                    copy.T.y = view_deck.T.y
                    copy:hard_set_T()
                    view_deck:emplace(copy)
                    table.insert(CardUtils.allCardsEverMade, copy)
                end
            end
        end
    end

    G.GAME.blind = nil
    return {
        n=G.UIT.ROOT,
        config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 11.4, minh = 4.2},
        nodes=deck_tables
    }
end

function GUI.updateAllDeckEditorAreas()
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicDeckEditorAreaCards"] = GUI.dynamicDeckEditorAreaCards()
    })
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicDeckEditorAreaDeckTables"] = GUI.dynamicDeckEditorAreaDeckTables()
    })
end

function GUI.updateAllStartingItemsAreas()
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicStartingItemsAreaCards"] = GUI.dynamicStartingItemsAreaCards()
    })
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicStartingItemsAreaDeckTables"] = GUI.dynamicStartingItemsAreaDeckTables()
    })
end

function GUI.startingItemsPageStatic()
    return {
        n=G.UIT.ROOT,
        config={align = "cm", colour = G.C.CLEAR},
        nodes= {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.05 },
                nodes = {
                    {n=G.UIT.C, config={align = "cm", padding = 0.0}, nodes={
                        {
                            n = G.UIT.R,
                            config = { align = "cm", padding = 0.05 },
                            nodes = {}
                        },
                        {n=G.UIT.R, config={align = "cm", padding = 0.1, minh = 5.5, minw = 4.5}, nodes={
                            {n=G.UIT.O, config={id = 'dynamicStartingItemsAreaCards', object = Moveable()}},
                        }},
                    }},
                    {n=G.UIT.C, config={align = "cm", minh = 5.5, minw = 12}, nodes={
                        {n=G.UIT.O, config={id = 'dynamicStartingItemsAreaDeckTables', object = Moveable()}},
                    }},
                }
            },
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.05 },
                nodes = {
                    {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                        UIBox_button({
                            label = {" Add Item "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleOpenAddItemToDeck",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                        UIBox_button({
                            label = {" Generate Item "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleGenerateItem",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                        UIBox_button({
                            label = {" Remove All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleDeleteAllStartingItemsFromBaseDeck",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                }
            }
        }}
end

function GUI.dynamicStartingItemsAreaCards()
    if GUI.openTab ~= "Starting Items" then
        return {
            n=G.UIT.C,
            config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
            nodes={}
        }
    end

    local flip_col = G.C.WHITE
    local jokerList = Utils.customDeckList[#Utils.customDeckList].config.customJokerList
    local consumableList = Utils.customDeckList[#Utils.customDeckList].config.customConsumableList
    local voucherList = Utils.customDeckList[#Utils.customDeckList].config.customVoucherList
    CardUtils.getJokersFromCustomJokerList(jokerList)
    CardUtils.getConsumablesFromCustomConsumableList(consumableList)
    CardUtils.getVouchersFromCustomVoucherList(voucherList)
    remove_nils(CardUtils.startingItems.jokers)
    remove_nils(CardUtils.startingItems.consumables)
    remove_nils(CardUtils.startingItems.vouchers)
    Helper.calculateStartingItemsSums()

    return {
        n=G.UIT.C,
        config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
        nodes={
            {
                n=G.UIT.C,
                config={align = "cm", padding = 0.1},
                nodes={
                    --[[{ n = G.UIT.R, config = { align = "cm", r = 0.1, colour = G.C.L_BLACK, emboss = 0.05, padding = 0.15 }, nodes = {
                        { n = G.UIT.R, config = { align = "cm" }, nodes = {
                            { n = G.UIT.O, config = { object = DynaText({ string = currentDeckName, colours = { G.C.WHITE }, bump = true, rotate = true, shadow = true, scale = 0.6 - string.len(currentDeckName) * 0.01 }) } },
                        } },
                        { n = G.UIT.R, config = { align = "cm", r = 0.1, padding = 0.1, minw = 2.5, minh = 1.3, colour = G.C.WHITE, emboss = 0.05 }, nodes = {
                            { n = G.UIT.O, config = { object = UIBox {
                                definition = backGeneratedUI,
                                config = { offset = { x = 0, y = 0 } }
                            } } }
                        } }
                    } },]]
                    { n = G.UIT.R, config = { align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5 }, nodes = {
                        --[[{ n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.07 }, nodes = {
                            { n = G.UIT.O, config = { object = DynaText({ string = { { string = "Starting Items", colour = G.C.RED }, Helper.sums.moddedItems and { string = localize('k_effective'), colour = G.C.BLUE } or nil }, colours = { G.C.RED }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4 }) } }
                        } },]]
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 1, y = 0 }, { { string = Helper.sums.item_tallies['Joker'], colour = flip_col }, { string = Helper.sums.item_tallies['Joker'], colour = G.C.BLUE } }, { "Jokers" }), --Aces
                            Helper.tally_item_sprite({ x = 2, y = 0 }, { { string = (Helper.sums.item_tallies['Planet'] or 0) + (Helper.sums.item_tallies['Tarot'] or 0), colour = flip_col }, { string = Helper.sums.item_tallies['Joker'], colour = G.C.BLUE } }, { "Consumable" }), --Face
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.item_tallies['Voucher'], colour = flip_col }, { string = Helper.sums.item_tallies['Voucher'], colour = G.C.BLUE } }, { "Vouchers" }), --Numbers
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 3, y = 1 }, { { string = Helper.sums.item_tallies['Joker'], colour = flip_col }, { string = Helper.sums.item_tallies['Joker'], colour = G.C.BLUE } }, { "Jokers" }),
                            Helper.tally_item_sprite({ x = 0, y = 1 }, { { string = Helper.sums.item_tallies['Planet'], colour = flip_col }, { string = Helper.sums.item_tallies['Planet'], colour = G.C.BLUE } }, { "Planets" }),
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.item_tallies['Tarot'], colour = flip_col }, { string = Helper.sums.item_tallies['Tarot'], colour = G.C.BLUE } }, { "Tarots" }),
                            Helper.tally_item_sprite({ x = 1, y = 1 }, { { string = Helper.sums.item_tallies['Voucher'], colour = flip_col }, { string = Helper.sums.item_tallies['Voucher'], colour = G.C.BLUE } }, { "Vouchers" }),
                        } },
                    } }
                }
            },
            {
                n=G.UIT.C,
                config={align = "cm"},
                nodes = Helper.sums.start_item_cols
            },
            {
                n=G.UIT.B,
                config={w = 0.1, h = 0.1}
            },
        }
    }
end

function GUI.dynamicStartingItemsAreaDeckTables()
    GUI.flushDeckEditorAreas()
    if GUI.openTab ~= "Starting Items" then
        return {
            n=G.UIT.ROOT,
            config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 11.4, minh = 4.2},
            nodes={}
        }
    end

    local jokerList = Utils.customDeckList[#Utils.customDeckList].config.customJokerList
    local consumableList = Utils.customDeckList[#Utils.customDeckList].config.customConsumableList
    local voucherList = Utils.customDeckList[#Utils.customDeckList].config.customVoucherList
    CardUtils.getJokersFromCustomJokerList(jokerList)
    CardUtils.getConsumablesFromCustomConsumableList(consumableList)
    CardUtils.getVouchersFromCustomVoucherList(voucherList)

    local deck_tables = {}
    local FakeBlind = {}
    function FakeBlind:debuff_card(arg) end
    remove_nils(CardUtils.startingItems.jokers)
    remove_nils(CardUtils.startingItems.consumables)
    remove_nils(CardUtils.startingItems.vouchers)
    G.VIEWING_DECK = true
    G.GAME.blind = FakeBlind

    local xy = GUI.openTab == 'Starting Items' and 0 or 9999

    -- jokers
    local jokerArea = CardArea(
            xy,xy,
            5.5*G.CARD_W,
            0.42*G.CARD_H,
            {card_limit = 1, type = 'title', view_deck = true, highlight_limit = 0, card_w = G.CARD_W*0.5, draw_layers = {'card'}})
    table.insert(Helper.deckEditorAreas, jokerArea)
    table.insert(deck_tables,
            {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                {n=G.UIT.O, config={object = jokerArea}}
            }}
    )
    for i = 1, #CardUtils.startingItems.jokers do
        if CardUtils.startingItems.jokers[i] then
            local base = CardUtils.startingItems.jokers[i]
            local _scale = 0.7
            local copy = copy_card(base, nil, _scale)
            copy.uuid = base.uuid
            copy.greyed = nil
            copy.T.x = jokerArea.T.x + jokerArea.T.w/2
            copy.T.y = jokerArea.T.y
            copy:hard_set_T()
            jokerArea:emplace(copy)
            table.insert(CardUtils.allCardsEverMade, copy)
        end
    end

    -- consumables
    local consumableArea = CardArea(
            xy,xy,
            5.5*G.CARD_W,
            0.42*G.CARD_H,
            {card_limit = 1, type = 'title', view_deck = true, highlight_limit = 0, card_w = G.CARD_W*0.5, draw_layers = {'card'}})
    table.insert(Helper.deckEditorAreas, consumableArea)
    table.insert(deck_tables,
            {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                {n=G.UIT.O, config={object = consumableArea}}
            }}
    )
    for i = 1, #CardUtils.startingItems.consumables do
        if CardUtils.startingItems.consumables[i] then
            local base = CardUtils.startingItems.consumables[i]
            local _scale = 0.7
            local copy = copy_card(base, nil, _scale)
            copy.uuid = base.uuid
            copy.greyed = nil
            copy.T.x = consumableArea.T.x + consumableArea.T.w/2
            copy.T.y = consumableArea.T.y
            copy:hard_set_T()
            consumableArea:emplace(copy)
            table.insert(CardUtils.allCardsEverMade, copy)
        end
    end

    -- vouchers
    local voucherArea = CardArea(
            xy,xy,
            5.5*G.CARD_W,
            0.42*G.CARD_H,
            {card_limit = #CardUtils.startingItems.vouchers, type = 'title_2', view_deck = true, highlight_limit = 0, card_w = G.CARD_W*0.5, draw_layers = {'card'}})
    table.insert(Helper.deckEditorAreas, voucherArea)
    table.insert(deck_tables,
            {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                {n=G.UIT.O, config={object = voucherArea}}
            }}
    )
    for i = 1, #CardUtils.startingItems.vouchers do
        if CardUtils.startingItems.vouchers[i] then
            local base = CardUtils.startingItems.vouchers[i]
            local _scale = 0.7
            local copy = copy_card(base, nil, _scale)
            copy.uuid = base.uuid
            copy.greyed = nil
            copy.T.x = voucherArea.T.x + voucherArea.T.w/2
            copy.T.y = voucherArea.T.y
            copy:hard_set_T()
            voucherArea:emplace(copy)
            table.insert(CardUtils.allCardsEverMade, copy)
        end
    end

    -- output
    G.GAME.blind = nil
    return {
        n=G.UIT.ROOT,
        config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 11.4, minh = 4.2},
        nodes=deck_tables
    }
end

function GUI.addVoucherMenu()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                4.25*G.CARD_W,
                1*G.CARD_H,
                {card_limit = 4, type = 'voucher', highlight_limit = 0, collection = true})
        table.insert(deck_tables,
                {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
                    {n=G.UIT.O, config={object = G.your_collection[j]}}
                }}
        )
    end

    local voucher_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Voucher/(4*#G.your_collection)) do
        table.insert(voucher_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Voucher/(4*#G.your_collection))))
    end

    for i = 1, 4 do
        for j = 1, #G.your_collection do
            local center = G.P_CENTER_POOLS["Voucher"][i+(j-1)*4]
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
            card.ability.order = i+(j-1)*4
            card:start_materialize(nil, i>1 or j>1)
            G.your_collection[j]:emplace(card)
        end
    end

    return create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenAddItemToDeck', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            create_option_cycle({options = voucher_options, w = 4.5, cycle_shoulders = true, opt_callback = 'your_collection_voucher_page', focus_args = {snap_to = true, nav = 'wide'}, current_option = 1, colour = G.C.RED, no_pips = true})
        }}
    }})
end

return GUI
