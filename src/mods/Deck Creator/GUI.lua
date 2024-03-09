local Persistence = require "Persistence"
local Utils = require "Utils"
local CustomDeck = require "CustomDeck"
local Helper = require "GuiElementHelper"
local CardUtils = require "CardUtils"

local GUI = {}

GUI.OpenTab = nil
GUI.DynamicUIManager = {}
GUI.DeckCreatorOpen = false
GUI.StartingItemsOpen = false
GUI.ManageDecksConfig = {
    allCustomBacks = {},
    currentIndex = 1
}

function GUI.CloseAllOpenFlags()
    GUI.DeckCreatorOpen = false
    GUI.StartingItemsOpen = false
    GUI.resetOpenStartingItemConfig()
    if G.GAME and G.GAME.viewed_back then
        G.GAME.viewed_back:change_to(G.P_CENTER_POOLS.Back[1])
        G.PROFILES[G.SETTINGS.profile].MEMORY.deck = "Red Deck"
    end
end

function GUI.setOpenTab(tab)
    GUI.OpenTab = tab
    GUI.CloseAllOpenFlags()
    Utils.log("Switched DeckCreator tab: " .. tab)
    if tab == "Base Deck" then
        GUI.DeckCreatorOpen = true
    elseif tab == "Starting Items" then
        GUI.StartingItemsOpen = true
    end
end

function GUI.resetOpenStartingItemConfig()
    GUI.OpenStartingItemConfig = {}
    GUI.OpenStartingItemConfig.openItemType = nil
    GUI.OpenStartingItemConfig.edition = "None"
    GUI.OpenStartingItemConfig.copies = 1
    GUI.OpenStartingItemConfig.pinned = false
    GUI.OpenStartingItemConfig.eternal = false
end
GUI.resetOpenStartingItemConfig()

