local Persistence = require "Persistence"
local Utils = require "Utils"
local CustomDeck = require "CustomDeck"
local Helper = require "GuiElementHelper"
local CardUtils = require "CardUtils"
local ModloaderHelper = require "ModloaderHelper"
local StaticMod = require "StaticMod"

local GUI = {}

GUI.OpenTab = nil
GUI.DynamicUIManager = {}
GUI.DeckCreatorOpen = false
GUI.StartingItemsOpen = false
GUI.BannedItemsOpen = false
GUI.StartingItemsConfig = {
    BlindRowPage = 1,
    TagRowPage = 1,
}
GUI.BannedItemsConfig = {
    BlindRowPage = 1,
    TagRowPage = 1,
}
GUI.ManageDecksConfig = {
    manageDecksOpen = false,
    allCustomBacks = {},
    currentIndex = 1
}
GUI.StaticModsCurrentPageName = "Gameplay";
GUI.StaticModsObjects = {}
GUI.StaticMods = {}
GUI.JokersPerPage = 10

function GUI.closeAllHoveredObjects()
    Utils.hoveredTagStartingItemsAddToItemsKey = nil
    Utils.hoveredTagStartingItemsAddToItemsSprite = nil
    Utils.hoveredTagStartingItemsRemoveKey = nil
    Utils.hoveredTagStartingItemsRemoveUUID = nil
    Utils.hoveredTagStartingItemsRemoveSprite = nil

    Utils.hoveredTagBanItemsAddToBanKey = nil
    Utils.hoveredTagBanItemsAddToBanSprite = nil
    Utils.hoveredTagBanItemsRemoveKey = nil
    Utils.hoveredTagBanItemsRemoveSprite = nil
    Utils.hoveredBlindBanItemsAddToBanKey = nil
    Utils.hoveredBlindBanItemsAddToBanSprite = nil
    Utils.hoveredBlindBanItemsRemoveKey = nil
    Utils.hoveredBlindBanItemsRemoveSprite = nil
end

function GUI.CloseAllOpenFlags()
    GUI.DeckCreatorOpen = false
    GUI.StartingItemsOpen = false
    GUI.BannedItemsOpen = false
    GUI.closeAllHoveredObjects()
    GUI.resetOpenStartingItemConfig()
    GUI.resetOpenBannedItemConfig()
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
    elseif tab == "Banned Items" then
        GUI.BannedItemsOpen = true
    end
end

function GUI.resetOpenStartingItemConfig()
    GUI.OpenStartingItemConfig = {}
    GUI.OpenStartingItemConfig.openItemType = nil
    GUI.OpenStartingItemConfig.edition = "None"
    GUI.OpenStartingItemConfig.copies = 1
    GUI.OpenStartingItemConfig.pinned = false
    GUI.OpenStartingItemConfig.eternal = false
    GUI.OpenStartingItemConfig.rental = false
    GUI.OpenStartingItemConfig.perishable = false
end
function GUI.resetOpenBannedItemConfig()
    GUI.OpenBannedItemConfig = {}
    GUI.OpenBannedItemConfig.openItemType = nil
    GUI.OpenBannedItemConfig.edition = "None"
    GUI.OpenBannedItemConfig.copies = 1
    GUI.OpenBannedItemConfig.pinned = false
    GUI.OpenBannedItemConfig.eternal = false
end
GUI.resetOpenStartingItemConfig()
GUI.resetOpenBannedItemConfig()