function GUI.registerGlobals()
    G.FUNCS.DeckCreatorModuleEmptyFunc = function() end

    G.FUNCS.DeckCreatorModuleOpenGithub = function()
        love.system.openURL("https://github.com/adambennett/Balatro-DeckCreator")
    end

    G.FUNCS.DeckCreatorModuleCopyDeck = function(args)
        local copyFrom
        local matchUUID = G.GAME.viewed_back.effect.config.uuid
        for k,v in pairs(Utils.customDeckList) do
            if v.config.uuid == matchUUID then
                copyFrom = v
                break
            end
        end

        local desc1 = copyFrom.loc_txt and copyFrom.loc_txt.text and #copyFrom.loc_txt.text > 0 and copyFrom.loc_txt.text[1] or ""
        local desc2 = copyFrom.loc_txt and copyFrom.loc_txt.text and #copyFrom.loc_txt.text > 1 and copyFrom.loc_txt.text[2] or ""
        local desc3 = copyFrom.loc_txt and copyFrom.loc_txt.text and #copyFrom.loc_txt.text > 2 and copyFrom.loc_txt.text[3] or ""
        local desc4 = copyFrom.loc_txt and copyFrom.loc_txt.text and #copyFrom.loc_txt.text > 3 and copyFrom.loc_txt.text[4] or ""
        local joinedDesc = desc1 .. " " .. desc2 .. " " .. desc3 .. " " .. desc4
        local copy = CustomDeck.fullNewFromExisting(copyFrom, joinedDesc, "", "", "", true)

        copy.config.dollars = copy.config.dollars + 8
        copy.config.hand_size = copy.config.hand_size + 16
        copy.config.discards = copy.config.discards + 6
        copy.config.hands = copy.config.hands + 8
        copy.config.joker_slot = copy.config.joker_slot + 10
        copy.config.consumable_slot = copy.config.consumable_slot + 4
        copy.config.interest_cap = copy.config.interest_cap / 25
        if not copy.config.extra_hand_bonus or copy.config.extra_hand_bonus == 0 then
            copy.config.extra_hand_bonus = 1
        end

        Utils.EditDeckConfig.newDeck = false
        Utils.EditDeckConfig.copyDeck = true
        Utils.EditDeckConfig.editDeck = false
        Utils.EditDeckConfig.deck = copy
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Main Menu")
        })
    end

    G.FUNCS.DeckCreatorModuleEditDeck = function(args)
        local matchUUID = G.GAME.viewed_back.effect.config.uuid
        for k,v in pairs(Utils.customDeckList) do
            if v.config.uuid == matchUUID then
                Utils.EditDeckConfig.deck = v
                break
            end
        end

        local deck = Utils.EditDeckConfig.deck
        local desc1 = deck.loc_txt and deck.loc_txt.text and #deck.loc_txt.text > 0 and deck.loc_txt.text[1] or ""
        local desc2 = deck.loc_txt and deck.loc_txt.text and #deck.loc_txt.text > 1 and deck.loc_txt.text[2] or ""
        local desc3 = deck.loc_txt and deck.loc_txt.text and #deck.loc_txt.text > 2 and deck.loc_txt.text[3] or ""
        local desc4 = deck.loc_txt and deck.loc_txt.text and #deck.loc_txt.text > 3 and deck.loc_txt.text[4] or ""
        local joinedDesc = desc1 .. " " .. desc2 .. " " .. desc3 .. " " .. desc4
        Utils.EditDeckConfig.deck = CustomDeck.fullNewFromExisting(deck, joinedDesc, "", "", "", false)

        Utils.EditDeckConfig.deck.config.dollars = Utils.EditDeckConfig.deck.config.dollars + 8
        Utils.EditDeckConfig.deck.config.hand_size = Utils.EditDeckConfig.deck.config.hand_size + 16
        Utils.EditDeckConfig.deck.config.discards = Utils.EditDeckConfig.deck.config.discards + 6
        Utils.EditDeckConfig.deck.config.hands = Utils.EditDeckConfig.deck.config.hands + 8
        Utils.EditDeckConfig.deck.config.joker_slot = Utils.EditDeckConfig.deck.config.joker_slot + 10
        Utils.EditDeckConfig.deck.config.consumable_slot = Utils.EditDeckConfig.deck.config.consumable_slot + 4
        Utils.EditDeckConfig.deck.config.interest_cap = Utils.EditDeckConfig.deck.config.interest_cap / 25
        if not Utils.EditDeckConfig.deck.config.extra_hand_bonus or Utils.EditDeckConfig.deck.config.extra_hand_bonus == 0 then
            Utils.EditDeckConfig.deck.config.extra_hand_bonus = 1
        end

        Utils.EditDeckConfig.newDeck = false
        Utils.EditDeckConfig.copyDeck = false
        Utils.EditDeckConfig.editDeck = true
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Main Menu")
        })
    end

    G.FUNCS.DeckCreatorModuleDeleteDeck = function(args)
        local matchUUID = G.GAME.viewed_back.effect.config.uuid
        local removeIndex
        for k,v in pairs(Utils.customDeckList) do
            if v.config.uuid == matchUUID then
                removeIndex = k
                break
            end
        end

        if removeIndex then
            table.remove(Utils.customDeckList, removeIndex)
        end

        local next = G.GAME.viewed_back.effect.center.order + 1
        table.insert(Utils.deletedSlugs, { slug = G.GAME.viewed_back.effect.center.key, order = G.GAME.viewed_back.effect.center.order })
        CustomDeck.unregister(matchUUID)
        Persistence.refreshDeckList()
        Persistence.saveAllDecks()
        if #Utils.customDeckList < 1 then
            GUI.redrawMainMenu()
            G.FUNCS.DeckCreatorModuleBackToMainMenu()
        else
            for k,v in pairs(Utils.customDeckList) do
                if v.config and v.config.centerPosition then
                    G.GAME.viewed_back:change_to(G.P_CENTER_POOLS.Back[v.config.centerPosition])
                    break
                end
            end
            G.FUNCS.overlay_menu({
                definition = GUI.createManageDecksMenu()
            })
        end
    end

    G.FUNCS.DeckCreatorModuleChangeManageDeckViewedDeck = function(args)
        for k,v in pairs(G.P_CENTER_POOLS.Back) do
            if v and v.name and v.name == args.to_val then
                G.GAME.viewed_back:change_to(v)
                G.PROFILES[G.SETTINGS.profile].MEMORY.deck = args.to_val
                return
            end
        end
        G.GAME.viewed_back:change_to(G.P_CENTER_POOLS.Back[args.to_key])
        G.PROFILES[G.SETTINGS.profile].MEMORY.deck = args.to_val
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
        Utils.getCurrentEditingDeck().config.custom_cards_set = true
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Base Deck")
        })
    end

    G.FUNCS.DeckCreatorModuleOpenAddCardToDeck = function ()
        G.FUNCS.overlay_menu({
            definition = GUI.createAddCardsMenu()
        })
    end

    G.FUNCS.DeckCreatorModuleOpenAddItemToDeck = function ()
        GUI.resetOpenStartingItemConfig()
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu({
            definition = GUI.createSelectItemTypeMenu()
        })
    end

    G.FUNCS.DeckCreatorModuleAddVoucherMenu = function()
        GUI.OpenStartingItemConfig.openItemType = 'voucher'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addVoucherMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleAddJokerMenu = function()
        GUI.OpenStartingItemConfig.openItemType = 'joker'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addJokerMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleAddTarotMenu = function()
        GUI.OpenStartingItemConfig.openItemType = 'tarot'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addTarotMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleAddPlanetMenu = function()
        GUI.OpenStartingItemConfig.openItemType = 'planet'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addPlanetMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleAddSpectralMenu = function()
        GUI.OpenStartingItemConfig.openItemType = 'spectral'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addSpectralMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleAddTagMenu = function()
        GUI.OpenStartingItemConfig.openItemType = 'tag'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addTagMenu()
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
        Utils.getCurrentEditingDeck().config.custom_cards_set = true
        GUI.updateAllDeckEditorAreas()
    end

    G.FUNCS.DeckCreatorModuleGenerateItem = function()
        CardUtils.addItemToDeck({ isRandomType = true, deck_list = Utils.customDeckList})
        Utils.getCurrentEditingDeck().config.custom_cards_set = true
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
        Utils.getCurrentEditingDeck().config.customCardList = {}
        Utils.getCurrentEditingDeck().config.custom_cards_set = true
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
        Utils.getCurrentEditingDeck().config.customVoucherList = {}
        Utils.getCurrentEditingDeck().config.customJokerList = {}
        Utils.getCurrentEditingDeck().config.customTarotList = {}
        Utils.getCurrentEditingDeck().config.customPlanetList = {}
        Utils.getCurrentEditingDeck().config.customSpectralList = {}
        Utils.getCurrentEditingDeck().config.custom_vouchers_set = false
        Utils.getCurrentEditingDeck().config.custom_jokers_set = false
        Utils.getCurrentEditingDeck().config.custom_tarots_set = false
        Utils.getCurrentEditingDeck().config.custom_planets_set = false
        Utils.getCurrentEditingDeck().config.custom_spectrals_set = false
        if CardUtils.startingItems.vouchers and #CardUtils.startingItems.vouchers > 0 then
            for j = 1, #CardUtils.startingItems.vouchers do
                local c = CardUtils.startingItems.vouchers[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.startingItems.jokers and #CardUtils.startingItems.jokers > 0 then
            for j = 1, #CardUtils.startingItems.jokers do
                local c = CardUtils.startingItems.jokers[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.startingItems.tarots and #CardUtils.startingItems.tarots > 0 then
            for j = 1, #CardUtils.startingItems.tarots do
                local c = CardUtils.startingItems.tarots[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.startingItems.planets and #CardUtils.startingItems.planets > 0 then
            for j = 1, #CardUtils.startingItems.planets do
                local c = CardUtils.startingItems.planets[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.startingItems.spectrals and #CardUtils.startingItems.spectrals > 0 then
            for j = 1, #CardUtils.startingItems.spectrals do
                local c = CardUtils.startingItems.spectrals[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.startingItems.tags and #CardUtils.startingItems.tags > 0 then
            for j = 1, #CardUtils.startingItems.tags do
                local c = CardUtils.startingItems.tags[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.startingItems.vouchers = {}
        CardUtils.startingItems.jokers = {}
        CardUtils.startingItems.tarots = {}
        CardUtils.startingItems.planets = {}
        CardUtils.startingItems.spectrals = {}
        CardUtils.startingItems.tags = {}
        GUI.updateAllStartingItemsAreas()
    end

    G.FUNCS.DeckCreatorModuleChangeOpenStartingItemConfigCopies = function(args)
        GUI.OpenStartingItemConfig.copies = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeOpenStartingItemConfigEdition = function(args)
        GUI.OpenStartingItemConfig.edition = string.lower(args.to_val)
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
        Utils.getCurrentEditingDeck().config.discard_cost = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDiscountPercent = function(args)
        Utils.getCurrentEditingDeck().config.discount_percent = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeShopSlots = function(args)
        Utils.getCurrentEditingDeck().config.shop_slots = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeInterestCap = function(args)
        Utils.getCurrentEditingDeck().config.interest_cap = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeInterestAmount = function(args)
        Utils.getCurrentEditingDeck().config.interest_amount = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeWinAnte = function(args)
        Utils.getCurrentEditingDeck().config.win_ante = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDeckBackIndex = function(args)
        local current_option_index = 1
        for i, option in ipairs(CustomDeck.getAllDeckBackNames()) do
            if option == args.to_val then
                current_option_index = i
                break
            end
        end
        Utils.getCurrentEditingDeck().config.deck_back_index = current_option_index
    end

    G.FUNCS.DeckCreatorModuleChangeEditionCount = function(args)
        Utils.getCurrentEditingDeck().config.edition_count = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeCopyFromDeck = function(args)
        Utils.getCurrentEditingDeck().config.copy_deck_config = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeJokerSlots = function(args)
        Utils.getCurrentEditingDeck().config.joker_slot = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeConsumableSlots = function(args)
        Utils.getCurrentEditingDeck().config.consumable_slot = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeAnteScaling = function(args)
        Utils.getCurrentEditingDeck().config.ante_scaling = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeJokerRate = function(args)
        Utils.getCurrentEditingDeck().config.joker_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeTarotRate = function(args)
        Utils.getCurrentEditingDeck().config.tarot_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangePlanetRate = function(args)
        Utils.getCurrentEditingDeck().config.planet_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeSpectralRate = function(args)
        Utils.getCurrentEditingDeck().config.spectral_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangePlayingCardRate = function(args)
        Utils.getCurrentEditingDeck().config.playing_card_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDollars = function(args)
        Utils.getCurrentEditingDeck().config.dollars = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDollarsPerHand = function(args)
        Utils.getCurrentEditingDeck().config.extra_hand_bonus = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDollarsPerDiscard = function(args)
        Utils.getCurrentEditingDeck().config.extra_discard_bonus = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeRerollCost = function(args)
        Utils.getCurrentEditingDeck().config.reroll_cost = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeNumHands = function(args)
        Utils.getCurrentEditingDeck().config.hands = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeNumDiscards = function(args)
        Utils.getCurrentEditingDeck().config.discards = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeHandSize = function(args)
        Utils.getCurrentEditingDeck().config.hand_size = args.to_val
    end

    G.FUNCS.DeckCreatorModuleBackToMainMenu = function()
        G.SETTINGS.paused = true
        GUI.CloseAllOpenFlags()
        if SMODS.BalamodMode then
            G.FUNCS.overlay_menu({
                definition = GUI.createBalamodMenu()
            })
        else
            G.FUNCS.overlay_menu({
                definition = create_UIBox_mods()
            })
        end
    end

    G.FUNCS.DeckCreatorModuleBackToModsScreen = function()
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu({
            definition = G.UIDEF.mods()
        })
    end

    G.FUNCS.DeckCreatorModuleOpenCreateDeck = function()
        G.SETTINGS.paused = true
        Utils.EditDeckConfig.newDeck = true
        Utils.EditDeckConfig.copyDeck = false
        Utils.EditDeckConfig.editDeck = false
        Utils.EditDeckConfig.deck = CustomDeck:blankDeck()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Base Deck")
        })
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Main Menu")
        })
    end

    G.FUNCS.DeckCreatorModuleOpenMainMenu = function()
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu({
            definition = GUI.createBalamodMenu()
        })
    end

    G.FUNCS.DeckCreatorModuleOpenManageDecks = function()
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu({
            definition = GUI.createManageDecksMenu()
        })
    end

    G.FUNCS.DeckCreatorModuleReopenBaseDeck = function()
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Base Deck")
        })
    end

    G.FUNCS.DeckCreatorModuleReopenStartingItems = function()
        G.SETTINGS.paused = true
        GUI.resetOpenStartingItemConfig()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Starting Items")
        })
    end

    G.FUNCS.DeckCreatorModuleSaveDeck = function()

        local desc1 = Utils.getCurrentEditingDeck().descLine1
        local desc2 = Utils.getCurrentEditingDeck().descLine2
        local desc3 = Utils.getCurrentEditingDeck().descLine3
        local desc4 = Utils.getCurrentEditingDeck().descLine4

        if desc1 == "" then
            desc1 = "Custom Deck"
            desc2 = "created at"
            desc3 = Utils.timestamp()
        elseif string.len(desc1) > 20 then
            local original = desc1
            desc1 = string.sub(original, 1, 20)
            desc2 = string.sub(original, 21, 40)
            desc3 = string.sub(original, 41, 60)
            desc4 = string.sub(original, 61, 80)
        end

        local newDeck = CustomDeck.fullNewFromExisting(Utils.getCurrentEditingDeck(), desc1, desc2, desc3, desc4)
        newDeck:register()

        if Utils.EditDeckConfig.editDeck then
            local newList = {}
            for k,v in pairs(Utils.customDeckList) do
                if v.config.uuid == Utils.EditDeckConfig.deck.config.uuid then
                    table.insert(newList, newDeck)
                else
                    table.insert(newList, v)
                end
            end
            Utils.customDeckList = newList

        else
            Utils.addDeckToList(newDeck)
        end

        Persistence.refreshDeckList()
        Persistence.saveAllDecks()
        GUI.CloseAllOpenFlags()
        GUI.redrawMainMenu()
        G.FUNCS:exit_overlay_menu()
    end