function GUI.registerGlobals()
    G.FUNCS.DeckCreatorModuleEmptyFunc = function() end

    G.FUNCS.DeckCreatorModuleOpenGithub = function()
        love.system.openURL("https://github.com/adambennett/Balatro-DeckCreator")
    end

    if ModloaderHelper.SteamoddedLoaded then
        local OpenModUI = G.FUNCS.openModUI_ADeckCreatorModule
        if OpenModUI then
            G.FUNCS.openModUI_ADeckCreatorModule = function(args)
                ModloaderHelper.ModsMenuOpenedBy = 'Steamodded'
                OpenModUI(args)
            end
        end
    end

    G.FUNCS.DeckCreatorModuleChangeShopJokersPageLeft = function(args)
        CardUtils.removeAllJokersFromShop()

        Utils.currentShopJokerPage = Utils.currentShopJokerPage - 1
        if Utils.currentShopJokerPage < 1 then
            Utils.currentShopJokerPage = Utils.maxShopJokerPages
        end
        CardUtils.addFourJokersToShop()
    end

    G.FUNCS.DeckCreatorModuleChangeShopJokersPageRight = function(args)
        CardUtils.removeAllJokersFromShop()

        Utils.currentShopJokerPage = Utils.currentShopJokerPage + 1
        if Utils.currentShopJokerPage > Utils.maxShopJokerPages then
            Utils.currentShopJokerPage = 1
        end
        CardUtils.addFourJokersToShop()
    end

    G.FUNCS.DeckCreatorModuleYourCollectionPlanetPage = function(args)
        if not args or not args.cycle_config then return end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards, 1, -1 do
                local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
                c:remove()
                c = nil
            end
        end

        for j = 1, #G.your_collection do
            for i = 1, 6 do
                local center = G.P_CENTER_POOLS["Planet"][i + (j - 1) * (6) + (12 * (args.cycle_config.current_option - 1))]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w / 2, G.your_collection[j].T.y, G
                        .CARD_W, G.CARD_H, G.P_CARDS.empty, center)
                card:start_materialize(nil, i > 1 or j > 1)
                G.your_collection[j]:emplace(card)
                GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedPlanetList'), card)
            end
        end
        INIT_COLLECTION_CARD_ALERTS()
    end

    G.FUNCS.DeckCreatorModuleStartingJokersChangePage = function(args)
        if not args or not args.cycle_config then return end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards,1, -1 do
                local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
                c:remove()
                c = nil
            end
        end
        for i = 1, GUI.JokersPerPage do
            for j = 1, #G.your_collection do
                local center = G.P_CENTER_POOLS["Joker"][i+(j-1)*GUI.JokersPerPage + (GUI.JokersPerPage*#G.your_collection*(args.cycle_config.current_option - 1))]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
                card.sticker = get_joker_win_sticker(center)
                G.your_collection[j]:emplace(card)
                GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedJokerList'), card)
            end
        end
    end

    G.FUNCS.DeckCreatorModuleChangeVoucherPage = function(args)
        if not args or not args.cycle_config then return end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards,1, -1 do
                local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
                c:remove()
                c = nil
            end
        end
        for i = 1, 4 do
            for j = 1, #G.your_collection do
                local center = G.P_CENTER_POOLS["Voucher"][i+(j-1)*4 + (8*(args.cycle_config.current_option - 1))]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
                card:start_materialize(nil, i>1 or j>1)
                G.your_collection[j]:emplace(card)
                GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedVoucherList'), card)
            end
        end
    end

    G.FUNCS.DeckCreatorModuleChangeTarotPage = function(args)
        if not args or not args.cycle_config then return end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards,1, -1 do
                local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
                c:remove()
                c = nil
            end
        end

        for j = 1, #G.your_collection do
            for i = 1, 4+j do
                local center = G.P_CENTER_POOLS["Tarot"][i+(j-1)*(5) + (11*(args.cycle_config.current_option - 1))]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
                card:start_materialize(nil, i>1 or j>1)
                G.your_collection[j]:emplace(card)
                GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedTarotList'), card)
            end
        end
    end

    G.FUNCS.DeckCreatorModuleChangeSpectralPage = function(args)
        if not args or not args.cycle_config then return end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards,1, -1 do
                local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
                c:remove()
                c = nil
            end
        end

        for j = 1, #G.your_collection do
            for i = 1, 3+j do
                local center = G.P_CENTER_POOLS["Spectral"][i+(j-1)*(4) + (9*(args.cycle_config.current_option - 1))]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center)
                card:start_materialize(nil, i>1 or j>1)
                G.your_collection[j]:emplace(card)
                GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedSpectralList'), card)
            end
        end
    end

    G.FUNCS.DeckCreatorModuleChangeBoosterPage = function(args)
        if not args or not args.cycle_config then return end
        for j = 1, #G.your_collection do
            for i = #G.your_collection[j].cards,1, -1 do
                local c = G.your_collection[j]:remove_card(G.your_collection[j].cards[i])
                c:remove()
                c = nil
            end
        end

        for j = 1, #G.your_collection do
            for i = 1, 4 do
                local center = G.P_CENTER_POOLS["Booster"][i+(j-1)*4 + (8*(args.cycle_config.current_option - 1))]
                if not center then break end
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*1.27, G.CARD_H*1.27, nil, center)
                card:start_materialize(nil, i>1 or j>1)
                G.your_collection[j]:emplace(card)
                GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedBoosterList'), card)
            end
        end
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

        local copy = CustomDeck.fullNewFromExisting(copyFrom, { [1] = copyFrom.config.rawDescription }, true)

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
        GUI.addCard = GUI.resetAddCard()
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
        Utils.EditDeckConfig.deck = CustomDeck.fullNewFromExisting(deck, { [1] = deck.config.rawDescription }, false)

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
        GUI.addCard = GUI.resetAddCard()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Main Menu")
        })
    end

    G.FUNCS.DeckCreatorModuleChangeStartingTagRowPageRight = function(args)
        GUI.StartingItemsConfig.TagRowPage = GUI.StartingItemsConfig.TagRowPage + 1
        if GUI.StartingItemsConfig.TagRowPage > math.ceil(#CardUtils.startingItems.tags / Utils.startingTagsPerPage) then
            GUI.StartingItemsConfig.TagRowPage = 1
        end
        GUI.updateAllStartingItemsAreas()
    end

    G.FUNCS.DeckCreatorModuleChangeStartingTagRowPageLeft = function(args)
        GUI.StartingItemsConfig.TagRowPage = GUI.StartingItemsConfig.TagRowPage - 1
        if GUI.StartingItemsConfig.TagRowPage < 1 then
            GUI.StartingItemsConfig.TagRowPage = math.ceil(#CardUtils.startingItems.tags / Utils.startingTagsPerPage)
        end

        if GUI.StartingItemsConfig.TagRowPage < 1 then
            GUI.StartingItemsConfig.TagRowPage = 1
        end
        GUI.updateAllStartingItemsAreas()
    end

    G.FUNCS.DeckCreatorModuleChangeBannedTagRowPageRight = function(args)
        GUI.BannedItemsConfig.TagRowPage = GUI.BannedItemsConfig.TagRowPage + 1
        if GUI.BannedItemsConfig.TagRowPage > math.ceil(#CardUtils.bannedItems.tags / Utils.bannedTagsPerPage) then
            GUI.BannedItemsConfig.TagRowPage = 1
        end
        GUI.updateAllBannedItemsAreas()
    end

    G.FUNCS.DeckCreatorModuleChangeBannedTagRowPageLeft = function(args)
        GUI.BannedItemsConfig.TagRowPage = GUI.BannedItemsConfig.TagRowPage - 1
        if GUI.BannedItemsConfig.TagRowPage < 1 then
            GUI.BannedItemsConfig.TagRowPage = math.ceil(#CardUtils.bannedItems.tags / Utils.bannedTagsPerPage)
        end

        if GUI.BannedItemsConfig.TagRowPage < 1 then
            GUI.BannedItemsConfig.TagRowPage = 1
        end
        GUI.updateAllBannedItemsAreas()
    end

    G.FUNCS.DeckCreatorModuleChangeBannedBlindRowPageRight = function(args)
        GUI.BannedItemsConfig.BlindRowPage = GUI.BannedItemsConfig.BlindRowPage + 1
        if GUI.BannedItemsConfig.BlindRowPage > math.ceil(#CardUtils.bannedItems.blinds / Utils.bannedBlindsPerPage) then
            GUI.BannedItemsConfig.BlindRowPage = 1
        end
        GUI.updateAllBannedItemsAreas()
    end

    G.FUNCS.DeckCreatorModuleChangeBannedBlindRowPageLeft = function(args)
        GUI.BannedItemsConfig.BlindRowPage = GUI.BannedItemsConfig.BlindRowPage - 1
        if GUI.BannedItemsConfig.BlindRowPage < 1 then
            GUI.BannedItemsConfig.BlindRowPage = math.ceil(#CardUtils.bannedItems.blinds / Utils.bannedBlindsPerPage)
        end

        if GUI.BannedItemsConfig.BlindRowPage < 1 then
            GUI.BannedItemsConfig.BlindRowPage = 1
        end
        GUI.updateAllBannedItemsAreas()
    end

    --[[GUI.DeckCreatorModuleSetBannedBlindRowPage = function(page)
        local totalPages = math.ceil(#CardUtils.bannedItems.blinds / Utils.bannedBlindsPerPage)
        local originalPage = GUI.BannedItemsConfig.BlindRowPage
        GUI.BannedItemsConfig.BlindRowPage = page
        if GUI.BannedItemsConfig.BlindRowPage < 1 then
            GUI.BannedItemsConfig.BlindRowPage = totalPages
        end
        if GUI.BannedItemsConfig.BlindRowPage > totalPages then
            GUI.BannedItemsConfig.BlindRowPage = 1
        end

        if originalPage ~= GUI.BannedItemsConfig.BlindRowPage then
            GUI.updateAllBannedItemsAreas()
        end
    end]]

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

        table.insert(Utils.deletedSlugs, { slug = G.GAME.viewed_back.effect.center.key, order = G.GAME.viewed_back.effect.center.order })
        CustomDeck.unregister(matchUUID)
        Persistence.refreshDeckList()
        Persistence.saveAllDecks()
        if #Utils.customDeckList < 1 then
           -- GUI.redrawMainMenu()
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

    G.FUNCS.DeckCreatorModuleChangeStaticModsPage = function(args)
        if not args or not args.cycle_config then return end
        GUI.updateAllStaticModAreas(args.cycle_config.current_option)
    end

    G.FUNCS.DeckCreatorModuleChangeDynamicModsPage = function(args)
        if not args or not args.cycle_config then return end
        GUI.updateAllDynamicModAreas(args.cycle_config.current_option)
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

    G.FUNCS.DeckCreatorModuleUpdateDynamicBannedItemsAreaCards = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["dynamicBannedItemsAreaCards"] = GUI.dynamicBannedItemsAreaCards()
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicBannedItemsAreaDeckTables = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["dynamicBannedItemsAreaDeckTables"] = GUI.dynamicBannedItemsAreaDeckTables()
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicStaticModsTitle = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["staticModsTitle"] = GUI.dynamicStaticModsTitle()
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicStaticModsColumnOne = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["staticModsColumnOne"] = GUI.dynamicStaticModsGenerateColumn(1)
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicStaticModsColumnTwo = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["staticModsColumnTwo"] = GUI.dynamicStaticModsGenerateColumn(2)
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicDynamicModsColumnOne = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["dynamicModsColumnOne"] = GUI.dynamicDynamicModsColumnOne()
        })
    end

    G.FUNCS.DeckCreatorModuleUpdateDynamicDynamicModsColumnTwo = function(args)
        GUI.DynamicUIManager.updateDynamicAreas({
            ["dynamicModsColumnTwo"] = GUI.dynamicDynamicModsColumnTwo()
        })
    end

    G.FUNCS.DeckCreatorModuleAddCard = function()
        CardUtils.addCardToDeck(GUI.addCard)
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

    G.FUNCS.DeckCreatorModuleOpenBanItem = function ()
        GUI.resetOpenBannedItemConfig()
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu({
            definition = GUI.createSelectBanItemTypeMenu()
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

    G.FUNCS.DeckCreatorModuleBanVoucherMenu = function()
        GUI.OpenBannedItemConfig.openItemType = 'voucher'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedVoucherMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleBanJokerMenu = function()
        GUI.OpenBannedItemConfig.openItemType = 'joker'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedJokerMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleBanTarotMenu = function()
        GUI.OpenBannedItemConfig.openItemType = 'tarot'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedTarotMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleBanPlanetMenu = function()
        GUI.OpenBannedItemConfig.openItemType = 'planet'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedPlanetMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleBanSpectralMenu = function()
        GUI.OpenBannedItemConfig.openItemType = 'spectral'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedSpectralMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleBanTagMenu = function()
        GUI.OpenBannedItemConfig.openItemType = 'tag'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedTagMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleBanBlindMenu = function()
        GUI.OpenBannedItemConfig.openItemType = 'blind'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedBlindMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleBanBoosterMenu = function()
        GUI.OpenBannedItemConfig.openItemType = 'booster'
        G.SETTINGS.paused = true
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedBoosterMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleGenerateCard = function()
        CardUtils.addCardToDeck({
            rank = "Random",
            suit = "Random",
            edition = "Random",
            enhancement = "Random",
            seal = "Random",
            copies = 1
        })
        Utils.getCurrentEditingDeck().config.custom_cards_set = true
        GUI.updateAllDeckEditorAreas()
    end

    G.FUNCS.DeckCreatorModuleGenerateItem = function()
        CardUtils.addItemToDeck({ isRandomType = true })
        Utils.getCurrentEditingDeck().config.custom_cards_set = true
        GUI.updateAllStartingItemsAreas()
    end

    G.FUNCS.DeckCreatorModuleBanRandomItem = function()
        CardUtils.banItem({ isRandomType = true })
        GUI.updateAllBannedItemsAreas()
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
        Utils.getCurrentEditingDeck().config.customTagList = {}
        Utils.getCurrentEditingDeck().config.custom_vouchers_set = false
        Utils.getCurrentEditingDeck().config.custom_jokers_set = false
        Utils.getCurrentEditingDeck().config.custom_tarots_set = false
        Utils.getCurrentEditingDeck().config.custom_planets_set = false
        Utils.getCurrentEditingDeck().config.custom_spectrals_set = false
        Utils.getCurrentEditingDeck().config.custom_tags_set = false
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

    G.FUNCS.DeckCreatorModuleBanAllVouchers = function()
        for k,v in pairs(G.P_CENTER_POOLS["Voucher"]) do
            CardUtils.banItem({ voucher = true, ref = 'bannedVoucherList', addCard = v.key})
        end
        GUI.runBanAllFlips()
    end
    G.FUNCS.DeckCreatorModuleBanAllJokers = function()
        for k,v in pairs(G.P_CENTER_POOLS["Joker"]) do
            CardUtils.banItem({ joker = true, ref = 'bannedJokerList', addCard = v.key})
        end
        GUI.runBanAllFlips()
    end
    G.FUNCS.DeckCreatorModuleBanAllTarots = function()
        for k,v in pairs(G.P_CENTER_POOLS["Tarot"]) do
            CardUtils.banItem({ tarot = true, ref = 'bannedTarotList', addCard = v.key})
        end
        GUI.runBanAllFlips()
    end
    G.FUNCS.DeckCreatorModuleBanAllPlanets = function()
        for k,v in pairs(G.P_CENTER_POOLS["Planet"]) do
            CardUtils.banItem({ planet = true, ref = 'bannedPlanetList', addCard = v.key})
        end
        GUI.runBanAllFlips()
    end
    G.FUNCS.DeckCreatorModuleBanAllSpectrals = function()
        for k,v in pairs(G.P_CENTER_POOLS["Spectral"]) do
            CardUtils.banItem({ spectral = true, ref = 'bannedSpectralList', addCard = v.key})
        end
        GUI.runBanAllFlips()
    end
    G.FUNCS.DeckCreatorModuleBanAllTags = function()
        for k,v in pairs(G.P_TAGS) do
            CardUtils.banItem({ tarot = true, ref = 'bannedTagList', addCard = k })
        end
    end
    G.FUNCS.DeckCreatorModuleBanAllBlinds = function()
        for k,v in pairs(G.P_BLINDS) do
            CardUtils.banItem({ blind = true, ref = 'bannedBlindList', addCard = v.name })
        end
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedBlindMenu()
        }
    end
    G.FUNCS.DeckCreatorModuleBanAllBoosters = function()
        for k,v in pairs(G.P_CENTER_POOLS["Booster"]) do
            CardUtils.banItem({ booster = true, ref = 'bannedBoosterList', addCard = v.key})
        end
        GUI.runBanAllFlips()
    end

    G.FUNCS.DeckCreatorModuleUnbanAllVouchers = function()
        Utils.getCurrentEditingDeck().config.bannedVoucherList = {}
        if CardUtils.bannedItems.vouchers and #CardUtils.bannedItems.vouchers > 0 then
            for j = 1, #CardUtils.bannedItems.vouchers do
                local c = CardUtils.bannedItems.vouchers[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.bannedItems.vouchers = {}
        GUI.runUnbannedFlips()
    end

    G.FUNCS.DeckCreatorModuleUnbanAllJokers = function()
        Utils.getCurrentEditingDeck().config.bannedJokerList = {}
        if CardUtils.bannedItems.jokers and #CardUtils.bannedItems.jokers > 0 then
            for j = 1, #CardUtils.bannedItems.jokers do
                local c = CardUtils.bannedItems.jokers[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.bannedItems.jokers = {}
        GUI.runUnbannedFlips()
    end

    G.FUNCS.DeckCreatorModuleUnbanAllTarots = function()
        Utils.getCurrentEditingDeck().config.bannedTarotList = {}
        if CardUtils.bannedItems.tarots and #CardUtils.bannedItems.tarots > 0 then
            for j = 1, #CardUtils.bannedItems.tarots do
                local c = CardUtils.bannedItems.tarots[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.bannedItems.tarots = {}
        GUI.runUnbannedFlips()
    end

    G.FUNCS.DeckCreatorModuleUnbanAllPlanets = function()
        Utils.getCurrentEditingDeck().config.bannedPlanetList = {}
        if CardUtils.bannedItems.planets and #CardUtils.bannedItems.planets > 0 then
            for j = 1, #CardUtils.bannedItems.planets do
                local c = CardUtils.bannedItems.planets[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.bannedItems.planets = {}
        GUI.runUnbannedFlips()
    end

    G.FUNCS.DeckCreatorModuleUnbanAllSpectrals = function()
        Utils.getCurrentEditingDeck().config.bannedSpectralList = {}
        if CardUtils.bannedItems.spectrals and #CardUtils.bannedItems.spectrals > 0 then
            for j = 1, #CardUtils.bannedItems.spectrals do
                local c = CardUtils.bannedItems.spectrals[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.bannedItems.spectrals = {}
        GUI.runUnbannedFlips()
    end

    G.FUNCS.DeckCreatorModuleUnbanAllTags = function()
        Utils.getCurrentEditingDeck().config.bannedTagList = {}
        if CardUtils.bannedItems.tags and #CardUtils.bannedItems.tags > 0 then
            for j = 1, #CardUtils.bannedItems.tags do
                local c = CardUtils.bannedItems.tags[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.bannedItems.tags = {}
    end

    G.FUNCS.DeckCreatorModuleUnbanAllBlinds = function()
        Utils.getCurrentEditingDeck().config.bannedBlindList = {}
        if CardUtils.bannedItems.blinds and #CardUtils.bannedItems.blinds > 0 then
            for j = 1, #CardUtils.bannedItems.blinds do
                local c = CardUtils.bannedItems.blinds[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.bannedItems.blinds = {}
        G.FUNCS.overlay_menu{
            definition = GUI.addBannedBlindMenu()
        }
    end

    G.FUNCS.DeckCreatorModuleUnbanAllBoosters = function()
        Utils.getCurrentEditingDeck().config.bannedBoosterList = {}
        if CardUtils.bannedItems.boosters and #CardUtils.bannedItems.boosters > 0 then
            for j = 1, #CardUtils.bannedItems.boosters do
                local c = CardUtils.bannedItems.boosters[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.bannedItems.boosters = {}
        GUI.runUnbannedFlips()
    end

    G.FUNCS.DeckCreatorModuleUnbanAll = function()
        for j = 1, #Helper.deckEditorAreas do
            for i = #Helper.deckEditorAreas[j].cards,1, -1 do
                local c = Helper.deckEditorAreas[j]:remove_card(Helper.deckEditorAreas[j].cards[i])
                c:remove()
                c = nil
            end
        end
        Utils.getCurrentEditingDeck().config.bannedVoucherList = {}
        Utils.getCurrentEditingDeck().config.bannedJokerList = {}
        Utils.getCurrentEditingDeck().config.bannedTarotList = {}
        Utils.getCurrentEditingDeck().config.bannedPlanetList = {}
        Utils.getCurrentEditingDeck().config.bannedSpectralList = {}
        Utils.getCurrentEditingDeck().config.bannedTagList = {}
        Utils.getCurrentEditingDeck().config.bannedBlindList = {}
        Utils.getCurrentEditingDeck().config.bannedBoosterList = {}
        if CardUtils.bannedItems.vouchers and #CardUtils.bannedItems.vouchers > 0 then
            for j = 1, #CardUtils.bannedItems.vouchers do
                local c = CardUtils.bannedItems.vouchers[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.bannedItems.jokers and #CardUtils.bannedItems.jokers > 0 then
            for j = 1, #CardUtils.bannedItems.jokers do
                local c = CardUtils.bannedItems.jokers[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.bannedItems.tarots and #CardUtils.bannedItems.tarots > 0 then
            for j = 1, #CardUtils.bannedItems.tarots do
                local c = CardUtils.bannedItems.tarots[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.bannedItems.planets and #CardUtils.bannedItems.planets > 0 then
            for j = 1, #CardUtils.bannedItems.planets do
                local c = CardUtils.bannedItems.planets[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.bannedItems.spectrals and #CardUtils.bannedItems.spectrals > 0 then
            for j = 1, #CardUtils.bannedItems.spectrals do
                local c = CardUtils.bannedItems.spectrals[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.bannedItems.tags and #CardUtils.bannedItems.tags > 0 then
            for j = 1, #CardUtils.bannedItems.tags do
                local c = CardUtils.bannedItems.tags[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.bannedItems.blinds and #CardUtils.bannedItems.blinds > 0 then
            for j = 1, #CardUtils.bannedItems.blinds do
                local c = CardUtils.bannedItems.blinds[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        if CardUtils.bannedItems.boosters and #CardUtils.bannedItems.boosters > 0 then
            for j = 1, #CardUtils.bannedItems.boosters do
                local c = CardUtils.bannedItems.boosters[j]
                if c then
                    c:remove()
                    c = nil
                end
            end
        end
        CardUtils.bannedItems.vouchers = {}
        CardUtils.bannedItems.jokers = {}
        CardUtils.bannedItems.tarots = {}
        CardUtils.bannedItems.planets = {}
        CardUtils.bannedItems.spectrals = {}
        CardUtils.bannedItems.tags = {}
        CardUtils.bannedItems.blinds = {}
        CardUtils.bannedItems.boosters = {}
        GUI.updateAllBannedItemsAreas()
    end

    G.FUNCS.DeckCreatorModuleChangeOpenStartingItemConfigCopies = function(args)
        GUI.OpenStartingItemConfig.copies = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeOpenStartingItemConfigEdition = function(args)
        GUI.OpenStartingItemConfig.edition = string.lower(args.to_val)
        if GUI.OpenStartingItemConfig.edition == 'holographic' then
            GUI.OpenStartingItemConfig.edition = 'holo'
        end
    end
    G.FUNCS.DeckCreatorModuleAddCardChangeRank = function(args)
        GUI.addCard.rank = args.to_val
    end
    G.FUNCS.DeckCreatorModuleAddCardChangeSuit = function(args)
        GUI.addCard.suit = args.to_val
        GUI.addCard.suitKey = string.sub(args.to_val, 1, 1)
        if ModloaderHelper.SteamoddedLoaded then
            for _, v in pairs(SMODS.Card.SUITS) do
                if v.key == args.to_val then
                    GUI.addCard.suitKey = v.card_key
                    break
                end
            end
        end
    end
    G.FUNCS.DeckCreatorModuleAddCardChangeEdition = function(args)
        GUI.addCard.edition = args.to_val
        GUI.addCard.editionKey = string.lower(args.to_val)
        if GUI.addCard.editionKey == 'holographic' then
            GUI.addCard.editionKey = 'holo'
        end
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

    G.FUNCS.DeckCreatorModuleChangeRandomPolychromeCards = function(args)
        Utils.getCurrentEditingDeck().config.random_polychrome_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomHolographicCards = function(args)
        Utils.getCurrentEditingDeck().config.random_holographic_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomFoilCards = function(args)
        Utils.getCurrentEditingDeck().config.random_foil_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomEditionCards = function(args)
        Utils.getCurrentEditingDeck().config.random_edition_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomBonusCards = function(args)
        Utils.getCurrentEditingDeck().config.random_bonus_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomGlassCards = function(args)
        Utils.getCurrentEditingDeck().config.random_glass_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomLuckyCards = function(args)
        Utils.getCurrentEditingDeck().config.random_lucky_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomSteelCards = function(args)
        Utils.getCurrentEditingDeck().config.random_steel_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomStoneCards = function(args)
        Utils.getCurrentEditingDeck().config.random_stone_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomWildCards = function(args)
        Utils.getCurrentEditingDeck().config.random_wild_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomMultCards = function(args)
        Utils.getCurrentEditingDeck().config.random_mult_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomGoldCards = function(args)
        Utils.getCurrentEditingDeck().config.random_gold_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRandomEnhancementCards = function(args)
        Utils.getCurrentEditingDeck().config.random_enhancement_cards = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeSkipShopSmallBlind = function(args)
        Utils.getCurrentEditingDeck().config.skip_shop_chance_small_blind = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeSkipShopBigBlind = function(args)
        Utils.getCurrentEditingDeck().config.skip_shop_chance_big_blind = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeSkipShopBoss = function(args)
        Utils.getCurrentEditingDeck().config.skip_shop_chance_boss = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeSkipShopAny = function(args)
        Utils.getCurrentEditingDeck().config.skip_shop_chance_any = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeDisableBlindSmallBlind = function(args)
        Utils.getCurrentEditingDeck().config.skip_blind_disabled_chance_small_blind = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeDisableBlindBigBlind = function(args)
        Utils.getCurrentEditingDeck().config.skip_blind_disabled_chance_big_blind = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeDisableBlindAnyBlind = function(args)
        Utils.getCurrentEditingDeck().config.skip_blind_disabled_chance_any = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeEditionRate = function(args)
        Utils.getCurrentEditingDeck().config.edition_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDiscardCost = function(args)
        Utils.getCurrentEditingDeck().config.discard_cost = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeFlippedCards = function(args)
        Utils.getCurrentEditingDeck().config.flipped_cards = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeBrokenGlassMoney = function(args)
        Utils.getCurrentEditingDeck().config.broken_glass_money = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeBoosterAnteScaling = function(args)
        Utils.getCurrentEditingDeck().config.booster_ante_scaling = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeRandomStartingJokers = function(args)
        Utils.getCurrentEditingDeck().config.random_starting_jokers = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeRandomizeMoneyConfigurable = function(args)
        Utils.getCurrentEditingDeck().config.randomize_money_configurable = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDrawToHandSize = function(args)
        Utils.getCurrentEditingDeck().config.draw_to_hand_size = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeNegativeJokerMoney = function(args)
        Utils.getCurrentEditingDeck().config.negative_joker_money = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeEnhancedDollarsPerRound = function(args)
        Utils.getCurrentEditingDeck().config.enhanced_dollars_per_round = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeRandomSellValueIncrease = function(args)
        Utils.getCurrentEditingDeck().config.random_sell_value_increase = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeChanceToIncreaseDiscardCardsRank = function(args)
        Utils.getCurrentEditingDeck().config.chance_to_increase_discard_cards_rank = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeChanceToIncreaseDrawnCardsRank = function(args)
        Utils.getCurrentEditingDeck().config.chance_to_increase_drawn_cards_rank = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeBalancePercent = function(args)
        Utils.getCurrentEditingDeck().config.balance_percent = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeMultReductionPercent = function(args)
        Utils.getCurrentEditingDeck().config.mult_reduction_percent = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeExtraRedSealRepetitions = function(args)
        Utils.getCurrentEditingDeck().config.extra_red_seal_repetitions = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeChanceToDoubleGoldSeal = function(args)
        Utils.getCurrentEditingDeck().config.chance_to_double_gold_seal = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeChanceMakeSevensLucky = function(args)
        Utils.getCurrentEditingDeck().config.make_sevens_lucky = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeGainDollarsWhenSkipBooster  = function(args)
        Utils.getCurrentEditingDeck().config.gain_dollars_when_skip_booster = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeExtraHandLevelUpgrades  = function(args)
        Utils.getCurrentEditingDeck().config.extra_hand_level_upgrades = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeChipReductionPercent = function(args)
        Utils.getCurrentEditingDeck().config.chip_reduction_percent = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeNegativeTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.negative_tag_percent = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeMegaStandardTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.mega_standard_tag_percent = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeStandardPackEditionRate = function(args)
        Utils.getCurrentEditingDeck().config.standard_pack_edition_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeStandardPackEnhancementRate = function(args)
        Utils.getCurrentEditingDeck().config.standard_pack_enhancement_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeStandardPackSealRate = function(args)
        Utils.getCurrentEditingDeck().config.standard_pack_seal_rate = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeDoubleTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.double_tag_percent = args.to_val
    end

    G.FUNCS.DeckCreatorModuleChangeEconomyTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.economy_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeOrbitalTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.orbital_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeSkipTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.skip_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeTopUpTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.top_up_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeD6TagPercent = function(args)
        Utils.getCurrentEditingDeck().config.d6_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeJuggleTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.juggle_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeEtherealTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.ethereal_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeCouponTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.coupon_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeHandyTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.handy_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeGarbageTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.garbage_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeBuffoonTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.buffoon_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeCharmTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.charm_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeMeteorTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.meteor_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeBossTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.boss_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeVoucherTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.voucher_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeInvestmentTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.investment_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangePolychromeTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.polychrome_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeHolographicTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.holographic_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeUncommonTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.uncommon_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeRareTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.rare_tag_percent = args.to_val
    end
    G.FUNCS.DeckCreatorModuleChangeFoilTagPercent = function(args)
        Utils.getCurrentEditingDeck().config.foil_tag_percent = args.to_val
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

    G.FUNCS.DeckCreatorModuleChangeBlindScaling = function(args)
        Utils.getCurrentEditingDeck().config.blind_scaling = args.to_val
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
        sendTraceMessage("Trying to back out", "DeckCreatorLog")
        G.SETTINGS.paused = true
        GUI.CloseAllOpenFlags()
        Utils.currentShopJokerPage = 1
        GUI.ManageDecksConfig.manageDecksOpen = false
        GUI.addCard = GUI.resetAddCard()
        if ModloaderHelper.ModsMenuOpenedBy and ModloaderHelper.ModsMenuOpenedBy == 'Balamod' then
            G.FUNCS.overlay_menu({
                definition = GUI.createBalamodMenu()
            })
        elseif ModloaderHelper.SteamoddedLoaded then
            sendTraceMessage("STEAMODDED", "DeckCreatorLog")
            G.FUNCS.overlay_menu({
                definition = create_UIBox_mods()
            })
        end
    end

    G.FUNCS.DeckCreatorModuleBackToModsScreen = function()
        G.SETTINGS.paused = true
        GUI.addCard = GUI.resetAddCard()
        G.FUNCS.overlay_menu({
            definition = G.UIDEF.mods()
        })
    end

    G.FUNCS.DeckCreatorModuleOpenCreateDeck = function()
        G.SETTINGS.paused = true
        GUI.ManageDecksConfig.manageDecksOpen = false
        Utils.EditDeckConfig.newDeck = true
        Utils.EditDeckConfig.copyDeck = false
        Utils.EditDeckConfig.editDeck = false
        Utils.EditDeckConfig.deck = CustomDeck:blankDeck()
        GUI.addCard = GUI.resetAddCard()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Base Deck")
        })
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Main Menu")
        })
    end

    G.FUNCS.DeckCreatorModuleOpenMainMenu = function()
        G.SETTINGS.paused = true
        ModloaderHelper.ModsMenuOpenedBy = 'Balamod'
        GUI.addCard = GUI.resetAddCard()
        G.FUNCS.overlay_menu({
            definition = GUI.createBalamodMenu()
        })
    end

    G.FUNCS.DeckCreatorModuleOpenManageDecks = function()
        G.SETTINGS.paused = true
        GUI.ManageDecksConfig.manageDecksOpen = true
        GUI.addCard = GUI.resetAddCard()
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

    G.FUNCS.DeckCreatorModuleReopenBannedItems = function()
        G.SETTINGS.paused = true
        GUI.resetOpenBannedItemConfig()
        G.FUNCS.overlay_menu({
            definition = GUI.createDecksMenu("Banned Items")
        })
    end

    G.FUNCS.DeckCreatorModuleSaveDeck = function()

        local descTable = {}
        Utils.getCurrentEditingDeck().config.rawDescription = Utils.getCurrentEditingDeck().descLine1
        if Utils.getCurrentEditingDeck().config.rawDescription == "" then
            Utils.getCurrentEditingDeck().config.rawDescription = "Custom Deck<ncreated at<n<:attention<" .. Utils.timestamp() .. "<"
        end
        descTable = CustomDeck.parseRawDescription(Utils.getCurrentEditingDeck().config.rawDescription)

        local newDeck = CustomDeck.fullNewFromExisting(Utils.getCurrentEditingDeck(), descTable)
        newDeck:register()

        Utils.log("New deck created\n" .. Utils.tableToStringIgnoreKeys(newDeck, { "customCardList" }))

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

        GUI.ManageDecksConfig.manageDecksOpen = false
        Persistence.refreshDeckList()
        Persistence.saveAllDecks()
        GUI.CloseAllOpenFlags()
        --GUI.redrawMainMenu()
        GUI.addCard = GUI.resetAddCard()
        --G.FUNCS:exit_overlay_menu()
        G.FUNCS.overlay_menu({
            definition = create_UIBox_mods()
        })
    end
end

function GUI.checkBannedForFlips(center, list)
    local isBanned = false
    for k,v in pairs(Utils.getCurrentEditingDeck().config[list]) do
        if v.key == center.key or v == center.key then
            isBanned = true
            break
        end
    end
    return isBanned
end

function GUI.runBannedFlips(isBanned, card)
    if isBanned and card.facing == 'front' then
        card:flip()
    elseif isBanned == false and card.facing == 'back' then
        card:flip()
    end
end

function GUI.runUnbannedFlips()
    for i = 1, #G.your_collection do
        for j = 1, #G.your_collection[i].cards do
            local card = G.your_collection[i].cards[j]
            if card ~= nil then
                GUI.runBannedFlips(false, card)
            end
        end
    end
end

function GUI.runBanAllFlips()
    for i = 1, #G.your_collection do
        for j = 1, #G.your_collection[i].cards do
            local card = G.your_collection[i].cards[j]
            if card ~= nil then
                GUI.runBannedFlips(true, card)
            end
        end
    end
end

function GUI.redrawMainMenu()
    if ModloaderHelper.SteamoddedLoaded then
        --SMODS.customUIElements["ADeckCreatorModule"] = GUI.mainMenu()
    end
end

function GUI.mainMenu()
    sendTraceMessage("Building menu", "DeckCreatorLogger")
    return {
        n = G.UIT.ROOT,
		config = {
			r = 0.1,
			minh = 6,
			minw = 6,
			align = 'cm',
			colour = G.C.CLEAR
		},
        nodes = {
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
                        colour = G.C.GREEN,
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
                        colour = G.C.GOLD,
                        button = "DeckCreatorModuleOpenGithub",
                        minh = 0.8,
                        minw = 8
                    })
                }
            }
        }
    }
end

function GUI.registerModMenuUI()
    if ModloaderHelper.SteamoddedLoaded then
        sendTraceMessage("Registering config menu", "DeckCreatorLogger")
        SMODS.current_mod.config_tab = GUI.mainMenu
        ---SMODS.registerUIElement("ADeckCreatorModule", GUI.mainMenu())
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
        config={align = "cm", colour = G.C.BLACK,  r = 0.1},
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
        back_func = "DeckCreatorModuleBackToMainMenu", --GUI.ManageDecksConfig.manageDecksOpen and "DeckCreatorModuleOpenManageDecks" or "DeckCreatorModuleBackToMainMenu",
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
                                                    Helper.createOptionSelector({label = "Winning Ante", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 9999), opt_callback = 'DeckCreatorModuleChangeWinAnte', current_option = (
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
                                                                        max_length = 90,
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
                                                                            Helper.createOptionSelector({label = "Ante Scaling", scale = 0.8, options = Utils.generateBoundedIntegerList(0, 3), opt_callback = 'DeckCreatorModuleChangeAnteScaling', current_option = (
                                                                                    Utils.getCurrentEditingDeck().config.ante_scaling
                                                                            ), multiArrows = true}),
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
                                                                            Helper.createOptionSelector({label = "Blind Score Multiplier", scale = 0.8, options = Utils.generateBoundedFloatList(0, 100, 0.01), opt_callback = 'DeckCreatorModuleChangeBlindScaling', current_option = (
                                                                                    Utils.getCurrentEditingDeck().config.blind_scaling
                                                                            ), multiArrows = true }),
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
                                                    Helper.createOptionSelector({label = "Hand Size", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 9999), opt_callback = 'DeckCreatorModuleChangeHandSize', current_option = (
                                                            Utils.getCurrentEditingDeck().config.hand_size
                                                    ), multiArrows = true }),
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
                                                    post = GUI.dynamicDeckEditorPostUpdate
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
                                                    post = GUI.dynamicStartingItemsPostUpdate
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
                                            return GUI.DynamicUIManager.initTab({
                                                preUpdateFunctions = {
                                                    init = GUI.dynamicBannedItemsPreUpdate
                                                },
                                                updateFunctions = {
                                                    dynamicBannedItemsAreaCards = G.FUNCS.DeckCreatorModuleUpdateDynamicBannedItemsAreaCards,
                                                    dynamicBannedItemsAreaDeckTables = G.FUNCS.DeckCreatorModuleUpdateDynamicBannedItemsAreaDeckTables
                                                },
                                                postUpdateFunctions = {
                                                    post = GUI.dynamicBannedItemsPostUpdate
                                                },
                                                staticPageDefinition = GUI.bannedItemsPageStatic()
                                            })
                                        end
                                    },
                                    {
                                        label = " Static Mods ",
                                        chosen = chosen == "Static Mods",
                                        tab_definition_function = function()
                                            GUI.setOpenTab("Static Mods")
                                            return GUI.DynamicUIManager.initTab({
                                                preUpdateFunctions = {
                                                    init = GUI.staticModsPreUpdate
                                                },
                                                updateFunctions = {
                                                    staticModsTitle = G.FUNCS.DeckCreatorModuleUpdateDynamicStaticModsTitle,
                                                    staticModsColumnOne = G.FUNCS.DeckCreatorModuleUpdateDynamicStaticModsColumnOne,
                                                    staticModsColumnTwo = G.FUNCS.DeckCreatorModuleUpdateDynamicStaticModsColumnTwo,
                                                },
                                                postUpdateFunctions = {
                                                    post = GUI.staticModsPostUpdate
                                                },
                                                staticPageDefinition = GUI.staticModsPageStatic()
                                            })
                                        end
                                    },
                                    {
                                        label = " Dynamic Mods ",
                                        chosen = chosen == "Dynamic Mods",
                                        tab_definition_function = function()
                                            GUI.setOpenTab("Dynamic Mods")
                                            return GUI.DynamicUIManager.initTab({
                                                preUpdateFunctions = {
                                                    init = GUI.dynamicModsPreUpdate
                                                },
                                                updateFunctions = {
                                                    dynamicModsColumnOne = G.FUNCS.DeckCreatorModuleUpdateDynamicDynamicModsColumnOne,
                                                    dynamicModsColumnTwo = G.FUNCS.DeckCreatorModuleUpdateDynamicDynamicModsColumnTwo
                                                },
                                                postUpdateFunctions = {
                                                    post = GUI.dynamicModsPostUpdate
                                                },
                                                staticPageDefinition = GUI.dynamicModsPageStatic()
                                            })
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
                                }},
                                {n=G.UIT.C, config={align = "cm", minh = 1.7, r = 0.1, colour = G.C.L_BLACK, padding = 0.1}, nodes={
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
    local memoryBefore = Utils.checkMemory()
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

    local tally_ui = {}

    -- base cards
    table.insert(tally_ui, { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.07 }, nodes = {
        { n = G.UIT.O, config = { object = DynaText({ string = { { string = localize('k_base_cards'), colour = G.C.RED }, Helper.sums.modded and { string = localize('k_effective'), colour = G.C.BLUE } or nil }, colours = { G.C.RED }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4 }) } }
    }})

    -- aces, faces and numbered cards
    table.insert(tally_ui, { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
        tally_sprite({ x = 1, y = 0 }, { { string = Helper.sums.ace_tally, colour = flip_col }, { string = Helper.sums.mod_ace_tally, colour = G.C.BLUE } }, { localize('k_aces') }),
        tally_sprite({ x = 2, y = 0 }, { { string = Helper.sums.face_tally, colour = flip_col }, { string = Helper.sums.mod_face_tally, colour = G.C.BLUE } }, { localize('k_face_cards') }),
        tally_sprite({ x = 3, y = 0 }, { { string = Helper.sums.num_tally, colour = flip_col }, { string = Helper.sums.mod_num_tally, colour = G.C.BLUE } }, { localize('k_numbered_cards') }),
    }})

    -- suits
    if ModloaderHelper.SteamoddedLoaded then
        local suit_list = SMODS.Card.SUIT_LIST
        local mod = 2
        if #suit_list > 4 then
            mod = 3
        end
        for i = 1, #suit_list, mod do
            local n = {
                n = G.UIT.R,
                config = { align = "cm", minh = 0.05, padding = 0.1 },
                nodes = {
                    tally_sprite(SMODS.Card.SUITS[suit_list[i]].ui_pos,
                            { { string = '' .. Helper.sums.suit_tallies[suit_list[i]], colour = flip_col }, { string = '' .. Helper.sums.mod_suit_tallies[suit_list[i]], colour = G.C.BLUE } },
                            { localize(suit_list[i], 'suits_plural') },
                            suit_list[i]),
                    suit_list[i + 1] and tally_sprite(SMODS.Card.SUITS[suit_list[i + 1]].ui_pos,
                            { { string = '' .. Helper.sums.suit_tallies[suit_list[i + 1]], colour = flip_col }, { string = '' .. Helper.sums.mod_suit_tallies[suit_list[i + 1]], colour = G.C.BLUE } },
                            { localize(suit_list[i + 1], 'suits_plural') },
                            suit_list[i + 1]) or nil
                }
            }
            if mod == 3 and suit_list[i + 2] then
                table.insert(n.nodes, suit_list[i + 2] and tally_sprite(SMODS.Card.SUITS[suit_list[i + 2]].ui_pos,
                        { { string = '' .. Helper.sums.suit_tallies[suit_list[i + 2]], colour = flip_col }, { string = '' .. Helper.sums.mod_suit_tallies[suit_list[i + 2]], colour = G.C.BLUE } },
                        { localize(suit_list[i + 2], 'suits_plural') },
                        suit_list[i + 2]) or nil)
            end
            table.insert(tally_ui, n)
        end
    else
        table.insert(tally_ui, { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
            tally_sprite({ x = 3, y = 1 }, { { string = Helper.sums.suit_tallies['Spades'], colour = flip_col }, { string = Helper.sums.mod_suit_tallies['Spades'], colour = G.C.BLUE } }, { localize('Spades', 'suits_plural') }),
            tally_sprite({ x = 0, y = 1 }, { { string = Helper.sums.suit_tallies['Hearts'], colour = flip_col }, { string = Helper.sums.mod_suit_tallies['Hearts'], colour = G.C.BLUE } }, { localize('Hearts', 'suits_plural') }),
        }})
        table.insert(tally_ui, { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
            tally_sprite({ x = 2, y = 1 }, { { string = Helper.sums.suit_tallies['Clubs'], colour = flip_col }, { string = Helper.sums.mod_suit_tallies['Clubs'], colour = G.C.BLUE } }, { localize('Clubs', 'suits_plural') }),
            tally_sprite({ x = 1, y = 1 }, { { string = Helper.sums.suit_tallies['Diamonds'], colour = flip_col }, { string = Helper.sums.mod_suit_tallies['Diamonds'], colour = G.C.BLUE } }, { localize('Diamonds', 'suits_plural') }),
        }})
    end

    -- total
    table.insert(tally_ui, { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
        {n=G.UIT.C, config={align = "cm", padding = 0.07,force_focus = true,  focus_args = {type = 'tally_sprite'}}, nodes={
            {n=G.UIT.R, config={align = "cm"}, nodes={
                {n=G.UIT.T, config={text = "Total: " .. Helper.sums.total_cards,colour = flip_col, scale = 0.4, shadow = true}},
            }},
        }}
    }})

    return {
        n=G.UIT.C,
        config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
        nodes={
            {
                n=G.UIT.C,
                config={align = "cm", padding = 0.1},
                nodes={
                    {
                        n = G.UIT.R,
                        config = { align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5 },
                        nodes = tally_ui
                    }
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

    local FakeBlind = {}
    function FakeBlind:debuff_card(arg) end
    G.VIEWING_DECK = true
    G.GAME.blind = FakeBlind
    table.sort(G.playing_cards, function (a, b) return a:get_nominal('suit') > b:get_nominal('suit') end )

    local deck_tables = {}
    local SUITS = { S = {}, H = {}, C = {}, D = {} }
    local suit_map = {'S', 'H', 'C', 'D'}
    local num_suits = 4

    if ModloaderHelper.SteamoddedLoaded then
        suit_map = SMODS.Card.SUIT_LIST
        SUITS = {}
        for _, v in ipairs(suit_map) do
            SUITS[v] = {}
        end
        for k, v in ipairs(G.playing_cards) do
            if SUITS[v.base.suit] ~= nil then
                table.insert(SUITS[v.base.suit], v)
            end
        end
        num_suits = 0
        for j = 1, #suit_map do
            if SUITS[suit_map[j]][1] then num_suits = num_suits + 1 end
        end
    else
        for k, v in ipairs(G.playing_cards) do
            table.insert(SUITS[string.sub(v.base.suit, 1, 1)], v)
        end
    end

    local xy = GUI.OpenTab == 'Base Deck' and 0 or 9999

    for j = 1, #suit_map do
        if SUITS[suit_map[j]][1] then
            if ModloaderHelper.SteamoddedLoaded == false then
                table.sort(SUITS[suit_map[j]], function(a,b) return a:get_nominal() > b:get_nominal() end )
            end
            local view_deck = CardArea(
                        xy,xy,
                        5.5*G.CARD_W,
                        ((num_suits > 8) and 0.2 or (num_suits > 4) and (1 - 0.1 * num_suits) or 0.6) * G.CARD_H,
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
    local tagList = Utils.getCurrentEditingDeck().config.customTagList
    CardUtils.getJokersFromCustomJokerList(jokerList)
    CardUtils.getTarotsFromCustomTarotList(tarotList)
    CardUtils.getPlanetsFromCustomPlanetList(planetList)
    CardUtils.getSpectralsFromCustomSpectralList(spectralList)
    CardUtils.getVouchersFromCustomVoucherList(voucherList)
    CardUtils.getTagsFromCustomTagList(tagList)
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
    Helper.calculateStartingItemsSums(CardUtils.startingItems)

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
                            Helper.tally_item_sprite({ x = 2, y = 0 }, { { string = Helper.sums.item_tallies['Joker'], colour = flip_col }, { string = Helper.sums.item_tallies['Joker'], colour = G.C.BLUE } }, { "Jokers" }),
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.item_tallies['Consumable'], colour = flip_col }, { string = Helper.sums.item_tallies['Consumable'], colour = G.C.BLUE } }, { "Consumables" }),
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.item_tallies['Other'], colour = flip_col }, { string = Helper.sums.item_tallies['Other'], colour = G.C.BLUE } }, { "Other" }),
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 2, y = 0 }, { { string = Helper.sums.item_tallies['Joker'], colour = flip_col }, { string = Helper.sums.item_tallies['Joker'], colour = G.C.BLUE } }, { "Jokers" }),
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.item_tallies['Voucher'], colour = flip_col }, { string = Helper.sums.item_tallies['Voucher'], colour = G.C.BLUE } }, { "Vouchers" }),
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.item_tallies['Tag'], colour = flip_col }, { string = Helper.sums.item_tallies['Tag'], colour = G.C.BLUE } }, { "Tags" }),
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.item_tallies['Tarot'], colour = flip_col }, { string = Helper.sums.item_tallies['Tarot'], colour = G.C.BLUE } }, { "Tarots" }),
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.item_tallies['Planet'], colour = flip_col }, { string = Helper.sums.item_tallies['Planet'], colour = G.C.BLUE } }, { "Planets" }),
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.item_tallies['Spectral'], colour = flip_col }, { string = Helper.sums.item_tallies['Spectral'], colour = G.C.BLUE } }, { "Spectrals" }),

                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {

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

    -- tags
    local totalPages = math.ceil(#CardUtils.startingItems.tags / Utils.startingTagsPerPage)
    if GUI.StartingItemsConfig.TagRowPage > totalPages or GUI.StartingItemsConfig.TagRowPage < 1 then
        GUI.StartingItemsConfig.BlindRowPage = 1
    end
    local max = Utils.startingTagsPerPage
    local skips = (GUI.StartingItemsConfig.TagRowPage - 1) * max
    local tooMany = #CardUtils.startingItems.tags > max
    local tagRow = { n=G.UIT.R, config={ align = "cm"}, nodes={}}
    for k,v in ipairs(CardUtils.startingItems.tags) do
        if skips > 0 then
            skips = skips - 1
        else
            local tagCol = { n=G.UIT.C, config={ align = "cm", padding = 0.1}, nodes={
                {n=G.UIT.O, config={object = v, focus_with_object = true}}
            }}
            table.insert(tagRow.nodes, tagCol)
            max = max - 1
            if max < 1 then
                break
            end
        end
    end
    Utils.resetTagsPerPage()
    if tooMany then
        table.insert(deck_tables, {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    r = 0.1,
                    minw = 0.6,
                    colour = G.C.BLACK,
                    button = 'DeckCreatorModuleChangeStartingTagRowPageLeft',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config = { text = '<', scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
                }
            },
            {
                n=G.UIT.C,
                config={align = "cm", padding = 0.1},
                nodes={ tagRow }
            },
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    r = 0.1,
                    minw = 0.6,
                    colour = G.C.BLACK,
                    button = 'DeckCreatorModuleChangeStartingTagRowPageRight',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config = { text = '>', scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
                }
            }
        }})
    else
        table.insert(deck_tables, tagRow)
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

function GUI.createSelectItemTypeMenu()
    GUI.closeAllHoveredObjects()
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
            create_option_cycle({options = voucher_options, w = 4.5, cycle_shoulders = true, opt_callback = 'DeckCreatorModuleChangeVoucherPage', focus_args = {snap_to = true, nav = 'wide'}, current_option = 1, colour = G.C.RED, no_pips = true})
        }}
    }})
end

function GUI.addJokerMenu()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                GUI.JokersPerPage*G.CARD_W,
                0.95*G.CARD_H,
                {card_limit = GUI.JokersPerPage, type = 'title', highlight_limit = 0, collection = true})
        table.insert(deck_tables,
                {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
                    {n=G.UIT.O, config={object = G.your_collection[j]}}
                }}
        )
    end

    local joker_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Joker/(GUI.JokersPerPage*#G.your_collection)) do
        table.insert(joker_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Joker/(GUI.JokersPerPage*#G.your_collection))))
    end

    for i = 1, GUI.JokersPerPage do
        for j = 1, #G.your_collection do
            local center = G.P_CENTER_POOLS["Joker"][i+(j-1)*GUI.JokersPerPage]
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
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = joker_options, w = 2, cycle_shoulders = true, opt_callback = 'DeckCreatorModuleStartingJokersChangePage', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
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
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_toggle({label = "Eternal", ref_table = GUI.OpenStartingItemConfig, ref_value = 'eternal'}),
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_toggle({label = "Pinned", ref_table = GUI.OpenStartingItemConfig, ref_value = 'pinned'}),
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_toggle({label = "Perishable", ref_table = GUI.OpenStartingItemConfig, ref_value = 'perishable'}),
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_toggle({label = "Rental", ref_table = GUI.OpenStartingItemConfig, ref_value = 'rental'}),
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
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Tarot/11) do
        table.insert(tarot_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Tarot/11)))
    end

    for j = 1, #G.your_collection do
        for i = 1, 4+j do
            local center = G.P_CENTER_POOLS["Tarot"][i+(j-1)*(5)]
            if center ~= nil then
                local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
                card:start_materialize(nil, i>1 or j>1)
                G.your_collection[j]:emplace(card)
            end
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
                        create_option_cycle({options = tarot_options, w = 2.5, cycle_shoulders = true, opt_callback = 'DeckCreatorModuleChangeTarotPage', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})
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

    local planet_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Planet / 12) do
        table.insert(planet_options,
                localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#G.P_CENTER_POOLS.Planet / 12)))
    end

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenAddItemToDeck', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    #planet_options > 1 and {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({
                            options = planet_options,
                            w = 4.5,
                            cycle_shoulders = true,
                            opt_callback =
                            'DeckCreatorModuleYourCollectionPlanetPage',
                            focus_args = { snap_to = true, nav = 'wide' },
                            current_option = 1,
                            colour = G.C.RED,
                            no_pips = true
                        })
                    }} or nil
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
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Spectral/9) do
        table.insert(spectral_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Spectral/9)))
    end

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenAddItemToDeck', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = spectral_options, w = 4.5, cycle_shoulders = true, opt_callback = 'DeckCreatorModuleChangeSpectralPage', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})
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
        local temp_tag_ui, temp_tag_sprite =  Helper.generateTagUI(temp_tag, 0.8, { key = 'hoveredTagStartingItemsAddToItemsKey', sprite = 'hoveredTagStartingItemsAddToItemsSprite' })
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
        {n=G.UIT.R, config={align = "cm"}, nodes={
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
        }},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            Helper.createOptionSelector({label = "Copies", scale = 0.8, options = Utils.generateBoundedIntegerList(1, 99), opt_callback = 'DeckCreatorModuleChangeOpenStartingItemConfigCopies', current_option = (
                    GUI.OpenStartingItemConfig.copies
            ), multiArrows = true, minorArrows = true })
        }}
    }})

    return t