end

function GUI.redrawMainMenu()
    if not SMODS.BalamodMode then
        SMODS.customUIElements["ADeckCreatorModule"] = GUI.mainMenu()
    end
end

function GUI.mainMenu()
    return {
        {
            n = G.UIT.R,
            config = {
                padding = 0.5,
                align = "cm"
            },
            nodes = {

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
                #Utils.customDeckList > 0 and UIBox_button({
                    label = {" Manage Decks "},
                    shadow = true,
                    scale = 0.75 * 0.5,
                    colour = G.C.BOOSTER,
                    button = "DeckCreatorModuleOpenManageDecks",
                    minh = 0.8,
                    minw = 8
                }) or UIBox_button({
                    label = {" No Custom Decks Found "},
                    shadow = true,
                    scale = 0.75 * 0.5,
                    colour = G.C.RED,
                    button = "DeckCreatorModuleEmptyFunc",
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
    }
end

function GUI.registerModMenuUI()
    if not SMODS.BalamodMode then
        SMODS.registerUIElement("ADeckCreatorModule", GUI.mainMenu())
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

function GUI.DynamicUIManager.initTab(args)
    local updateFunctions = args.updateFunctions
    local staticPageDefinition = args.staticPageDefinition
    local preUpdateFunctions = args.preUpdateFunctions
    local postUpdateFunctions = args.postUpdateFunctions

    if preUpdateFunctions ~= nil then
        for _, updateFunction in pairs(preUpdateFunctions) do
            G.E_MANAGER:add_event(Event({func = function()
                updateFunction{cycle_config = {current_option = 1}}
                return true
            end}))
        end
    end

    if updateFunctions ~= nil then
        for _, updateFunction in pairs(updateFunctions) do
            G.E_MANAGER:add_event(Event({func = function()
                updateFunction{cycle_config = {current_option = 1}}
                return true
            end}))
        end
    end

    if postUpdateFunctions ~= nil then
        for _, updateFunction in pairs(postUpdateFunctions) do
            G.E_MANAGER:add_event(Event({func = function()
                updateFunction{cycle_config = {current_option = 1}}
                return true
            end}))
        end
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

-- Menus
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
        back_func = "DeckCreatorModuleBackToMainMenu",
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
                                                                w = 4,  -- Width of the text input
                                                                max_length = 25,  -- Max length of deck name
                                                                prompt_text = "Custom Deck",  -- Prompt text for input
                                                                ref_table = Utils.getCurrentEditingDeck(),  -- Table to store the inputted value
                                                                ref_value = 'name',  -- Key in ref_table where input is stored
                                                                extended_corpus = true,
                                                                keyboard_offset = 1,
                                                                callback = function(val) end
                                                            }),
                                                        }
                                                    },
                                                    create_option_cycle({label = "Card Back", scale = 0.8, options = CustomDeck.getAllDeckBackNames(), opt_callback = 'DeckCreatorModuleChangeDeckBackIndex', current_option = (
                                                            Utils.getCurrentEditingDeck().config.deck_back_index
                                                    ), no_pips = true }),
                                                    Helper.createOptionSelector({label = "Winning Ante", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 50), opt_callback = 'DeckCreatorModuleChangeWinAnte', current_option = (
                                                            Utils.getCurrentEditingDeck().config.win_ante
                                                    ), multiArrows = true, minorArrows = true }),

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
                                                    {
                                                        n = G.UIT.R,
                                                        config = { align = "cm", padding = 0.1 },
                                                        nodes = {
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.05,
                                                                    minw = 4
                                                                },
                                                                nodes = {
                                                                    {
                                                                        n=G.UIT.R,
                                                                        config={align = "cm"},
                                                                        nodes={{n=G.UIT.T, config={text = "Deck Description", scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}}
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
                                                                        w = 4,
                                                                        max_length = 70,
                                                                        prompt_text = "Custom Description",
                                                                        ref_table = Utils.getCurrentEditingDeck(),
                                                                        ref_value = 'descLine1',
                                                                        extended_corpus = true,
                                                                        keyboard_offset = 1,
                                                                        callback = function(val) end
                                                                    }),
                                                                }
                                                            }
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = { align = "cm", padding = 0.1 },
                                                        nodes = {
                                                            {
                                                                n = G.UIT.C,
                                                                config = { align = "cm", minw = 3, padding = 0.2, r = 0.1, colour = G.C.CLEAR },
                                                                nodes = {
                                                                    {
                                                                        n = G.UIT.R,
                                                                        config = { align = "cm", padding = 0.1 },
                                                                        nodes = {
                                                                            Helper.createOptionSelector({label = "Joker Slots", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeJokerSlots', current_option = (
                                                                                    Utils.getCurrentEditingDeck().config.joker_slot
                                                                            ), multiArrows = true }),
                                                                        }
                                                                    },
                                                                    {
                                                                        n = G.UIT.R,
                                                                        config = { align = "cm", padding = 0.1 },
                                                                        nodes = {
                                                                            Helper.createOptionSelector({label = "Shop Slots", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 5), opt_callback = 'DeckCreatorModuleChangeShopSlots', current_option = (
                                                                                    Utils.getCurrentEditingDeck().config.shop_slots
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
                                                                        config = { align = "cm", padding = 0.1 },
                                                                        nodes = {
                                                                            Helper.createOptionSelector({label = "Consumable Slots", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeConsumableSlots', current_option = (
                                                                                    Utils.getCurrentEditingDeck().config.consumable_slot
                                                                            ), multiArrows = true }),
                                                                        }
                                                                    },
                                                                    {
                                                                        n = G.UIT.R,
                                                                        config = { align = "cm", padding = 0.1 },
                                                                        nodes = {
                                                                            Helper.createOptionSelector({label = "Ante Scaling", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 3), opt_callback = 'DeckCreatorModuleChangeAnteScaling', current_option = (
                                                                                    Utils.getCurrentEditingDeck().config.ante_scaling
                                                                            )}),
                                                                        }
                                                                    }
                                                                }
                                                            },
                                                        }
                                                    }
                                                   --[[ Helper.createOptionSelector({label = "Copy Deck Properties", scale = 0.8, options = Utils.allDeckNames(), opt_callback = 'DeckCreatorModuleChangeCopyFromDeck', current_option = (
                                                            Utils.getCurrentEditingDeck().config.copy_deck_config
                                                    ) }),]]
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
                                                                          Utils.getCurrentEditingDeck().config.dollars
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
                                                                          Utils.getCurrentEditingDeck().config.extra_hand_bonus
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
                                                                          Utils.getCurrentEditingDeck().config.interest_amount
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
                                                                  Helper.createOptionSelector({label = "Discount Percent", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeDiscountPercent', current_option = (
                                                                          Utils.getCurrentEditingDeck().config.discount_percent
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
                                                                            Utils.getCurrentEditingDeck().config.reroll_cost
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
                                                                            Utils.getCurrentEditingDeck().config.extra_discard_bonus
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
                                                                            Utils.getCurrentEditingDeck().config.interest_cap
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
                                                                            Utils.getCurrentEditingDeck().config.discard_cost
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
                                                            Utils.getCurrentEditingDeck().config.hands
                                                    ), multiArrows = true}),
                                                    Helper.createOptionSelector({label = "Number of Discards", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeNumDiscards', current_option = (
                                                            Utils.getCurrentEditingDeck().config.discards
                                                    ), multiArrows = true }),
                                                    Helper.createOptionSelector({label = "Hand Size", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 25), opt_callback = 'DeckCreatorModuleChangeHandSize', current_option = (
                                                            Utils.getCurrentEditingDeck().config.hand_size
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
                                                            Utils.getCurrentEditingDeck().config.joker_rate
                                                    ), multiArrows = true, minorArrows = true }),
                                                    Helper.createOptionSelector({label = "Tarot Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeTarotRate', current_option = (
                                                            Utils.getCurrentEditingDeck().config.tarot_rate
                                                    ), multiArrows = true, minorArrows = true }),
                                                    Helper.createOptionSelector({label = "Planet Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangePlanetRate', current_option = (
                                                            Utils.getCurrentEditingDeck().config.planet_rate
                                                    ), multiArrows = true, minorArrows = true }),
                                                    Helper.createOptionSelector({label = "Spectral Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangeSpectralRate', current_option = (
                                                            Utils.getCurrentEditingDeck().config.spectral_rate
                                                    ), multiArrows = true, minorArrows = true }),
                                                    Helper.createOptionSelector({label = "Playing Card Rate", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 100), opt_callback = 'DeckCreatorModuleChangePlayingCardRate', current_option = (
                                                            Utils.getCurrentEditingDeck().config.playing_card_rate
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
                                                preUpdateFunctions = {
                                                  init = GUI.dynamicDeckEditorPreUpdate
                                                },
                                                updateFunctions = {
                                                    dynamicDeckEditorAreaCards = G.FUNCS.DeckCreatorModuleUpdateDynamicDeckEditorAreaCards,
                                                    dynamicDeckEditorAreaDeckTables = G.FUNCS.DeckCreatorModuleUpdateDynamicDeckEditorAreaDeckTables
                                                },
                                                postUpdateFunctions = {
                                                    post = GUI.dynamicDeckEditorPostUpdate()
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
                                                preUpdateFunctions = {
                                                  init = GUI.dynamicStartingItemsPreUpdate
                                                },
                                                updateFunctions = {
                                                    dynamicStartingItemsAreaCards = G.FUNCS.DeckCreatorModuleUpdateDynamicStartingItemsAreaCards,
                                                    dynamicStartingItemsAreaDeckTables = G.FUNCS.DeckCreatorModuleUpdateDynamicStartingItemsAreaDeckTables
                                                },
                                                postUpdateFunctions = {
                                                    post = GUI.dynamicStartingItemsPostUpdate()
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
                                                                    create_toggle({label = "Double Tag on Boss win", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'double_tag'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Balance Chips and Mult", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'balance_chips'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "All Jokers Eternal", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'all_eternal'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Boosters cost $1 more per Ante", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'booster_ante_scaling'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Hold -1 cards in hand per $5", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'minus_hand_size_per_X_dollar'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Gain $1 per round for each\nof your Enhanced cards", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'one_dollar_for_each_enhanced_card'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Gain $10 when a Glass card breaks", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'ten_dollars_for_broken_glass'}),
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
                                                                    create_toggle({label = "1 in 4 cards are drawn face down", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'flipped_cards'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "All played cards become debuffed after scoring", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'debuff_played_cards'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Eternal Jokers appear in shop", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'enable_eternals_in_shop'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Chips cannot exceed current $", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'chips_dollar_cap'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Raise prices by $1 on every purchase", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'inflation'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Lose $1 per round for each Negative Joker", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'lose_one_dollar_per_negative_joker'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Receive random Negative Joker when a Glass card breaks", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'negative_joker_for_broken_glass'}),
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
                                                                    create_toggle({label = "No Face Cards", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'remove_faces'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Randomize Ranks and Suits", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_rank_suit'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Increase Starting Money ($0 - $100)", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_money_big'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Scramble All Money Settings", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_money'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Scramble Appearance Rate Settings", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_appearance_rates'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Randomize Suits", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_suits'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Start with 2 Random Jokers", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'two_random_jokers'}),
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
                                                                    create_toggle({label = "No Numbered Cards", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'no_numbered_cards'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Scramble Number of Hands & Discards", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_hands_discards'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Increase Starting Money ($0 - $20)", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_money_small'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Random Starting Items", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'random_starting_items'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Randomly Enable Gameplay Settings", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomly_enable_gameplay'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Randomize Ranks", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_ranks'}),
                                                                }
                                                            },
                                                            {
                                                                n = G.UIT.R,
                                                                config = {
                                                                    align = "cm",
                                                                    padding = 0.1
                                                                },
                                                                nodes = {
                                                                    create_toggle({label = "Start with 1 Random Voucher", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'one_random_voucher'}),
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
                UIBox_button({button = 'DeckCreatorModuleAddJokerMenu', label = {localize('b_jokers')}, count = G.DISCOVER_TALLIES.jokers,  minw = 5, minh = 1.7, scale = 0.6, id = 'your_collection_jokers'}),
                UIBox_button({button = 'DeckCreatorModuleAddTagMenu', label = {localize('b_tags')}, count = G.DISCOVER_TALLIES.tags, minw = 5, id = 'your_collection_tags'}),
                UIBox_button({button = 'DeckCreatorModuleAddVoucherMenu', label = {localize('b_vouchers')}, count = G.DISCOVER_TALLIES.vouchers, minw = 5, id = 'your_collection_vouchers'}),
                {n=G.UIT.R, config={align = "cm", padding = 0.1, r=0.2, colour = G.C.BLACK}, nodes={
                    {n=G.UIT.C, config={align = "cm", maxh=2.9}, nodes={
                        {n=G.UIT.T, config={text = localize('k_cap_consumables'), scale = 0.45, colour = G.C.L_BLACK, vert = true, maxh=2.2}},
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes={
                        UIBox_button({button = 'DeckCreatorModuleAddTarotMenu', label = {localize('b_tarot_cards')}, count = G.DISCOVER_TALLIES.tarots, minw = 4, id = 'your_collection_tarots', colour = G.C.SECONDARY_SET.Tarot}),
                        UIBox_button({button = 'DeckCreatorModuleAddPlanetMenu', label = {localize('b_planet_cards')}, count = G.DISCOVER_TALLIES.planets, minw = 4, id = 'your_collection_planets', colour = G.C.SECONDARY_SET.Planet}),
                        UIBox_button({button = 'DeckCreatorModuleAddSpectralMenu', label = {localize('b_spectral_cards')}, count = G.DISCOVER_TALLIES.spectrals, minw = 4, id = 'your_collection_spectrals', colour = G.C.SECONDARY_SET.Spectral}),
                    }}
                }}
            }}
        }
    })
end

function GUI.createManageDecksMenu()

    G.PROFILES[G.SETTINGS.profile].MEMORY.stake = G.PROFILES[G.SETTINGS.profile].MEMORY.stake or 1

    local ordered_names = {}
    local customDecks = 0
    local curIndex = 1
    local firstDeckUUID = #Utils.customDeckList > 0 and Utils.customDeckList[1].config and Utils.customDeckList[1].config.uuid or nil
    for k,v in ipairs(G.P_CENTER_POOLS.Back) do
        if v.config.customDeck and (firstDeckUUID == nil or v.config.uuid == firstDeckUUID) then
            local back = Back(v)
            G.GAME.viewed_back = back
            GUI.ManageDecksConfig.currentIndex = curIndex
            if firstDeckUUID == nil then
                firstDeckUUID = back.effect.config.uuid
            end
        end
        if v.config.customDeck then
            ordered_names[#ordered_names+1] = v.name
            customDecks = customDecks + 1
            curIndex = curIndex + 1
            table.insert(GUI.ManageDecksConfig.allCustomBacks, back)
        end
    end

    local area = CardArea(G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,G.CARD_W,G.CARD_H,{card_limit = 5, type = 'deck', highlight_limit = 0, deck_height = 0.75, thin_draw = 1})
    for i = 1, customDecks do
        local card = Card(G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h, G.CARD_W, G.CARD_H, pseudorandom_element(G.P_CARDS), G.P_CENTERS.c_base, {playing_card = i, viewed_back = true})
        card.sprite_facing = 'back'
        card.facing = 'back'
        area:emplace(card)
    end

    for k,v in pairs(G.P_CENTER_POOLS.Back) do
        if v and v.config and v.config.uuid == firstDeckUUID then
            G.GAME.viewed_back:change_to(v)
            G.PROFILES[G.SETTINGS.profile].MEMORY.deck = v.name
            break
        end
    end

    local t = {
        n=G.UIT.ROOT,
        config={align = "cm", colour = G.C.CLEAR, minh = 5, minw = 6, padding = 1 },
        nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 0.1, padding = 1, r = 0.1, colour = G.C.CLEAR },
                nodes = {}
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 3, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm", minh = 3.8}, nodes={
                        create_option_cycle({options =  ordered_names, opt_callback = 'DeckCreatorModuleChangeManageDeckViewedDeck', current_option = 1, colour = G.C.RED, w = 6, mid =
                        {n=G.UIT.R, config={align = "cm", minh = 3.3, minw = 6}, nodes={
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
                                }}
                            }}
                        }}
                        })
                    }},
                    {n=G.UIT.R, config={align = "cm", padding = 0.1 }, nodes={}},
                    {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                        {
                            n = G.UIT.C,
                            config = { align = "cm", minw = 0.2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                            nodes = {
                                {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                                    UIBox_button({
                                        label = {" Edit "},
                                        shadow = true,
                                        scale = 0.75 * 0.5,
                                        colour = G.C.GREEN,
                                        button = "DeckCreatorModuleEditDeck",
                                        minh = 0.8,
                                        minw = 3
                                    })
                                }}
                            }
                        },
                        {
                            n = G.UIT.C,
                            config = { align = "cm", minw = 0.2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                            nodes = {
                                {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                                    UIBox_button({
                                        label = {" Copy "},
                                        shadow = true,
                                        scale = 0.75 * 0.5,
                                        colour = G.C.BOOSTER,
                                        button = "DeckCreatorModuleCopyDeck",
                                        minh = 0.8,
                                        minw = 3
                                    })
                                }}
                            }
                        },
                        {
                            n = G.UIT.C,
                            config = { align = "cm", minw = 0.2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                            nodes = {
                                {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                                    UIBox_button({
                                        label = {" Delete "},
                                        shadow = true,
                                        scale = 0.75 * 0.5,
                                        colour = G.C.RED,
                                        button = "DeckCreatorModuleDeleteDeck",
                                        minh = 0.8,
                                        minw = 3
                                    })
                                }}
                            }
                        }
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 0.1, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {}
            },
        }
    }
    return create_UIBox_generic_options({
        back_func = "DeckCreatorModuleBackToMainMenu",
        contents = {
            {n=G.UIT.R, config={align = "cm", padding = 0, draw_layer = 1 }, nodes={
                t
            }}
        }
    })
end

function GUI.createBalamodMenu()
    local scale = 0.75
    return (create_UIBox_generic_options({
        back_func = "DeckCreatorModuleBackToModsScreen",
        contents = {
            {
                n = G.UIT.R,
                config = {
                    padding = 0,
                    align = "tm"
                },
                nodes = {
                    create_tabs({
                        snap_to_nav = true,
                        colour = G.C.BOOSTER,
                        tabs = {
                            {
                                label = "Deck Creator",
                                chosen = true,
                                tab_definition_function = function()
                                    local modNodes = {}


                                    -- Authors names in blue
                                    table.insert(modNodes, {
                                        n = G.UIT.R,
                                        config = {
                                            padding = 0,
                                            align = "cm",
                                            r = 0.1,
                                            emboss = 0.1,
                                            outline = 1,
                                            padding = 0.07
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    text = "Nyoxide",
                                                    shadow = true,
                                                    scale = scale * 0.65,
                                                    colour = G.C.BLUE,
                                                }
                                            }
                                        }
                                    })

                                    -- Mod description
                                    table.insert(modNodes, {
                                        n = G.UIT.R,
                                        config = {
                                            padding = 0.2,
                                            align = "cm"
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.T,
                                                config = {
                                                    text = Utils.modDescription(),
                                                    shadow = false,
                                                    scale = scale * 0.5,
                                                    colour = G.C.UI.TEXT_LIGHT
                                                }
                                            }
                                        }
                                    })

                                    for k,v in pairs(GUI.mainMenu()) do
                                        table.insert(modNodes, v)
                                    end

                                    return {
                                        n = G.UIT.ROOT,
                                        config = {
                                            emboss = 0.05,
                                            minh = 6,
                                            r = 0.1,
                                            minw = 6,
                                            align = "tm",
                                            padding = 0.2,
                                            colour = G.C.BLACK
                                        },
                                        nodes = modNodes
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

-- Base Deck
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
            Helper.deckEditorAreas[j] = nil
        end
    end
    Helper.deckEditorAreas = {}
    local memoryBefore = collectgarbage("count")
    collectgarbage("collect")
    if Utils.runMemoryChecks then
        local memoryAfter = collectgarbage("count")
        local diff = memoryAfter - memoryBefore
        Utils.log("MEMORY CHECK (Flush): " .. memoryBefore .. " -> " .. memoryAfter .. " (" .. diff .. ")")
    end
end

function GUI.dynamicDeckEditorPreUpdate()
    if GUI.OpenTab ~= "Base Deck" then
        return
    end
    GUI.flushDeckEditorAreas()
    CardUtils.getCardsFromCustomCardList(Utils.getCurrentEditingDeck().config.customCardList)
    remove_nils(G.playing_cards)
end

function GUI.dynamicDeckEditorPostUpdate()
    collectgarbage("collect")
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
                            colour = G.C.GREEN,
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
                            colour = G.C.RED,
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

    if GUI.OpenTab ~= "Base Deck" then
        return {
            n=G.UIT.C,
            config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
            nodes={}
        }
    end

    local flip_col = G.C.WHITE
    Helper.calculateDeckEditorSums()

    return {
        n=G.UIT.C,
        config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
        nodes={
            {
                n=G.UIT.C,
                config={align = "cm", padding = 0.1},
                nodes={
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
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            {n=G.UIT.C, config={align = "cm", padding = 0.07,force_focus = true,  focus_args = {type = 'tally_sprite'}, tooltip = {text = "All cards"}}, nodes={
                                {n=G.UIT.R, config={align = "cm"}, nodes={
                                    {n=G.UIT.T, config={text = "Total: " .. Helper.sums.total_cards,colour = flip_col, scale = 0.4, shadow = true}},
                                }},
                            }}
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

function GUI.dynamicDeckEditorAreaDeckTables()

    if GUI.OpenTab ~= "Base Deck" then
        return {
            n=G.UIT.ROOT,
            config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 11.4, minh = 4.2},
            nodes={}
        }
    end

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
    G.VIEWING_DECK = true
    G.GAME.blind = FakeBlind

    table.sort(G.playing_cards, function (a, b) return a:get_nominal('suit') > b:get_nominal('suit') end )

    for k, v in ipairs(G.playing_cards) do
        table.insert(SUITS[string.sub(v.base.suit, 1, 1)], v)
    end

    local xy = GUI.OpenTab == 'Base Deck' and 0 or 9999

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
    GUI.dynamicDeckEditorPreUpdate()
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicDeckEditorAreaCards"] = GUI.dynamicDeckEditorAreaCards()
    })
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicDeckEditorAreaDeckTables"] = GUI.dynamicDeckEditorAreaDeckTables()
    })
    GUI.dynamicDeckEditorPostUpdate()
end

-- Starting Items
function GUI.dynamicStartingItemsPreUpdate()
    GUI.flushDeckEditorAreas()
    if GUI.OpenTab ~= "Starting Items" then
        return
    end

    local jokerList = Utils.getCurrentEditingDeck().config.customJokerList
    local tarotList = Utils.getCurrentEditingDeck().config.customTarotList
    local planetList = Utils.getCurrentEditingDeck().config.customPlanetList
    local spectralList = Utils.getCurrentEditingDeck().config.customSpectralList
    local voucherList = Utils.getCurrentEditingDeck().config.customVoucherList
    CardUtils.getJokersFromCustomJokerList(jokerList)
    CardUtils.getTarotsFromCustomTarotList(tarotList)
    CardUtils.getPlanetsFromCustomPlanetList(planetList)
    CardUtils.getSpectralsFromCustomSpectralList(spectralList)
    CardUtils.getVouchersFromCustomVoucherList(voucherList)
    remove_nils(CardUtils.startingItems.jokers)
    remove_nils(CardUtils.startingItems.tarots)
    remove_nils(CardUtils.startingItems.planets)
    remove_nils(CardUtils.startingItems.spectrals)
    remove_nils(CardUtils.startingItems.vouchers)
    remove_nils(CardUtils.startingItems.tags)
end

function GUI.dynamicStartingItemsPostUpdate()
    collectgarbage("collect")
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
                config = { align = "cm", padding = 0.2 },
                nodes = {}
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
                            colour = G.C.GREEN,
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
                            colour = G.C.RED,
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
    if GUI.OpenTab ~= "Starting Items" then
        return {
            n=G.UIT.C,
            config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
            nodes={}
        }
    end

    local flip_col = G.C.WHITE
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
                            Helper.tally_item_sprite({ x = 1, y = 0 }, { { string = Helper.sums.item_tallies['Joker'], colour = flip_col }, { string = Helper.sums.item_tallies['Joker'], colour = G.C.BLUE } }, { "Jokers" }),
                            Helper.tally_item_sprite({ x = 2, y = 0 }, { { string = (Helper.sums.item_tallies['Planet'] or 0) + (Helper.sums.item_tallies['Tarot'] or 0) + (Helper.sums.item_tallies['Spectral'] or 0), colour = flip_col }, { string = (Helper.sums.item_tallies['Planet'] or 0) + (Helper.sums.item_tallies['Tarot'] or 0) + (Helper.sums.item_tallies['Spectral'] or 0), colour = G.C.BLUE } }, { "Consumable" }),
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.item_tallies['Voucher'], colour = flip_col }, { string = Helper.sums.item_tallies['Voucher'], colour = G.C.BLUE } }, { "Vouchers" }),
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 3, y = 1 }, { { string = Helper.sums.item_tallies['Joker'], colour = flip_col }, { string = Helper.sums.item_tallies['Joker'], colour = G.C.BLUE } }, { "Jokers" }),
                            Helper.tally_item_sprite({ x = 0, y = 1 }, { { string = Helper.sums.item_tallies['Planet'], colour = flip_col }, { string = Helper.sums.item_tallies['Planet'], colour = G.C.BLUE } }, { "Planets" }),
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.item_tallies['Tarot'], colour = flip_col }, { string = Helper.sums.item_tallies['Tarot'], colour = G.C.BLUE } }, { "Tarots" }),
                            Helper.tally_item_sprite({ x = 1, y = 1 }, { { string = Helper.sums.item_tallies['Voucher'], colour = flip_col }, { string = Helper.sums.item_tallies['Voucher'], colour = G.C.BLUE } }, { "Vouchers" }),
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.item_tallies['Spectral'], colour = flip_col }, { string = Helper.sums.item_tallies['Spectral'], colour = G.C.BLUE } }, { "Spectrals" }),
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

    if GUI.OpenTab ~= "Starting Items" then
        return {
            n=G.UIT.ROOT,
            config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 11.4, minh = 4.2},
            nodes={}
        }
    end

    local deck_tables = {}
    local FakeBlind = {}
    function FakeBlind:debuff_card(arg) end

    G.VIEWING_DECK = true
    G.GAME.blind = FakeBlind

    local xy = GUI.OpenTab == 'Starting Items' and 0 or 9999

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
    for i = 1, #CardUtils.startingItems.tarots do
        if CardUtils.startingItems.tarots[i] then
            local base = CardUtils.startingItems.tarots[i]
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
    for i = 1, #CardUtils.startingItems.planets do
        if CardUtils.startingItems.planets[i] then
            local base = CardUtils.startingItems.planets[i]
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
    for i = 1, #CardUtils.startingItems.spectrals do
        if CardUtils.startingItems.spectrals[i] then
            local base = CardUtils.startingItems.spectrals[i]
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

    -- output
    G.GAME.blind = nil
    return {
        n=G.UIT.ROOT,
        config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 11.4, minh = 4.2},
        nodes=deck_tables
    }