end

-- Banned Items
function GUI.dynamicBannedItemsPreUpdate()
    GUI.flushDeckEditorAreas()
    if GUI.OpenTab ~= "Banned Items" then
        return
    end

    local jokerList = Utils.getCurrentEditingDeck().config.bannedJokerList
    local tarotList = Utils.getCurrentEditingDeck().config.bannedTarotList
    local planetList = Utils.getCurrentEditingDeck().config.bannedPlanetList
    local spectralList = Utils.getCurrentEditingDeck().config.bannedSpectralList
    local voucherList = Utils.getCurrentEditingDeck().config.bannedVoucherList
    local tagList = Utils.getCurrentEditingDeck().config.bannedTagList
    local blindList = Utils.getCurrentEditingDeck().config.bannedBlindList
    local boosterList = Utils.getCurrentEditingDeck().config.bannedBoosterList
    CardUtils.getBannedJokersFromBannedJokerList(jokerList)
    CardUtils.getBannedTarotsFromBannedTarotList(tarotList)
    CardUtils.getBannedPlanetsFromBannedPlanetList(planetList)
    CardUtils.getBannedSpectralsFromBannedSpectralList(spectralList)
    CardUtils.getBannedVouchersFromBannedVoucherList(voucherList)
    CardUtils.getBannedTagsFromBannedTagList(tagList)
    CardUtils.getBannedBlindsFromBannedBlindList(blindList)
    CardUtils.getBannedBoostersFromBannedBoosterList(boosterList)
    remove_nils(CardUtils.bannedItems.jokers)
    remove_nils(CardUtils.bannedItems.tarots)
    remove_nils(CardUtils.bannedItems.planets)
    remove_nils(CardUtils.bannedItems.spectrals)
    remove_nils(CardUtils.bannedItems.vouchers)
    remove_nils(CardUtils.bannedItems.tags)
    remove_nils(CardUtils.bannedItems.blinds)
    remove_nils(CardUtils.bannedItems.boosters)
end

function GUI.dynamicBannedItemsPostUpdate()
    collectgarbage("collect")
end

function GUI.bannedItemsPageStatic()
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
                            {n=G.UIT.O, config={id = 'dynamicBannedItemsAreaCards', object = Moveable()}},
                        }},
                    }},
                    {n=G.UIT.C, config={align = "cm", minh = 6.5, minw = 12}, nodes={
                        {n=G.UIT.O, config={id = 'dynamicBannedItemsAreaDeckTables', object = Moveable()}},
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
                            label = {" Ban Item "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.GREEN,
                            button = "DeckCreatorModuleOpenBanItem",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                        UIBox_button({
                            label = {" Ban Random "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleBanRandomItem",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                        UIBox_button({
                            label = {" Unban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.RED,
                            button = "DeckCreatorModuleUnbanAll",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                }
            }
        }}
end

function GUI.dynamicBannedItemsAreaCards()
    if GUI.OpenTab ~= "Banned Items" then
        return {
            n=G.UIT.C,
            config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
            nodes={}
        }
    end

    local flip_col = G.C.WHITE
    Helper.calculateBannedItemsSums(CardUtils.bannedItems)

    return {
        n=G.UIT.C,
        config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
        nodes={
            {
                n=G.UIT.C,
                config={align = "cm", padding = 0.1},
                nodes={
                    { n = G.UIT.R, config = { align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5 }, nodes = {
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 2, y = 0 }, { { string = Helper.sums.banned_item_tallies['Joker'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Joker'], colour = G.C.BLUE } }, { "Jokers" }),
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.banned_item_tallies['Consumable'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Consumable'], colour = G.C.BLUE } }, { "Consumables" }),
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.banned_item_tallies['Other'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Other'], colour = G.C.BLUE } }, { "Other" }),
                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 2, y = 0 }, { { string = Helper.sums.banned_item_tallies['Joker'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Joker'], colour = G.C.BLUE } }, { "Jokers" }),
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.banned_item_tallies['Voucher'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Voucher'], colour = G.C.BLUE } }, { "Vouchers" }),

                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.banned_item_tallies['Tarot'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Tarot'], colour = G.C.BLUE } }, { "Tarots" }),
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.banned_item_tallies['Planet'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Planet'], colour = G.C.BLUE } }, { "Planets" }),
                            Helper.tally_item_sprite({ x = 2, y = 1 }, { { string = Helper.sums.banned_item_tallies['Spectral'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Spectral'], colour = G.C.BLUE } }, { "Spectrals" }),

                        } },
                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.banned_item_tallies['Tag'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Tag'], colour = G.C.BLUE } }, { "Tags" }),
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.banned_item_tallies['Blind'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Blind'], colour = G.C.BLUE } }, { "Blinds" }),
                            Helper.tally_item_sprite({ x = 3, y = 0 }, { { string = Helper.sums.banned_item_tallies['Booster'], colour = flip_col }, { string = Helper.sums.banned_item_tallies['Booster'], colour = G.C.BLUE } }, { "Boosters" }),
                        } },
                    } }
                }
            },
            {
                n=G.UIT.C,
                config={align = "cm"},
                nodes = Helper.sums.ban_item_cols
            },
            {
                n=G.UIT.B,
                config={w = 0.1, h = 0.1}
            },
        }
    }
end

function GUI.dynamicBannedItemsAreaDeckTables()

    if GUI.OpenTab ~= "Banned Items" then
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

    local xy = GUI.OpenTab == 'Banned Items' and 0 or 9999


    -- tags
    local totalPages = math.ceil(#CardUtils.bannedItems.tags / Utils.bannedTagsPerPage)
    if GUI.BannedItemsConfig.TagRowPage > totalPages or GUI.BannedItemsConfig.TagRowPage < 1 then
        GUI.BannedItemsConfig.TagRowPage = 1
    end
    local max = Utils.bannedTagsPerPage
    local skips = (GUI.BannedItemsConfig.TagRowPage - 1) * max
    local tooMany = #CardUtils.bannedItems.tags > max
    local tagRow = { n=G.UIT.R, config={ align = "cm"}, nodes={}}
    for k,v in ipairs(CardUtils.bannedItems.tags) do
        if skips > 0 then
            skips = skips - 1
        else
            local tagCol = { n=G.UIT.C, config={ align = "cm", padding = 0.1}, nodes={
                {n=G.UIT.O, config={object = v, focus_with_object = true}}
            }}
            table.insert(tagRow.nodes, tagCol)
            max = max - 1
            if max < 1 then
                break
            end
        end
    end
    Utils.resetTagsPerPage()
    if tooMany then
        table.insert(deck_tables, {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    r = 0.1,
                    minw = 0.6,
                    colour = G.C.BLACK,
                    button = 'DeckCreatorModuleChangeBannedTagRowPageLeft',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config = { text = '<', scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
                }
            },
            {
                n=G.UIT.C,
                config={align = "cm", padding = 0.1},
                nodes={ tagRow }
            },
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    r = 0.1,
                    minw = 0.6,
                    colour = G.C.BLACK,
                    button = 'DeckCreatorModuleChangeBannedTagRowPageRight',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config = { text = '>', scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
                }
            }
        }})
    else
        table.insert(deck_tables, tagRow)
    end

    -- blinds
    totalPages = math.ceil(#CardUtils.bannedItems.blinds / Utils.bannedBlindsPerPage)
    if GUI.BannedItemsConfig.BlindRowPage > totalPages or GUI.BannedItemsConfig.BlindRowPage < 1 then
        GUI.BannedItemsConfig.BlindRowPage = 1
    end
    max = Utils.bannedBlindsPerPage
    skips = (GUI.BannedItemsConfig.BlindRowPage - 1) * max
    tooMany = #CardUtils.bannedItems.blinds > max
    local blindRow = {n=G.UIT.R, config={align = "cm"}, nodes={}}
    for k,v in ipairs(CardUtils.bannedItems.blinds) do
        if skips > 0 then
            skips = skips - 1
        else
            local blindCol = {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
                {n=G.UIT.O, config={object = v, focus_with_object = true}}
            }}
            table.insert(blindRow.nodes, blindCol)
            max = max - 1
            if max < 1 then
                break
            end
        end
    end
    Utils.resetBlindsPerPage()
    if tooMany then
        table.insert(deck_tables, {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    r = 0.1,
                    minw = 0.6,
                    colour = G.C.BLACK,
                    button = 'DeckCreatorModuleChangeBannedBlindRowPageLeft',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config = { text = '<', scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
                }
            },
            {
                n=G.UIT.C,
                config={align = "cm", padding = 0.1},
                nodes={ blindRow }
            },
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    r = 0.1,
                    minw = 0.6,
                    colour = G.C.BLACK,
                    button = 'DeckCreatorModuleChangeBannedBlindRowPageRight',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config = { text = '>', scale = 0.5, colour = G.C.UI.TEXT_LIGHT } }
                }
            }
        }})
    else
        table.insert(deck_tables, blindRow)
    end


    -- vouchers
    local voucherArea = CardArea(
            xy,xy,
            5.5*G.CARD_W,
            0.42*G.CARD_H,
            {card_limit = #CardUtils.bannedItems.vouchers, type = 'title_2', view_deck = true, highlight_limit = 0, card_w = G.CARD_W*0.5, draw_layers = {'card'}})
    table.insert(Helper.deckEditorAreas, voucherArea)
    table.insert(deck_tables,
            {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
                {n=G.UIT.O, config={object = voucherArea}}
            }}
    )

    for i = 1, #CardUtils.bannedItems.vouchers do
        if CardUtils.bannedItems.vouchers[i] then
            local base = CardUtils.bannedItems.vouchers[i]
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
    for i = 1, #CardUtils.bannedItems.tarots do
        if CardUtils.bannedItems.tarots[i] then
            local base = CardUtils.bannedItems.tarots[i]
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
    for i = 1, #CardUtils.bannedItems.planets do
        if CardUtils.bannedItems.planets[i] then
            local base = CardUtils.bannedItems.planets[i]
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
    for i = 1, #CardUtils.bannedItems.spectrals do
        if CardUtils.bannedItems.spectrals[i] then
            local base = CardUtils.bannedItems.spectrals[i]
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
    for i = 1, #CardUtils.bannedItems.boosters do
        if CardUtils.bannedItems.boosters[i] then
            local base = CardUtils.bannedItems.boosters[i]
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
    for i = 1, #CardUtils.bannedItems.jokers do
        if CardUtils.bannedItems.jokers[i] then
            local base = CardUtils.bannedItems.jokers[i]
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

function GUI.updateAllBannedItemsAreas()
    GUI.dynamicBannedItemsPreUpdate()
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicBannedItemsAreaCards"] = GUI.dynamicBannedItemsAreaCards()
    })
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicBannedItemsAreaDeckTables"] = GUI.dynamicBannedItemsAreaDeckTables()
    })
    GUI.dynamicBannedItemsPostUpdate()
end

function GUI.createSelectBanItemTypeMenu()
    GUI.closeAllHoveredObjects()
    return create_UIBox_generic_options({
        back_func = 'DeckCreatorModuleReopenBannedItems',
        contents = {
            {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes={
                UIBox_button({button = 'DeckCreatorModuleBanJokerMenu', label = {localize('b_jokers')}, count = G.DISCOVER_TALLIES.jokers,  minw = 5, minh = 1.7, scale = 0.6, id = 'your_collection_jokers'}),
                UIBox_button({button = 'DeckCreatorModuleBanTagMenu', label = {localize('b_tags')}, count = G.DISCOVER_TALLIES.tags, minw = 5, id = 'your_collection_tags'}),
                UIBox_button({button = 'DeckCreatorModuleBanVoucherMenu', label = {localize('b_vouchers')}, count = G.DISCOVER_TALLIES.vouchers, minw = 5, id = 'your_collection_vouchers'}),
                UIBox_button({button = 'DeckCreatorModuleBanBlindMenu', label = {localize('b_blinds')}, count = G.DISCOVER_TALLIES.blinds, minw = 5, id = 'your_collection_blinds', focus_args = {snap_to = true}}),
                UIBox_button({button = 'DeckCreatorModuleBanBoosterMenu', label = {localize('b_booster_packs')}, count = G.DISCOVER_TALLIES.boosters, minw = 5, id = 'your_collection_boosters'}),
                {n=G.UIT.R, config={align = "cm", padding = 0.1, r=0.2, colour = G.C.BLACK}, nodes={
                    {n=G.UIT.C, config={align = "cm", maxh=2.9}, nodes={
                        {n=G.UIT.T, config={text = localize('k_cap_consumables'), scale = 0.45, colour = G.C.L_BLACK, vert = true, maxh=2.2}},
                    }},
                    {n=G.UIT.C, config={align = "cm", padding = 0.15}, nodes={
                        UIBox_button({button = 'DeckCreatorModuleBanTarotMenu', label = {localize('b_tarot_cards')}, count = G.DISCOVER_TALLIES.tarots, minw = 4, id = 'your_collection_tarots', colour = G.C.SECONDARY_SET.Tarot}),
                        UIBox_button({button = 'DeckCreatorModuleBanPlanetMenu', label = {localize('b_planet_cards')}, count = G.DISCOVER_TALLIES.planets, minw = 4, id = 'your_collection_planets', colour = G.C.SECONDARY_SET.Planet}),
                        UIBox_button({button = 'DeckCreatorModuleBanSpectralMenu', label = {localize('b_spectral_cards')}, count = G.DISCOVER_TALLIES.spectrals, minw = 4, id = 'your_collection_spectrals', colour = G.C.SECONDARY_SET.Spectral}),
                    }}
                }}
            }}
        }
    })
end

function GUI.addBannedVoucherMenu()
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
            GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedVoucherList'), card)
        end
    end

    return create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenBanItem', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = voucher_options, w = 4.5, cycle_shoulders = true, opt_callback = 'DeckCreatorModuleChangeVoucherPage', focus_args = {snap_to = true, nav = 'wide'}, current_option = 1, colour = G.C.RED, no_pips = true}),
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Ban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleBanAllVouchers",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Unban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.RED,
                            button = "DeckCreatorModuleUnbanAllVouchers",
                            minh = 0.8,
                            minw = 3
                        })
                    }}
                }
            },
        }}
    }})