end

function GUI.updateAllStartingItemsAreas()
    GUI.dynamicStartingItemsPreUpdate()
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicStartingItemsAreaCards"] = GUI.dynamicStartingItemsAreaCards()
    })
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicStartingItemsAreaDeckTables"] = GUI.dynamicStartingItemsAreaDeckTables()
    })
    GUI.dynamicStartingItemsPostUpdate()
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

function GUI.addJokerMenu()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 3 do
        G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                5*G.CARD_W,
                0.95*G.CARD_H,
                {card_limit = 5, type = 'title', highlight_limit = 0, collection = true})
        table.insert(deck_tables,
                {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
                    {n=G.UIT.O, config={object = G.your_collection[j]}}
                }}
        )
    end

    local joker_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Joker/(5*#G.your_collection)) do
        table.insert(joker_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Joker/(5*#G.your_collection))))
    end

    for i = 1, 5 do
        for j = 1, #G.your_collection do
            local center = G.P_CENTER_POOLS["Joker"][i+(j-1)*5]
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
            card.sticker = get_joker_win_sticker(center)
            G.your_collection[j]:emplace(card)
        end
    end

    local t =  create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenAddItemToDeck', contents = {
        {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = joker_options, w = 2.5, cycle_shoulders = true, opt_callback = 'your_collection_joker_page', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        Helper.createOptionSelector({label = "Copies", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 99), opt_callback = 'DeckCreatorModuleChangeOpenStartingItemConfigCopies', current_option = (
                                GUI.OpenStartingItemConfig.copies
                        ), multiArrows = true, minorArrows = true })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        Helper.createOptionSelector({label = "Edition", scale = 0.8, options = Utils.editions(true, true), opt_callback = 'DeckCreatorModuleChangeOpenStartingItemConfigEdition', current_option = (
                                GUI.OpenStartingItemConfig.edition
                        )})
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_toggle({label = "Eternal", ref_table = GUI.OpenStartingItemConfig, ref_value = 'eternal'}),
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_toggle({label = "Pinned", ref_table = GUI.OpenStartingItemConfig, ref_value = 'pinned'}),
                    }}
                }
            }
        }}
    }})
    return t