end

function GUI.addBannedJokerMenu()
    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                GUI.JokersPerPage*G.CARD_W,
                0.95*G.CARD_H,
                {card_limit = GUI.JokersPerPage, type = 'title', highlight_limit = 0, collection = true})
        table.insert(deck_tables,
                {n=G.UIT.R, config={align = "cm", padding = 0.07, no_fill = true}, nodes={
                    {n=G.UIT.O, config={object = G.your_collection[j]}}
                }}
        )
    end

    local joker_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Joker/(GUI.JokersPerPage*#G.your_collection)) do
        table.insert(joker_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Joker/(GUI.JokersPerPage*#G.your_collection))))
    end

    for i = 1, GUI.JokersPerPage do
        for j = 1, #G.your_collection do
            local center = G.P_CENTER_POOLS["Joker"][i+(j-1)*GUI.JokersPerPage]
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
            card.sticker = get_joker_win_sticker(center)
            G.your_collection[j]:emplace(card)
            GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedJokerList'), card)
        end
    end

    local t =  create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenBanItem', contents = {
        {n=G.UIT.R, config={align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = joker_options, w = 2.5, cycle_shoulders = true, opt_callback = 'DeckCreatorModuleStartingJokersChangePage', current_option = 1, colour = G.C.RED, no_pips = true, focus_args = {snap_to = true, nav = 'wide'}})
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Ban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleBanAllJokers",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Unban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.RED,
                            button = "DeckCreatorModuleUnbanAllJokers",
                            minh = 0.8,
                            minw = 3
                        })
                    }}
                }
            },
        }}
    }})
    return t
end

function GUI.addBannedTarotMenu()
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
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Tarot/11) do
        table.insert(tarot_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Tarot/11)))
    end

    for j = 1, #G.your_collection do
        for i = 1, 4+j do
            local center = G.P_CENTER_POOLS["Tarot"][i+(j-1)*(5)]
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W, G.CARD_H, nil, center)
            card:start_materialize(nil, i>1 or j>1)
            G.your_collection[j]:emplace(card)
            GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedTarotList'), card)
        end
    end

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenBanItem', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = tarot_options, w = 2.5, cycle_shoulders = true, opt_callback = 'DeckCreatorModuleChangeTarotPage', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Ban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleBanAllTarots",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Unban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.RED,
                            button = "DeckCreatorModuleUnbanAllTarots",
                            minh = 0.8,
                            minw = 3
                        })
                    }}
                }
            },
        }}
    }})
    return t
end

function GUI.addBannedPlanetMenu()
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
            GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedPlanetList'), card)
        end
    end

    local planet_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Planet / 12) do
        table.insert(planet_options,
                localize('k_page') .. ' ' .. tostring(i) .. '/' .. tostring(math.ceil(#G.P_CENTER_POOLS.Planet / 12)))
    end

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenBanItem', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    #planet_options > 1 and {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({
                            options = planet_options,
                            w = 4.5,
                            cycle_shoulders = true,
                            opt_callback =
                            'DeckCreatorModuleYourCollectionPlanetPage',
                            focus_args = { snap_to = true, nav = 'wide' },
                            current_option = 1,
                            colour = G.C.RED,
                            no_pips = true
                        })
                    }} or nil
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Ban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleBanAllPlanets",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Unban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.RED,
                            button = "DeckCreatorModuleUnbanAllPlanets",
                            minh = 0.8,
                            minw = 3
                        })
                    }}
                }
            },
        }}
    }})
    return t
end

function GUI.addBannedSpectralMenu()
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
            GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedSpectralList'), card)
        end
    end

    local spectral_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Spectral/9) do
        table.insert(spectral_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Spectral/9)))
    end

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenBanItem', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = spectral_options, w = 4.5, cycle_shoulders = true, opt_callback = 'DeckCreatorModuleChangeSpectralPage', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Ban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleBanAllSpectrals",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Unban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.RED,
                            button = "DeckCreatorModuleUnbanAllSpectrals",
                            minh = 0.8,
                            minw = 3
                        })
                    }}
                }
            },
        }}
    }})
    return t
end

function GUI.addBannedTagMenu()
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

        local isBanned = false
        local baseSize = 0.8
        for x,y in pairs(Utils.getCurrentEditingDeck().config.bannedTagList) do
            if v.name == y.key then
                isBanned = true
                break
            end
        end
        if isBanned then
            baseSize = 0.5
        end

        local discovered = v.discovered
        local temp_tag = Tag(v.key, true)
        if not v.discovered then temp_tag.hide_ability = true end
        local temp_tag_ui, temp_tag_sprite = Helper.generateTagUI(temp_tag, baseSize, { key = 'hoveredTagBanItemsAddToBanKey', sprite = 'hoveredTagBanItemsAddToBanSprite' })
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


    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenBanItem', contents = {
        {n=G.UIT.R, config={align = "cm"}, nodes={
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
        }},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    UIBox_button({
                        label = {" Ban All "},
                        shadow = true,
                        scale = 0.75 * 0.4,
                        colour = G.C.BOOSTER,
                        button = "DeckCreatorModuleBanAllTags",
                        minh = 0.8,
                        minw = 3
                    }),
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    UIBox_button({
                        label = {" Unban All "},
                        shadow = true,
                        scale = 0.75 * 0.4,
                        colour = G.C.RED,
                        button = "DeckCreatorModuleUnbanAllTags",
                        minh = 0.8,
                        minw = 3
                    })
                }
            },
        }}
    }})
    return t
end

function GUI.addBannedBlindMenu()

    local blind_matrix = {
        {},{},{}, {}, {}, {}
    }
    local blind_tab = {}
    for k, v in pairs(G.P_BLINDS) do
        blind_tab[#blind_tab+1] = v
    end

    local blinds_per_row = math.ceil(#blind_tab/6)
    table.sort(blind_tab, function (a, b) return a.order < b.order end)

    local blinds_to_be_alerted = {}
    for k, v in ipairs(blind_tab) do
        if v.name ~= 'Big Blind' and v.name ~= 'Small Blind' then
            local isBanned = false
            local baseH = 1.3
            local baseW = 1.3
            local atlas = 'blind_chips'
            if v.atlas then
                atlas = v.atlas
            end
            for x,y in pairs(Utils.getCurrentEditingDeck().config.bannedBlindList) do
                if v.name == y.key then
                    isBanned = true
                    break
                end
            end
            if isBanned then
                baseH = 0.85
                baseW = 0.85
            end

            local discovered = v.discovered
            local temp_blind = AnimatedSprite(0,0,baseW,baseH, G.ANIMATION_ATLAS[atlas], discovered and v.pos or G.b_undiscovered.pos)
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
            temp_blind.config = {blind = v, force_focus = true, pos = v.pos }
            if discovered and not v.alerted then
                blinds_to_be_alerted[#blinds_to_be_alerted+1] = temp_blind
            end
            temp_blind.hover = function()
                if not G.CONTROLLER.dragging.target or G.CONTROLLER.using_touch then
                    if not temp_blind.hovering and temp_blind.states.visible then
                        temp_blind.hovering = true
                        temp_blind.hover_tilt = 3
                        temp_blind:juice_up(0.05, 0.02)
                        Utils.hoveredBlindBanItemsAddToBanKey = v.name
                        Utils.hoveredBlindBanItemsAddToBanSprite = temp_blind
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
                temp_blind.stop_hover = function()
                    temp_blind.hovering = false
                    Utils.hoveredBlindBanItemsAddToBanKey = nil
                    Utils.hoveredBlindBanItemsAddToBanSprite = nil
                    Node.stop_hover(temp_blind)
                    temp_blind.hover_tilt = 0
                end
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

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenBanItem', contents = {
        {n=G.UIT.R, config={align = "cm"}, nodes={
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
        }},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    UIBox_button({
                        label = {" Ban All "},
                        shadow = true,
                        scale = 0.75 * 0.4,
                        colour = G.C.BOOSTER,
                        button = "DeckCreatorModuleBanAllBlinds",
                        minh = 0.8,
                        minw = 3
                    }),
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    UIBox_button({
                        label = {" Unban All "},
                        shadow = true,
                        scale = 0.75 * 0.4,
                        colour = G.C.RED,
                        button = "DeckCreatorModuleUnbanAllBlinds",
                        minh = 0.8,
                        minw = 3
                    })
                }
            },
        }}
    }})
    return t
end

function GUI.addBannedBoosterMenu()

    local deck_tables = {}

    G.your_collection = {}
    for j = 1, 2 do
        G.your_collection[j] = CardArea(
                G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
                (5.25)*G.CARD_W,
                1.3*G.CARD_H,
                {card_limit = 4, type = 'title', highlight_limit = 0, collection = true})
        table.insert(deck_tables,
                {n=G.UIT.R, config={align = "cm", padding = 0, no_fill = true}, nodes={
                    {n=G.UIT.O, config={object = G.your_collection[j]}}
                }}
        )
    end

    local booster_options = {}
    for i = 1, math.ceil(#G.P_CENTER_POOLS.Booster/8) do
        table.insert(booster_options, localize('k_page')..' '..tostring(i)..'/'..tostring(math.ceil(#G.P_CENTER_POOLS.Booster/8)))
    end

    for j = 1, #G.your_collection do
        for i = 1, 4 do
            local center = G.P_CENTER_POOLS["Booster"][i+(j-1)*4]
            local card = Card(G.your_collection[j].T.x + G.your_collection[j].T.w/2, G.your_collection[j].T.y, G.CARD_W*1.27, G.CARD_H*1.27, nil, center)
            card:start_materialize(nil, i>1 or j>1)
            G.your_collection[j]:emplace(card)
            GUI.runBannedFlips(GUI.checkBannedForFlips(center, 'bannedBoosterList'), card)
        end
    end

    local t = create_UIBox_generic_options({ back_func = 'DeckCreatorModuleOpenBanItem', contents = {
        {n=G.UIT.R, config={align = "cm", minw = 2.5, padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05}, nodes=deck_tables},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        create_option_cycle({options = booster_options, w = 4.5, cycle_shoulders = true, opt_callback = 'DeckCreatorModuleChangeBoosterPage', focus_args = {snap_to = true, nav = 'wide'},current_option = 1, colour = G.C.RED, no_pips = true})
                    }}
                }
            },
            {
                n = G.UIT.C,
                config = { align = "cm", minw = 2, padding = 0.1, r = 0.1, colour = G.C.CLEAR },
                nodes = {
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Ban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.BOOSTER,
                            button = "DeckCreatorModuleBanAllBoosters",
                            minh = 0.8,
                            minw = 3
                        })
                    }},
                    {n=G.UIT.R, config={align = "cm"}, nodes={
                        UIBox_button({
                            label = {" Unban All "},
                            shadow = true,
                            scale = 0.75 * 0.4,
                            colour = G.C.RED,
                            button = "DeckCreatorModuleUnbanAllBoosters",
                            minh = 0.8,
                            minw = 3
                        })
                    }}
                }
            },

        }}
    }})
    return t
end