end

function GUI.addTarotMenu()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                (4.25+j)*G.CARD_W,
                1*G.CARD_H,
                {card_limit = 4 + j, type = 'title', highlight_limit = 0, collection = true})
        table.insert(deck_tables,
                {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
                    {n=G.UIT.O, config={object = G.your_collection[j]}}
                }}
        )
    end

    local tarot_options = {}
    for i = 1, math.floor(#G.P_CENTER_POOLS.Tarot/11) do
        table.insert(tarot_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.floor(#G.P_CENTER_POOLS.Tarot/11)))
    end

    for j = 1, #G.your_collection do
        for i = 1, 4+j do
            local center = G.P_CENTER_POOLS["Tarot"][i+(j-1)*(5)]
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
            card:start_materialize(nil, i>1 or j>1)
            G.your_collection[j]:emplace(card)
        end
    end

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenAddItemToDeck', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = tarot_options, w = 2.5, cycle_shoulders = true, opt_callback = 'your_collection_tarot_page', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        Helper.createOptionSelector({label = "Copies", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 99), opt_callback = 'DeckCreatorModuleChangeOpenStartingItemConfigCopies', current_option = (
                                GUI.OpenStartingItemConfig.copies
                        ), multiArrows = true, minorArrows = true })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        Helper.createOptionSelector({label = "Edition", scale = 0.8, options = { "None", "Negative", "Random" }, opt_callback = 'DeckCreatorModuleChangeOpenStartingItemConfigEdition', current_option = (
                                GUI.OpenStartingItemConfig.edition
                        )})
                    }}
                }
            }
        }}
    }})
    return t