-- Static Mods
function GUI.initializeStaticMods()

    local groupsOrder = {"Gameplay", "Money", "Shop", "Booster Packs", "Blind", "Seals", "Enhancements", "Glass Break", "Boss Win Tags"}

    local allGroups = {}
    local gameplayMods = {
        {
            group = "Gameplay",
            label = "Aces are considered Face cards",
            property = 'aces_are_faces'
        },
        {
            group = "Gameplay",
            label = "7s are considered Face cards",
            property = 'sevens_are_faces'
        },
        {
            group = "Gameplay",
            label = "Stone cards are considered Face cards",
            property = "stones_are_faces"
        },
        {
            group = "Gameplay",
            label = "Chips cannot exceed current $",
            property = 'chips_dollar_cap'
        },
        {
            group = "Gameplay",
            label = "Hold -1 cards in hand per $5",
            property = 'minus_hand_size_per_X_dollar'
        },
        {
            group = "Gameplay",
            label = "All played cards become debuffed after scoring",
            property = 'debuff_played_cards'
        },
        {
            group = "Gameplay",
            label = "Death cards transform a random card in hand instead",
            property = 'death_targets_random_card'
        },
        {
            group = "Gameplay",
            label = "Ankh and Hex cannot destroy Jokers",
            property = 'spectral_cards_cannot_destroy_jokers'
        },
        {
            group = "Gameplay",
            label = "Ectoplasm cannot reduce your hand size",
            property = 'ectoplasm_cannot_change_hand_size'
        },
        {
            group = "Gameplay",
            label = "Ouija cannot reduce your hand size",
            property = 'ouija_cannot_change_hand_size'
        },
        {
            group = "Gameplay",
            label = "Wraith cannot modify your money",
            property = 'wraith_cannot_set_money_to_zero'
        },
        {
            group = "Gameplay",
            label = "Spectral cards add 1 additional Seal",
            property = 'spectral_seals_add_additional'
        },
        {
            group = "Gameplay",
            label = "Spectral cards cannot destroy cards in your hand",
            property = 'no_spectral_destroy_cards'
        },
        {
            group = "Gameplay",
            label = "Chance to Balance Chips and Mult",
            property = "balance_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Gameplay",
            label = "1 in X cards are drawn face down",
            property = "flipped_cards",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Gameplay",
            label = "Number of Cards to Draw on Play or Discard",
            property = "draw_to_hand_size",
            options = Utils.generateBoundedIntegerListWithNoneOption(1, 9999),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Gameplay",
            label = "Gain X extra levels whenever a hand is upgraded",
            property = "extra_hand_level_upgrades",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Gameplay",
            label = "Chance to Increase Rank of Discarded Cards by 1",
            property = "chance_to_increase_discard_cards_rank",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Gameplay",
            label = "Chance to Increase Rank of Drawn Cards by 1",
            property = "chance_to_increase_drawn_cards_rank",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        --[[{
            group = "Gameplay",
            label = "Mult Reduced by X Percent",
            property = "mult_reduction_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Gameplay",
            label = "Chips Reduced by X Percent",
            property = "chip_reduction_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },]]
        {
            group = "Gameplay",
            label = "Multiply all probabilities by X",
            property = "multiply_probabilities",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Gameplay",
            label = "Divide all probabilities by X",
            property = "divide_probabilities",
            options = Utils.generateBoundedIntegerList(1, 9999),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Gameplay",
            label = "Edition Rate",
            property = "edition_rate",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Gameplay",
            label = "Chance to destroy a random Joker at the end of Ante 4",
            property = "destroy_random_joker_after_ante_four",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        }
    }
    local moneyMods = {
        {
            group = "Money",
            label = "Jokers sell for full price",
            property = "full_price_jokers"
        },
        {
            group = "Money",
            label = "Consumables sell for full price",
            property = "full_price_consumables"
        },
        {
            group = "Money",
            label = "Raise prices by $1 on every purchase",
            property = "inflation"
        },
        {
            group = "Money",
            label = "Allow funds to drop to -$50",
            property = 'negative_fifty_dollars_allowed'
        },
        {
            group = "Money",
            label = "Boosters cost $X more per Ante",
            property = "booster_ante_scaling",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Money",
            label = "Gain $X per round for each Negative Joker",
            property = "negative_joker_money",
            options = Utils.generateBoundedIntegerList(-300, 300),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Money",
            label = "Gain $X per round for each Enhanced card",
            property = "enhanced_dollars_per_round",
            options = Utils.generateBoundedIntegerList(-300, 300),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Money",
            label = "Gain $X when any Booster Pack is skipped",
            property = "gain_dollars_when_skip_booster",
            options = Utils.generateBoundedIntegerList(-300, 300),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Money",
            label = "Add $X Sell Value to a random Joker each round",
            property = "random_sell_value_increase",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Money",
            label = "Remove $X Sell Value from a random Joker each round",
            property = "random_sell_value_decrease",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
    }
    local shopMods = {
        {
            group = "Shop",
            label = "Reroll also replaces Booster Packs",
            property = "reroll_boosters"
        },
        {
            group = "Shop",
            label = "Allow Legendary Jokers to appear",
            property = "allow_legendary_jokers_everywhere"
        },
        {
            group = "Shop",
            label = "Eternal Jokers appear in shop",
            property = "enable_eternals_in_shop"
        },
        {
            group = "Shop",
            label = "Perishable Jokers appear in shop",
            property = "enable_perishables_in_shop"
        },
        {
            group = "Shop",
            label = "Rental Jokers appear in shop",
            property = "enable_rentals_in_shop"
        },
        {
            group = "Shop",
            label = "Allow The Soul to Appear",
            property = "allow_soul"
        },
        {
            group = "Shop",
            label = "Allow Black Hole to Appear",
            property = "allow_black_hole"
        },
        {
            group = "Shop",
            label = "Allow Duplicate Items to appear",
            property = "allow_duplicate_jokers"
        },
        {
            group = "Shop",
            label = "One random card in initial shop is free",
            property = "one_free_card_in_shop"
        },
        {
            group = "Shop",
            label = "Voucher is always free",
            property = "voucher_is_free"
        },
        {
            group = "Shop",
            label = "One random Booster Pack in initial shop is free",
            property = "one_free_booster_in_shop"
        },
        {
            group = "Shop",
            label = "One random item in initial shop is free",
            property = "one_free_item_in_shop"
        },
        {
            group = "Shop",
            label = "Joker Slots",
            property = "shop_slots",
            options = Utils.generateBoundedIntegerList(0, 5),
            isToggle = false
        },
        {
            group = "Shop",
            label = "Eternal Rate",
            property = "eternal_rate",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Shop",
            label = "Booster Pack Slots",
            property = "booster_pack_slots",
            options = Utils.generateBoundedIntegerList(0, 99),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Shop",
            label = "Perishable Rate",
            property = "perishable_rate",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Shop",
            label = "Voucher Slots",
            property = "voucher_slots",
            options = Utils.generateBoundedIntegerList(0, 99),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Shop",
            label = "Rental Rate",
            property = "rental_rate",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        }
    }
    local boosterMods = {
        {
            group = "Booster Packs",
            label = "Celestial packs always contain most played hand",
            property = "always_telescoping"
        },
        {
            group = "Booster Packs",
            label = "Celestial Packs never contain most played hand",
            property = "never_telescoping"
        },
        {
            group = "Booster Packs",
            label = "Allow Spectral cards to appear in Arcana Packs",
            property = "spectral_cards_in_arcana"
        },
        {
            group = "Booster Packs",
            label = "Allow Planet cards to appear in Arcana Packs",
            property = "planet_cards_in_arcana"
        },
        {
            group = "Booster Packs",
            label = "Allow Tarot cards to appear in Spectral Packs",
            property = "tarot_cards_in_spectral"
        },
        {
            group = "Booster Packs",
            label = "Allow Planet cards to appear in Spectral Packs",
            property = "planet_cards_in_spectral"
        },
        {
            group = "Booster Packs",
            label = "Allow Tarot cards to appear in Celestial Packs",
            property = "tarot_cards_in_celestial"
        },
        {
            group = "Booster Packs",
            label = "Allow Spectral cards to appear in Celestial Packs",
            property = "spectral_cards_in_celestial"
        },
        {
            group = "Booster Packs",
            label = "Standard Pack Enhancement Rate",
            property = "standard_pack_enhancement_rate",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Booster Packs",
            label = "Standard Pack Edition Rate",
            property = "standard_pack_edition_rate",
            options = Utils.generateBoundedIntegerList(0, 300),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Booster Packs",
            label = "Standard Pack Seal Rate",
            property = "standard_pack_seal_rate",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Booster Packs",
            label = "Extra Booster Pack Choices",
            property = "extra_booster_pack_choices",
            options = Utils.generateBoundedIntegerList(0, 10),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Booster Packs",
            label = "Extra cards in Arcana packs",
            property = "extra_arcana_pack_cards",
            options = Utils.generateBoundedIntegerList(0, 5),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Booster Packs",
            label = "Extra cards in Celestial packs",
            property = "extra_celestial_pack_cards",
            options = Utils.generateBoundedIntegerList(0, 5),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Booster Packs",
            label = "Extra cards in Spectral packs",
            property = "extra_spectral_pack_cards",
            options = Utils.generateBoundedIntegerList(0, 5),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Booster Packs",
            label = "Extra cards in Standard packs",
            property = "extra_standard_pack_cards",
            options = Utils.generateBoundedIntegerList(0, 5),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Booster Packs",
            label = "Extra cards in Buffoon packs",
            property = "extra_buffoon_pack_cards",
            options = Utils.generateBoundedIntegerList(0, 5),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Booster Packs",
            label = "Chance to spend $0 when purchasing Booster Packs",
            property = "chance_for_free_booster",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
    }
    local blindMods = {
        {
            group = "Blind",
            label = "Chance to Autoskip Shop after Small Blind",
            property = "skip_shop_chance_small_blind",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to Autoskip Shop after Big Blind",
            property = "skip_shop_chance_big_blind",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to Autoskip Shop after Boss",
            property = "skip_shop_chance_boss",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to Autoskip Shop after Every Blind",
            property = "skip_shop_chance_any",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to gain a random Negative Joker if shop skipped",
            property = "chance_for_random_negative_joker_on_shop_skip",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to gain $20 if shop skipped",
            property = "chance_for_twenty_dollars_on_shop_skip",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },

        {
            group = "Blind",
            label = "Chance to Disable Skip on Small Blind",
            property = "skip_blind_disabled_chance_small_blind",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to Disable Skip on Big Blind",
            property = "skip_blind_disabled_chance_big_blind",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to Disable Skip on Every Blind",
            property = "skip_blind_disabled_chance_any",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to gain $5 if skip disabled",
            property = "chance_for_five_dollars_on_skip_disable",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to gain $15 if skip disabled",
            property = "chance_for_fifteen_dollars_on_skip_disable",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Blind",
            label = "Chance to gain random Negative Joker if skip disabled",
            property = "chance_for_negative_joker_on_skip_disable",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
    }
    local sealMods = {
        {
            group = "Seals",
            label = "On Blue Seal trigger switch to another random Seal",
            property = 'blue_seal_switch_trigger'
        },
        {
            group = "Seals",
            label = "Blue Seals always generate Planet of most played hand",
            property = 'blue_seal_always_most_played'
        },
        {
            group = "Seals",
            label = "On Purple Seal trigger switch to another random Seal",
            property = 'purple_seal_switch_trigger'
        },
        {
            group = "Seals",
            label = "Replace Red Seal 'Again!' text with messages from file",
            property = 'red_seal_silly_messages'
        },
        {
            group = "Seals",
            label = "Extra Red Seal Repetitions",
            property = "extra_red_seal_repetitions",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Seals",
            label = "Chance to Double Gold Seal Money",
            property = "chance_to_double_gold_seal",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Seals",
            label = "Chance to receive second Tarot on Purple Seal discard",
            property = "chance_for_two_purple_tarots",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Seals",
            label = "Chance to disable retriggers on Red Seal cards",
            property = "chance_to_disable_red_seal_retriggers",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Seals",
            label = "Chance for Purple Seals to create Spectrals instead",
            property = "chance_purple_seal_rolls_spectral",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Seals",
            label = "Chance to receive random Negative Joker when Blue Seal triggers",
            property = "chance_for_negative_joker_on_blue_seal_trigger",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        }
    }
    local enhanceMods = {
        {
            group = "Enhancements",
            label = "Chance to consider 7s as Lucky Cards",
            property = "make_sevens_lucky",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Enhancements",
            label = "Chance to consider Stones as Lucky Cards",
            property = "make_stones_lucky",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Enhancements",
            label = "Chance to triple mult from Mult cards",
            property = "triple_mult_cards_chance",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Enhancements",
            label = "Chance to disable mult from Mult cards",
            property = "disable_mult_cards_chance",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Enhancements",
            label = "Chance to triple money from Gold cards",
            property = "chance_to_triple_gold_money",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Enhancements",
            label = "Chance to disable money from Gold cards",
            property = "chance_to_disable_gold_money",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            isToggle = false
        },
    }
    local glassBreakMods = {
        {
            group = "Glass Break",
            label = "Gain $X on Glass Break",
            property = "broken_glass_money",
            options = Utils.generateBoundedIntegerList(-300, 300),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Glass Break",
            label = "Chance to gain $10 on Glass Break",
            property = "gain_ten_dollars_glass_break_chance",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Glass Break",
            label = "Chance to replace broken Glass with Stones",
            property = "replace_broken_glass_with_stones_chance",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Glass Break",
            label = "Chance to replace broken Glass with random cards",
            property = "replace_broken_glass_with_random_cards_chance",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Glass Break",
            label = "Chance to receive random Negative Joker on Glass Break",
            property = "negative_joker_for_broken_glass",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            isToggle = false
        },
        {
            group = "Glass Break",
            label = "Chance to destroy a random Joker on Glass Break",
            property = "destroy_joker_on_broken_glass",
            options = Utils.generateBigIntegerList(),
            multiArrows = true,
            isToggle = false
        },
    }
    local bossWinTagMods = {
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Uncommon Tag on Boss Win",
            property = "uncommon_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Rare Tag on Boss Win",
            property = "rare_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Foil Tag on Boss Win",
            property = "foil_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Negative Tag on Boss Win",
            property = "negative_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Holographic Tag on Boss Win",
            property = "holographic_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Polychrome Tag on Boss Win",
            property = "polychrome_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Investment Tag on Boss Win",
            property = "investment_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Voucher Tag on Boss Win",
            property = "voucher_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Boss Tag on Boss Win",
            property = "boss_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Standard Tag on Boss Win",
            property = "mega_standard_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Charm Tag on Boss Win",
            property = "charm_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Meteor Tag on Boss Win",
            property = "meteor_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Buffoon Tag on Boss Win",
            property = "buffoon_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Handy Tag on Boss Win",
            property = "handy_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Garbage Tag on Boss Win",
            property = "garbage_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Ethereal Tag on Boss Win",
            property = "ethereal_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Coupon Tag on Boss Win",
            property = "coupon_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Double Tag on Boss Win",
            property = "double_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Juggle Tag on Boss Win",
            property = "juggle_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain D6 Tag on Boss Win",
            property = "d6_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Top-up Tag on Boss Win",
            property = "top_up_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Skip Tag on Boss Win",
            property = "skip_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Orbital Tag on Boss Win",
            property = "orbital_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        },
        {
            group = "Boss Win Tags",
            label = "Chance to Gain Economy Tag on Boss Win",
            property = "economy_tag_percent",
            options = Utils.generateBoundedIntegerList(0, 100),
            multiArrows = true,
            minorArrows = true,
            isToggle = false
        }
    }

    table.insert(allGroups, gameplayMods)
    table.insert(allGroups, moneyMods)
    table.insert(allGroups, shopMods)
    table.insert(allGroups, boosterMods)
    table.insert(allGroups, blindMods)
    table.insert(allGroups, sealMods)
    table.insert(allGroups, enhanceMods)
    table.insert(allGroups, glassBreakMods)
    table.insert(allGroups, bossWinTagMods)

    for x,y in pairs(allGroups) do
        for k,v in pairs(y) do
            table.insert(GUI.StaticModsObjects, StaticMod:new(v))
        end
    end
    GUI.StaticMods = GUI.prepareMods(GUI.StaticModsObjects, groupsOrder)
end

function GUI.prepareMods(modList, groupsOrder)
    local groups = {} -- Stores mods categorized

    for _, groupName in ipairs(groupsOrder) do
        groups[groupName] = {toggles = {}, selectors = {}}
    end

    -- Categorize mods into toggles and selectors within their groups
    for _, mod in ipairs(modList) do
        if mod.isToggle then
            table.insert(groups[mod.group].toggles, mod)
        else
            table.insert(groups[mod.group].selectors, mod)
        end
    end

    local pages = {}
    local currentPage = 1
    for _, groupName in ipairs(groupsOrder) do
        local group = groups[groupName]

        -- Process toggles with a maximum of 8 per page
        for i = 1, #group.toggles, 8 do
            local pageMods = {}
            for j = i, math.min(i + 7, #group.toggles) do
                local column = ((j - i) % 2) + 1 -- Balance across two columns
                table.insert(pageMods, {mod = group.toggles[j], column = column})
            end
            pages[currentPage] = pageMods
            currentPage = currentPage + 1
        end

        -- Process selectors with a maximum of 6 per page
        for i = 1, #group.selectors, 6 do
            local pageMods = {}
            for j = i, math.min(i + 5, #group.selectors) do
                local column = ((j - i) % 2) + 1 -- Balance across two columns
                table.insert(pageMods, {mod = group.selectors[j], column = column})
            end
            pages[currentPage] = pageMods
            currentPage = currentPage + 1
        end
    end

    return pages
end

function GUI.staticModsPreUpdate()
    if GUI.OpenTab ~= "Static Mods" then
        return
    end
end

function GUI.staticModsPostUpdate()
    collectgarbage("collect")
end

function GUI.staticModsPageStatic()
    local pages = {}
    for i = 1, #GUI.StaticMods do
        table.insert(pages, "Page " .. i .. "/" .. #GUI.StaticMods)
    end
    return {
        n = G.UIT.ROOT,
        config={
            align = "cm",
            colour = G.C.CLEAR,
            padding = 0.2,
            minh = 7,
            minw = 22
        },
        nodes = {
            {n=G.UIT.R, config={align = "cm", padding = 0.1 }, nodes={
                {n=G.UIT.O, config={padding = 2, id = 'staticModsTitle', object = Moveable()}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.5 }, nodes={

            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
                {
                    n = G.UIT.C,
                    config = { align = "cm", padding = 0.2, r = 0.1, colour = G.C.CLEAR, minh = 3, minw = 10 },
                    nodes = {

                        {n=G.UIT.R, config={align = "cm", padding = 0.1, minh = 3, minw = 2}, nodes={
                            {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={}},
                            {n=G.UIT.O, config={padding = 2, id = 'staticModsColumnOne', object = Moveable()}},
                        }},
                    }
                },
                {
                    n = G.UIT.C,
                    config = { align = "cm", padding = 0.2, r = 0.1, colour = G.C.CLEAR, minh = 3, minw = 10 },
                    nodes = {
                        {n=G.UIT.R, config={align = "cm", padding = 0.1, minh = 3, minw = 2}, nodes={
                            {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={}},
                            {n=G.UIT.O, config={padding = 2, id = 'staticModsColumnTwo', object = Moveable()}},
                        }},
                    }
                }
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.1 }, nodes={
                create_option_cycle({label = "", scale = 0.8, options = pages, opt_callback = 'DeckCreatorModuleChangeStaticModsPage', current_option = 1, no_pips = true }),
            }}
        }
    }
end

function GUI.staticModsSetPage(page)
    page = page or 1
    if page > #GUI.StaticMods then
        page = 1
    end
    GUI.StaticModsCurrentPageName = GUI.StaticMods[page][1].mod.group
    return page
end

function GUI.dynamicStaticModsTitle(page)

    if GUI.OpenTab ~= "Static Mods" then
        return {
            n=G.UIT.ROOT,
            config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 8, minh = 5},
            nodes={}
        }
    end

    page = GUI.staticModsSetPage(page)
    return {n=G.UIT.T, config={text = GUI.StaticModsCurrentPageName, scale = 0.5, colour = G.C.UI.TEXT_LIGHT}}
end

function GUI.dynamicStaticModsGetColumnMods(page, column)
    page = GUI.staticModsSetPage(page)
    local pageMods = GUI.StaticMods[page]
    local columnMods = {}
    for k,v in ipairs(pageMods) do
        if v.column == column then
            table.insert(columnMods, {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    padding = 0.1
                },
                nodes = {
                    v.mod:generate_ui_element()
                }
            })
        end
    end
    return columnMods
end

function GUI.dynamicStaticModsGenerateColumn(column, page)

    if GUI.OpenTab ~= "Static Mods" then
        return {
            n=G.UIT.ROOT,
            config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 8, minh = 5},
            nodes={}
        }
    end
    page = GUI.staticModsSetPage(page)
    local columnMods = GUI.dynamicStaticModsGetColumnMods(page, column)

    return {
        n=G.UIT.ROOT,
        config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 8, minh = 5},
        nodes=columnMods
    }
end

function GUI.updateAllStaticModAreas(page)
    page = GUI.staticModsSetPage(page)
    GUI.staticModsPreUpdate()
    GUI.DynamicUIManager.updateDynamicAreas({
        ["staticModsTitle"] = GUI.dynamicStaticModsTitle(page)
    })
    GUI.DynamicUIManager.updateDynamicAreas({
        ["staticModsColumnOne"] = GUI.dynamicStaticModsGenerateColumn(1, page)
    })
    GUI.DynamicUIManager.updateDynamicAreas({
        ["staticModsColumnTwo"] = GUI.dynamicStaticModsGenerateColumn(2, page)
    })
    GUI.staticModsPostUpdate()
end

-- Dynamic Mods
function GUI.dynamicModsPreUpdate()
    if GUI.OpenTab ~= "Dynamic Mods" then
        return
    end
end

function GUI.dynamicModsPostUpdate()
    collectgarbage("collect")
end

function GUI.dynamicModsPageStatic()
    return {
        n = G.UIT.ROOT,
        config={
            align = "cm",
            colour = G.C.CLEAR,
            padding = 0.2,
            minh = 7,
            minw = 10
        },
        nodes = {
            {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
                {
                    n = G.UIT.C,
                    config = { align = "cm", padding = 0.2, r = 0.1, colour = G.C.CLEAR, minh = 3, minw = 10 },
                    nodes = {

                        {n=G.UIT.R, config={align = "cm", padding = 0.1, minh = 3, minw = 2}, nodes={
                            {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={}},
                            {n=G.UIT.O, config={padding = 2, id = 'dynamicModsColumnOne', object = Moveable()}},
                        }},
                    }
                },
                {
                    n = G.UIT.C,
                    config = { align = "cm", padding = 0.2, r = 0.1, colour = G.C.CLEAR, minh = 3, minw = 10 },
                    nodes = {
                        {n=G.UIT.R, config={align = "cm", padding = 0.1, minh = 3, minw = 2}, nodes={
                            {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={}},
                            {n=G.UIT.O, config={padding = 2, id = 'dynamicModsColumnTwo', object = Moveable()}},
                        }},
                    }
                }
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.1 }, nodes={
                create_option_cycle({label = "", scale = 0.8, options = { "Page 1/4", "Page 2/4", "Page 3/4", "Page 4/4"}, opt_callback = 'DeckCreatorModuleChangeDynamicModsPage', current_option = 1, no_pips = true }),
            }}
        }
    }
end

function GUI.dynamicDynamicModsColumnOne(page)

    if GUI.OpenTab ~= "Dynamic Mods" then
        return {
            n=G.UIT.ROOT,
            config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 8, minh = 5},
            nodes={}
        }
    end

    local output = GUI.dynamicModsPageOneColumnOne()
    if page == 2 then
        output = GUI.dynamicModsPageTwoColumnOne()
    elseif page == 3 then
        output = GUI.dynamicModsPageThreeColumnOne()
    elseif page == 4 then
        output = GUI.dynamicModsPageFourColumnOne()
    end

    return {
        n=G.UIT.ROOT,
        config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 8, minh = 5},
        nodes=output
    }
end

function GUI.dynamicDynamicModsColumnTwo(page)

    if GUI.OpenTab ~= "Dynamic Mods" then
        return {
            n=G.UIT.ROOT,
            config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 8, minh = 5},
            nodes={}
        }
    end

    local output = GUI.dynamicModsPageOneColumnTwo()
    if page == 2 then
        output = GUI.dynamicModsPageTwoColumnTwo()
    elseif page == 3 then
        output = GUI.dynamicModsPageThreeColumnTwo()
    elseif page == 4 then
        output = GUI.dynamicModsPageFourColumnTwo()
    end

    return {
        n=G.UIT.ROOT,
        config={align = "cm", padding = 0, colour = G.C.BLACK, r = 0.1, minw = 8, minh = 5},
        nodes=output
    }
end

function GUI.updateAllDynamicModAreas(page)
    GUI.dynamicModsPreUpdate()
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicModsColumnOne"] = GUI.dynamicDynamicModsColumnOne(page)
    })
    GUI.DynamicUIManager.updateDynamicAreas({
        ["dynamicModsColumnTwo"] = GUI.dynamicDynamicModsColumnTwo(page)
    })
    GUI.dynamicModsPostUpdate()
end

function GUI.dynamicModsPageOneColumnOne()
    return {
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
                create_toggle({label = "No Aces", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'no_aces'}),

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
        }
    }