end

function GUI.addPlanetMenu()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                (6.25)*G.CARD_W,
                1*G.CARD_H,
                {card_limit = 6, type = 'title', highlight_limit = 0, collection = true})
        table.insert(deck_tables,
                {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
                    {n=G.UIT.O, config={object = G.your_collection[j]}}
                }}
        )
    end

    for j = 1, #G.your_collection do
        for i = 1, 6 do
            local center = G.P_CENTER_POOLS["Planet"][i+(j-1)*(6)]
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
            card:start_materialize(nil, i>1 or j>1)
            G.your_collection[j]:emplace(card)
        end
    end

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenAddItemToDeck', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm", padding = 0.7}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        Helper.createOptionSelector({label = "Copies", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 99), opt_callback = 'DeckCreatorModuleChangeOpenStartingItemConfigCopies', current_option = (
                                GUI.OpenStartingItemConfig.copies
                        ), multiArrows = true, minorArrows = true })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        Helper.createOptionSelector({label = "Edition", scale = 0.8, options = { "None", "Negative", "Random" }, opt_callback = 'DeckCreatorModuleChangeOpenStartingItemConfigEdition', current_option = (
                                GUI.OpenStartingItemConfig.edition
                        )})
                    }}
                }
            }
        }}
    }})
    return t
end

function GUI.addSpectralMenu()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                (3.25+j)*G.CARD_W,
                1*G.CARD_H,
                {card_limit = 3+j, type = 'title', highlight_limit = 0, collection = true})
        table.insert(deck_tables,
                {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
                    {n=G.UIT.O, config={object = G.your_collection[j]}}
                }}
        )
    end

    for j = 1, #G.your_collection do
        for i = 1, 3+j do
            local center = G.P_CENTER_POOLS["Spectral"][i+(j-1)*3 + j - 1]

            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
            card:start_materialize(nil, i>1 or j>1)
            G.your_collection[j]:emplace(card)
        end
    end

    local spectral_options = {}
    for i = 1, math.floor(#G.P_CENTER_POOLS.Tarot/9) do
        table.insert(spectral_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.floor(#G.P_CENTER_POOLS.Spectral/9)))
    end

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenAddItemToDeck', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = spectral_options, w = 4.5, cycle_shoulders = true, opt_callback = 'your_collection_spectral_page', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        Helper.createOptionSelector({label = "Copies", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 99), opt_callback = 'DeckCreatorModuleChangeOpenStartingItemConfigCopies', current_option = (
                                GUI.OpenStartingItemConfig.copies
                        ), multiArrows = true, minorArrows = true })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        Helper.createOptionSelector({label = "Edition", scale = 0.8, options = { "None", "Negative", "Random" }, opt_callback = 'DeckCreatorModuleChangeOpenStartingItemConfigEdition', current_option = (
                                GUI.OpenStartingItemConfig.edition
                        )})
                    }}
                }
            }
        }}
    }})
    return t