end

function GUI.dynamicModsPageOneColumnTwo()
    return {
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
                create_toggle({label = "Start with 1 Random Voucher", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'one_random_voucher'}),
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
        }
    }
end

function GUI.dynamicModsPageTwoColumnOne()
    return {
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {
                Helper.createOptionSelector({label = "X Random Cards become Polychrome", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomPolychromeCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_polychrome_cards
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
                Helper.createOptionSelector({label = "X Random Cards become Holographic", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomHolographicCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_holographic_cards
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
                Helper.createOptionSelector({label = "Start with X Random Jokers", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomStartingJokers', current_option = (
                        Utils.getCurrentEditingDeck().config.random_starting_jokers
                ), multiArrows = true })
            }
        }
    }
end

function GUI.dynamicModsPageTwoColumnTwo()
    return {
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {

                Helper.createOptionSelector({label = "X Random Cards become Foil", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomFoilCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_foil_cards
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

                Helper.createOptionSelector({label = "X Random Cards gain a Random Edition", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomEditionCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_edition_cards
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
                Helper.createOptionSelector({label = "Increase Starting Money ($0 - $X)", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomizeMoneyConfigurable', current_option = (
                        Utils.getCurrentEditingDeck().config.randomize_money_configurable
                ), multiArrows = true })
            }
        }
    }
end

function GUI.dynamicModsPageThreeColumnOne()
    return {
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {
                Helper.createOptionSelector({label = "X Random Cards become Bonus", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomBonusCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_bonus_cards
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
                Helper.createOptionSelector({label = "X Random Cards become Glass", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomGlassCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_glass_cards
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
                Helper.createOptionSelector({label = "X Random Cards become Lucky", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomLuckyCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_lucky_cards
                ), multiArrows = true })
            }
        }
    }
end

function GUI.dynamicModsPageThreeColumnTwo()
    return {
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {
                Helper.createOptionSelector({label = "X Random Cards become Steel", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomSteelCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_steel_cards
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
                Helper.createOptionSelector({label = "X Random Cards become Stone", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomStoneCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_stone_cards
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
                Helper.createOptionSelector({label = "X Random Cards become Wild", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomWildCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_wild_cards
                ), multiArrows = true })
            }
        }
    }
end

function GUI.dynamicModsPageFourColumnOne()
    return {
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {
                Helper.createOptionSelector({label = "X Random Cards become Mult", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomMultCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_mult_cards
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
                Helper.createOptionSelector({label = "X Random Cards become Gold", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomGoldCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_gold_cards
                ), multiArrows = true })
                --create_toggle({label = "Scramble Number of Hands & Discards", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_hands_discards'}),
            }
        },
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {

                --create_toggle({label = "Scramble All Money Settings", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_money_settings'}),
            }
        },
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {
               -- create_toggle({label = "Random Starting Items", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'random_starting_items'}),
            }
        },
    }
end

function GUI.dynamicModsPageFourColumnTwo()
    return {
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {
                Helper.createOptionSelector({label = "X Random Cards gain Random Enhancement", scale = 0.8, options = Utils.generateBigIntegerList(), opt_callback = 'DeckCreatorModuleChangeRandomEnhancementCards', current_option = (
                        Utils.getCurrentEditingDeck().config.random_enhancement_cards
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
                --create_toggle({label = "Increase Starting Money ($0 - $20)", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_money_small'}),
            }
        },
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {

                --create_toggle({label = "Scramble Appearance Rate Settings", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomize_appearance_rates'}),
            }
        },
        {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.1
            },
            nodes = {

                --create_toggle({label = "Randomly Enable Gameplay Settings", ref_table = Utils.getCurrentEditingDeck().config, ref_value = 'randomly_enable_gameplay_settings'}),
            }
        },
    }
end

return GUI