end

function GUI.addTagMenu()
    local tag_matrix = {
        {},{},{},{},
    }
    local tag_tab = {}
    for k, v in pairs(G.P_TAGS) do
        tag_tab[#tag_tab+1] = v
    end

    table.sort(tag_tab, function (a, b) return a.order < b.order end)

    local tags_to_be_alerted = {}
    for k, v in ipairs(tag_tab) do
        local discovered = v.discovered
        local temp_tag = Tag(v.key, true)
        if not v.discovered then temp_tag.hide_ability = true end
        local temp_tag_ui, temp_tag_sprite = temp_tag:generate_UI()
        tag_matrix[math.ceil((k-1)/6+0.001)][1+((k-1)%6)] = {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
            temp_tag_ui,
        }}
        if discovered and not v.alerted then
            tags_to_be_alerted[#tags_to_be_alerted+1] = temp_tag_sprite
        end
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = (function()
            for _, v in ipairs(tags_to_be_alerted) do
                v.children.alert = UIBox{
                    definition = create_UIBox_card_alert(),
                    config = { align="tri", offset = {x = 0.1, y = 0.1}, parent = v}
                }
                v.children.alert.states.collide.can = false
            end
            return true
        end)
    }))


    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenAddItemToDeck', contents = {
        {n=G.UIT.C, config={align = "cm", r = 0.1, colour = G.C.BLACK, padding = 0.1, emboss = 0.05}, nodes={
            {n=G.UIT.C, config={align = "cm"}, nodes={
                {n=G.UIT.R, config={align = "cm"}, nodes={
                    {n=G.UIT.R, config={align = "cm"}, nodes=tag_matrix[1]},
                    {n=G.UIT.R, config={align = "cm"}, nodes=tag_matrix[2]},
                    {n=G.UIT.R, config={align = "cm"}, nodes=tag_matrix[3]},
                    {n=G.UIT.R, config={align = "cm"}, nodes=tag_matrix[4]},
                }}
            }}
        }}
    }})
    return t
end

return GUI
