local Utils = require "Utils"
local CardUtils = require "CardUtils"

local Helper = {}

local FakeBlind = {}
function FakeBlind:debuff_card(arg) end

function Helper.registerGlobals()
    G.FUNCS.DeckCreatorModuleOptionCycle = function(e)
        local from_val = e.config.ref_table.options[e.config.ref_table.current_option]
        local from_key = e.config.ref_table.current_option
        local old_pip = e.UIBox:get_UIE_by_ID('pip_'..e.config.ref_table.current_option, e.parent.parent)
        local cycle_main = e.UIBox:get_UIE_by_ID('cycle_main', e.parent.parent)

        if cycle_main and cycle_main.config.h_popup then
            cycle_main:stop_hover()
            G.E_MANAGER:add_event(Event({
                func = function()
                    cycle_main:hover()
                    return true
                end
            }))
        end

        if e.config.ref_value == 'l' then
            --cycle left
            e.config.ref_table.current_option = e.config.ref_table.current_option - 1
            if e.config.ref_table.current_option <= 0 then e.config.ref_table.current_option = #e.config.ref_table.options end
        elseif e.config.ref_value == 'll' then
            --cycle left x10
            local inc = 10
            if e.config.minorArrows then
                inc = 5
            end
            e.config.ref_table.current_option = e.config.ref_table.current_option - inc
            if e.config.ref_table.current_option <= 0 then e.config.ref_table.current_option = #e.config.ref_table.options end
        elseif e.config.ref_value == 'lll' then
            --cycle left x100
            local inc = 100
            if e.config.minorArrows then
                inc = 10
            end
            e.config.ref_table.current_option = e.config.ref_table.current_option - inc
            if e.config.ref_table.current_option <= 0 then e.config.ref_table.current_option = #e.config.ref_table.options end
        elseif e.config.ref_value == 'r' then
            --cycle right
            e.config.ref_table.current_option = e.config.ref_table.current_option + 1
            if e.config.ref_table.current_option > #e.config.ref_table.options then e.config.ref_table.current_option = 1 end
        elseif e.config.ref_value == 'rr' then
            --cycle right x10
            local inc = 10
            if e.config.minorArrows then
                inc = 5
            end
            e.config.ref_table.current_option = e.config.ref_table.current_option + inc
            if e.config.ref_table.current_option > #e.config.ref_table.options then e.config.ref_table.current_option = 1 end
        elseif e.config.ref_value == 'rrr' then
            --cycle right x100
            local inc = 100
            if e.config.minorArrows then
                inc = 10
            end
            e.config.ref_table.current_option = e.config.ref_table.current_option + inc
            if e.config.ref_table.current_option > #e.config.ref_table.options then e.config.ref_table.current_option = 1 end
        end
        local to_val = e.config.ref_table.options[e.config.ref_table.current_option]
        local to_key = e.config.ref_table.current_option
        e.config.ref_table.current_option_val = e.config.ref_table.options[e.config.ref_table.current_option]

        local new_pip = e.UIBox:get_UIE_by_ID('pip_'..e.config.ref_table.current_option, e.parent.parent)

        if old_pip then old_pip.config.colour = G.C.BLACK end
        if new_pip then new_pip.config.colour = G.C.WHITE end

        if e.config.ref_table.opt_callback then
            G.FUNCS[e.config.ref_table.opt_callback]{
                from_val = from_val,
                to_val = to_val,
                from_key = from_key,
                to_key = to_key,
                cycle_config = e.config.ref_table
            }
        end
    end
end

function Helper.createOptionSelector(args)
    args = args or {}
    args.colour = args.colour or G.C.RED
    args.options = args.options or {
        'Option 1',
        'Option 2'
    }

    local current_option_index = 1
    for i, option in ipairs(args.options) do
        if option == args.current_option then
            current_option_index = i
            break
        end
    end
    args.current_option_val = args.options[current_option_index]
    args.current_option = current_option_index

    args.opt_callback = args.opt_callback or nil
    args.scale = args.scale or 1
    args.ref_table = args.ref_table or nil
    args.ref_value = args.ref_value or nil
    args.w = (args.w or 2.5)*args.scale
    args.h = (args.h or 0.8)*args.scale
    args.text_scale = (args.text_scale or 0.5)*args.scale
    args.l = '<'
    args.ll = '<<'
    args.lll = '<<<'
    args.r = '>'
    args.rr = '>>'
    args.rrr = '>>>'
    args.focus_args = args.focus_args or {}
    args.focus_args.type = 'cycle'

    local info
    if args.info then
        info = {}
        for k, v in ipairs(args.info) do
            table.insert(info, {n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes={
                {n=G.UIT.T, config={text = v, scale = 0.3*args.scale, colour = G.C.UI.TEXT_LIGHT}}
            }})
        end
        info =  {n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes=info}
    end

    local disabled = #args.options < 2

    local t = {
        n = G.UIT.C,
        config = {
            align = "cm",
            padding = 0.1,
            r = 0.1,
            colour = G.C.CLEAR,
            id = args.id and (not args.label and args.id or nil) or nil,
            focus_args = args.focus_args
        },
        nodes = {
            not args.doubleArrowsOnly and args.multiArrows and {
                n = G.UIT.C,
                config = {
                    minorArrows = args.minorArrows,
                    doubleArrowsOnly = args.doubleArrowsOnly,
                    align = "cm",
                    r = 0.1,
                    minw = 0.6*args.scale,
                    hover = not disabled,
                    colour = not disabled and args.colour or G.C.BLACK,
                    shadow = not disabled,
                    button = not disabled and 'DeckCreatorModuleOptionCycle' or nil,
                    ref_table = args,
                    ref_value = 'lll',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config = {ref_table = args, ref_value = 'lll', scale = args.text_scale, colour = not disabled and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE} }
                }
            } or nil,
            args.multiArrows and {
                n = G.UIT.C,
                config = {
                    minorArrows = args.minorArrows,
                    doubleArrowsOnly = args.doubleArrowsOnly,
                    align = "cm",
                    r = 0.1,
                    minw = 0.6*args.scale,
                    hover = not disabled,
                    colour = not disabled and args.colour or G.C.BLACK,
                    shadow = not disabled,
                    button = not disabled and 'DeckCreatorModuleOptionCycle' or nil,
                    ref_table = args,
                    ref_value = 'll',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config = {ref_table = args, ref_value = 'll', scale = args.text_scale, colour = not disabled and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE} }
                }
            } or nil,
            {
                n = G.UIT.C,
                config = {
                    minorArrows = args.minorArrows,
                    doubleArrowsOnly = args.doubleArrowsOnly,
                    align = "cm",
                    r = 0.1,
                    minw = 0.6*args.scale,
                    hover = not disabled,
                    colour = not disabled and args.colour or G.C.BLACK,
                    shadow = not disabled,
                    button = not disabled and 'DeckCreatorModuleOptionCycle' or nil,
                    ref_table = args,
                    ref_value = 'l',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config = {ref_table = args, ref_value = 'l', scale = args.text_scale, colour = not disabled and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE} }
                }
            },
            args.mid and {n=G.UIT.C, config={id = 'cycle_main'}, nodes={{n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes={args.mid}}}}
            or
            {
                n = G.UIT.C,
                config = {
                    id = 'cycle_main',
                    align = "cm",
                    minw = args.w,
                    minh = args.h,
                    r = 0.1,
                    padding = 0.05,
                    colour = args.colour,emboss = 0.1,
                    hover = true,
                    can_collide = true,
                    on_demand_tooltip = args.on_demand_tooltip
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = {align = "cm"},
                        nodes = {
                            {n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.O, config={object = DynaText({string = {{ref_table = args, ref_value = "current_option_val"}}, colours = {G.C.UI.TEXT_LIGHT},pop_in = 0, pop_in_rate = 8, reset_pop_in = true,shadow = true, float = true, silent = true, bump = true, scale = args.text_scale, non_recalc = true})}},}},
                            {n=G.UIT.R, config={align = "cm", minh = 0.05}, nodes={}}
                        }
                    }
                }
            },
            {
                n = G.UIT.C,
                config = {
                    minorArrows = args.minorArrows,
                    doubleArrowsOnly = args.doubleArrowsOnly,
                    align = "cm",
                    r = 0.1,
                    minw = 0.6*args.scale,
                    hover = not disabled,
                    colour = not disabled and args.colour or G.C.BLACK,
                    shadow = not disabled,
                    button = not disabled and 'DeckCreatorModuleOptionCycle' or nil,
                    ref_table = args,
                    ref_value = 'r',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config={ref_table = args, ref_value = 'r', scale = args.text_scale, colour = not disabled and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE} }
                }
            },
            args.multiArrows and {
                n = G.UIT.C,
                config = {
                    minorArrows = args.minorArrows,
                    doubleArrowsOnly = args.doubleArrowsOnly,
                    align = "cm",
                    r = 0.1,
                    minw = 0.6*args.scale,
                    hover = not disabled,
                    colour = not disabled and args.colour or G.C.BLACK,
                    shadow = not disabled,
                    button = not disabled and 'DeckCreatorModuleOptionCycle' or nil,
                    ref_table = args,
                    ref_value = 'rr',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config={ref_table = args, ref_value = 'rr', scale = args.text_scale, colour = not disabled and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE} }
                }
            } or nil,
            not args.doubleArrowsOnly and args.multiArrows and {
                n = G.UIT.C,
                config = {
                    minorArrows = args.minorArrows,
                    doubleArrowsOnly = args.doubleArrowsOnly,
                    align = "cm",
                    r = 0.1,
                    minw = 0.6*args.scale,
                    hover = not disabled,
                    colour = not disabled and args.colour or G.C.BLACK,
                    shadow = not disabled,
                    button = not disabled and 'DeckCreatorModuleOptionCycle' or nil,
                    ref_table = args,
                    ref_value = 'rrr',
                    focus_args = {type = 'none'}
                },
                nodes = {
                    { n=G.UIT.T, config={ref_table = args, ref_value = 'rrr', scale = args.text_scale, colour = not disabled and G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE} }
                }
            } or nil,
        }
    }

    t = {
        n = G.UIT.R,
        config = {
            align = "cm",
            colour = G.C.CLEAR,
            padding = 0.0
        },
        nodes = { t }
    }

    if args.label or args.info then
        t = {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    padding = 0.05,
                    id = args.id or nil
                },
                nodes={
                    args.label and {n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = args.label, scale = 0.5*args.scale, colour = G.C.UI.TEXT_LIGHT}}}} or nil,
                    t,
                    info,
                }
        }
    end
    return t
end

function Helper.createTextInput(args)
    args = args or {}
    args.colour = copy_table(args.colour) or copy_table(G.C.BLUE)
    args.hooked_colour = copy_table(args.hooked_colour) or darken(copy_table(G.C.BLUE), 0.3)
    args.w = args.w or 2.5
    args.h = args.h or 0.7
    args.text_scale = args.text_scale or 0.4
    args.max_length = args.max_length or 16
    args.all_caps = args.all_caps or false
    args.prompt_text = args.prompt_text or "Enter Text"
    args.current_prompt_text = ''

    local buttonId = args.id and args.id .. "_text_input" or "text_input"
    local promptId = args.id and args.id .. "_prompt" or "prompt"
    local positionId = args.id and args.id .. "_position" or "position"

    local text = {ref_table = args.ref_table, ref_value = args.ref_value, letters = {}, current_position = string.len(args.ref_table[args.ref_value])}
    local ui_letters = {}
    for i = 1, args.max_length do
        text.letters[i] = (args.ref_table[args.ref_value] and (string.sub(args.ref_table[args.ref_value], i, i) or '')) or ''
        ui_letters[i] = {n=G.UIT.T, config={ref_table = text.letters, ref_value = i, scale = args.text_scale, colour = G.C.UI.TEXT_LIGHT, id = 'letter_'..i}}
    end
    args.text = text

    local position_text_colour = lighten(copy_table(G.C.BLUE), 0.4)

    ui_letters[#ui_letters+1] = {n=G.UIT.T, config={ref_table = args, ref_value = 'current_prompt_text', scale = args.text_scale, colour = lighten(copy_table(args.colour), 0.4), id = promptId }}
    ui_letters[#ui_letters+1] = {n=G.UIT.B, config={r = 0.03,w=0.1, h=0.4, colour = position_text_colour, id = positionId, func = 'flash'}}

    local t =
    {n=G.UIT.C, config={align = "cm", draw_layer = 1, colour = G.C.CLEAR}, nodes = {
        {n=G.UIT.C, config={id = buttonId, align = "cm", padding = 0.05, r = 0.1, draw_layer = 2, hover = true, colour = args.colour,minw = args.w, min_h = args.h, button = 'select_text_input', shadow = true}, nodes={
            {n=G.UIT.R, config={ref_table = args, padding = 0.05, align = "cm", r = 0.1, colour = G.C.CLEAR}, nodes={
                {n=G.UIT.R, config={ref_table = args, align = "cm", r = 0.1, colour = G.C.CLEAR, func = 'text_input'}, nodes=
                ui_letters
                }
            }}
        }}
    }}

    if args.label then
        t = {
            n = G.UIT.R,
            config = {
                align = "cm",
                padding = 0.05,
                id = args.id or nil
            },
            nodes={
                args.label and {n=G.UIT.R, config={align = "cm"}, nodes={{n=G.UIT.T, config={text = args.label, scale = 0.5*args.scale, colour = G.C.UI.TEXT_LIGHT}}}} or nil,
                t
            }
        }
    end
    return t
end

function Helper.createMultiRowTabs(args)
    args.colour = args.colour or G.C.RED
    args.tab_alignment = args.tab_alignment or 'cm'
    args.opt_callback = args.opt_callback or nil
    args.scale = args.scale or 1
    args.tab_w = args.tab_w or 0
    args.tab_h = args.tab_h or 0
    args.text_scale = (args.text_scale or 0.5)

    local tabRowNodes = {}

    for a, b in ipairs(args.tabRows) do
        local tab_buttons = {}
        for k, v in ipairs(b.tabs) do
            if v.chosen then args.current = {k = k, v = v} end
            tab_buttons[#tab_buttons+1] = UIBox_button({id = 'tab_but_'..(v.label or ''), ref_table = v, button = 'change_tab', label = {v.label}, minh = 0.8*args.scale, minw = 2.5*args.scale, col = true, choice = true, scale = args.text_scale, chosen = v.chosen, func = v.func, focus_args = {type = 'none'}})
        end

        local tabNode = {
            n = G.UIT.R,
            config = { align = "cm", colour = G.C.CLEAR },
            nodes = {
                (#b.tabs > 1 and not args.no_shoulders) and { n = G.UIT.C, config = { minw = 0.7, align = "cm", colour = G.C.CLEAR, func = 'set_button_pip', focus_args = { button = 'leftshoulder', type = 'none', orientation = 'cm', scale = 0.7, offset = { x = -0.1, y = 0 } } }, nodes = {} } or nil,
                { n = G.UIT.C, config = { id = args.no_shoulders and 'no_shoulders' or 'tab_shoulders', ref_table = args, align = "cm", padding = 0.15, group = 1, collideable = true, focus_args = #b.tabs > 1 and { type = 'tab', nav = 'wide', snap_to = args.snap_to_nav, no_loop = args.no_loop } or nil }, nodes = tab_buttons },
                (#b.tabs > 1 and not args.no_shoulders) and { n = G.UIT.C, config = { minw = 0.7, align = "cm", colour = G.C.CLEAR, func = 'set_button_pip', focus_args = { button = 'rightshoulder', type = 'none', orientation = 'cm', scale = 0.7, offset = { x = 0.1, y = 0 } } }, nodes = {} } or nil,
            }
        }
        table.insert(tabRowNodes, tabNode)
    end

    local output = {
        n = G.UIT.R,
        config = { padding = 0.0, align = "cm", colour = G.C.CLEAR },
        nodes = tabRowNodes
    }
    local contentNode = {
        n = G.UIT.R,
        config = { align = args.tab_alignment, padding = args.padding or 0.1, no_fill = true, minh = args.tab_h, minw = args.tab_w },
        nodes = {
            {
                n = G.UIT.O,
                config = { id = 'tab_contents', object = UIBox { definition = args.current.v.tab_definition_function(args.current.v.tab_definition_function_args), config = { offset = { x = 0, y = 0 } } } }
            }
        }
    }
    table.insert(output.nodes, contentNode)

    return output
end

function Helper.view_deck(unplayed_only)
    local currentDeckName = "New Custom Deck"
    local deckList = Utils.customDeckList[#Utils.customDeckList].config.customCardList
    Utils.log("Custom card list before view deck init:\n" .. Utils.tableToString(deckList))
    CardUtils.getCardsFromCustomCardList(deckList)
    local deck_tables = {}
    remove_nils(G.playing_cards)
    G.VIEWING_DECK = true
    G.GAME.blind = FakeBlind
    table.sort(G.playing_cards, function (a, b) return a:get_nominal('suit') > b:get_nominal('suit') end )
    local SUITS = {
    Spades = {},
    Hearts = {},
    Clubs = {},
    Diamonds = {},
    }
    local suit_map = {'Spades', 'Hearts', 'Clubs', 'Diamonds'}
    for k, v in ipairs(G.playing_cards) do
        local val = v.base
        if val ~= nil then
            local newVal = val.suit
            if newVal ~= nil then
                val = newVal
            else
                val = Utils.tableToString(v.base)
            end
        else
            val = 'v.base was nil'
        end
        Utils.log("Inserting into SUITS[" .. val .. "]")
        table.insert(SUITS[v.base.suit], v)
    end
    for j = 1, 4 do
    if SUITS[suit_map[j]][1] then
    local view_deck = CardArea(
    G.ROOM.T.x + 0.2*G.ROOM.T.w/2,G.ROOM.T.h,
    6.5*G.CARD_W,
    0.6*G.CARD_H,
    {card_limit = #SUITS[suit_map[j]], type = 'title', view_deck = true, highlight_limit = 0, card_w = G.CARD_W*0.7, draw_layers = {'card'}})
    table.insert(deck_tables,
    {n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
    {n=G.UIT.O, config={object = view_deck}}
    }}
    )

    for i = 1, #SUITS[suit_map[j]] do
    if SUITS[suit_map[j]][i] then
    local greyed, _scale = nil, 0.7
    if unplayed_only and not ((SUITS[suit_map[j]][i].area and SUITS[suit_map[j]][i].area == G.deck) or SUITS[suit_map[j]][i].ability.wheel_flipped) then
    greyed = true
    end
    local copy = copy_card(SUITS[suit_map[j]][i],nil, _scale)
    copy.greyed = greyed
    copy.T.x = view_deck.T.x + view_deck.T.w/2
    copy.T.y = view_deck.T.y

    copy:hard_set_T()
    view_deck:emplace(copy)
    end
    end
    end
    end

    local flip_col = G.C.WHITE

    local suit_tallies = {['Spades']  = 0, ['Hearts'] = 0, ['Clubs'] = 0, ['Diamonds'] = 0}
    local mod_suit_tallies = {['Spades']  = 0, ['Hearts'] = 0, ['Clubs'] = 0, ['Diamonds'] = 0}
    local rank_tallies = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    local mod_rank_tallies = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    local rank_name_mapping = {2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A'}
    local face_tally = 0
    local mod_face_tally = 0
    local num_tally = 0
    local mod_num_tally = 0
    local ace_tally = 0
    local mod_ace_tally = 0
    local wheel_flipped = 0

    for k, v in ipairs(G.playing_cards) do
    if v.ability.name ~= 'Stone Card' and (not unplayed_only or ((v.area and v.area == G.deck) or v.ability.wheel_flipped)) then
    if v.ability.wheel_flipped and unplayed_only then wheel_flipped = wheel_flipped + 1 end
    --For the suits
    suit_tallies[v.base.suit] = (suit_tallies[v.base.suit] or 0) + 1
    mod_suit_tallies['Spades'] = (mod_suit_tallies['Spades'] or 0) + (v:is_suit('Spades') and 1 or 0)
    mod_suit_tallies['Hearts'] = (mod_suit_tallies['Hearts'] or 0) + (v:is_suit('Hearts') and 1 or 0)
    mod_suit_tallies['Clubs'] = (mod_suit_tallies['Clubs'] or 0) + (v:is_suit('Clubs') and 1 or 0)
    mod_suit_tallies['Diamonds'] = (mod_suit_tallies['Diamonds'] or 0) + (v:is_suit('Diamonds') and 1 or 0)

    --for face cards/numbered cards/aces
    local card_id = v:get_id()
    face_tally = face_tally + ((card_id ==11 or card_id ==12 or card_id ==13) and 1 or 0)
    mod_face_tally = mod_face_tally + (v:is_face() and 1 or 0)
    if card_id > 1 and card_id < 11 then
    num_tally = num_tally + 1
    if not v.debuff then mod_num_tally = mod_num_tally + 1 end
    end
    if card_id == 14 then
    ace_tally = ace_tally + 1
    if not v.debuff then mod_ace_tally = mod_ace_tally + 1 end
    end

    --ranks
    rank_tallies[card_id - 1] = rank_tallies[card_id - 1] + 1
    if not v.debuff then mod_rank_tallies[card_id - 1] = mod_rank_tallies[card_id - 1] + 1 end
    end
    end

    local modded = (face_tally ~= mod_face_tally) or
    (mod_suit_tallies['Spades'] ~= suit_tallies['Spades']) or
    (mod_suit_tallies['Hearts'] ~= suit_tallies['Hearts']) or
    (mod_suit_tallies['Clubs'] ~= suit_tallies['Clubs']) or
    (mod_suit_tallies['Diamonds'] ~= suit_tallies['Diamonds'])

    if wheel_flipped > 0 then flip_col = mix_colours(G.C.FILTER, G.C.WHITE,0.7) end

    local rank_cols = {}
    for i = 13, 1, -1 do
    local mod_delta = mod_rank_tallies[i] ~= rank_tallies[i]
    rank_cols[#rank_cols+1] = {n=G.UIT.R, config={align = "cm", padding = 0.07}, nodes={
    {n=G.UIT.C, config={align = "cm", r = 0.1, padding = 0.04, emboss = 0.04, minw = 0.5, colour = G.C.L_BLACK}, nodes={
    {n=G.UIT.T, config={text = rank_name_mapping[i],colour = G.C.JOKER_GREY, scale = 0.35, shadow = true}},
    }},
    {n=G.UIT.C, config={align = "cr", minw = 0.4}, nodes={
    mod_delta and {n=G.UIT.O, config={object = DynaText({string = {{string = ''..rank_tallies[i], colour = flip_col},{string =''..mod_rank_tallies[i], colour = G.C.BLUE}}, colours = {G.C.RED}, scale = 0.4, y_offset = -2, silent = true, shadow = true, pop_in_rate = 10, pop_delay = 4})}} or
    {n=G.UIT.T, config={text = rank_tallies[i] or 'NIL',colour = flip_col, scale = 0.45, shadow = true}},
    }}
    }}
    end

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

    local output =
    {
        n=G.UIT.ROOT,
        config={align = "cm", colour = G.C.CLEAR},
        nodes={
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.05 },
                nodes = {}
            },
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                    {
                        n=G.UIT.C,
                        config={align = "cm", minw = 1.5, minh = 2, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
                        nodes={
                            {
                                n=G.UIT.C,
                                config={align = "cm", padding = 0.1},
                                nodes={
                                    { n = G.UIT.R, config = { align = "cm", r = 0.1, colour = G.C.L_BLACK, emboss = 0.05, padding = 0.15 }, nodes = {
                                        { n = G.UIT.R, config = { align = "cm" }, nodes = {
                                            { n = G.UIT.O, config = { object = DynaText({ string = currentDeckName, colours = { G.C.WHITE }, bump = true, rotate = true, shadow = true, scale = 0.6 - string.len(currentDeckName) * 0.01 }) } },
                                        } },
                                        --[[{ n = G.UIT.R, config = { align = "cm", r = 0.1, padding = 0.1, minw = 2.5, minh = 1.3, colour = G.C.WHITE, emboss = 0.05 }, nodes = {
                                            { n = G.UIT.O, config = { object = UIBox {
                                                definition = backGeneratedUI,
                                                config = { offset = { x = 0, y = 0 } }
                                            } } }
                                        } }]]
                                    } },
                                    { n = G.UIT.R, config = { align = "cm", r = 0.1, outline_colour = G.C.L_BLACK, line_emboss = 0.05, outline = 1.5 }, nodes = {
                                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.07 }, nodes = {
                                            { n = G.UIT.O, config = { object = DynaText({ string = { { string = localize('k_base_cards'), colour = G.C.RED }, modded and { string = localize('k_effective'), colour = G.C.BLUE } or nil }, colours = { G.C.RED }, silent = true, scale = 0.4, pop_in_rate = 10, pop_delay = 4 }) } }
                                        } },
                                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                                            tally_sprite({ x = 1, y = 0 }, { { string = '' .. ace_tally, colour = flip_col }, { string = '' .. mod_ace_tally, colour = G.C.BLUE } }, { localize('k_aces') }), --Aces
                                            tally_sprite({ x = 2, y = 0 }, { { string = '' .. face_tally, colour = flip_col }, { string = '' .. mod_face_tally, colour = G.C.BLUE } }, { localize('k_face_cards') }), --Face
                                            tally_sprite({ x = 3, y = 0 }, { { string = '' .. num_tally, colour = flip_col }, { string = '' .. mod_num_tally, colour = G.C.BLUE } }, { localize('k_numbered_cards') }), --Numbers
                                        } },
                                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                                            tally_sprite({ x = 3, y = 1 }, { { string = '' .. suit_tallies['Spades'], colour = flip_col }, { string = '' .. mod_suit_tallies['Spades'], colour = G.C.BLUE } }, { localize('Spades', 'suits_plural') }),
                                            tally_sprite({ x = 0, y = 1 }, { { string = '' .. suit_tallies['Hearts'], colour = flip_col }, { string = '' .. mod_suit_tallies['Hearts'], colour = G.C.BLUE } }, { localize('Hearts', 'suits_plural') }),
                                        } },
                                        { n = G.UIT.R, config = { align = "cm", minh = 0.05, padding = 0.1 }, nodes = {
                                            tally_sprite({ x = 2, y = 1 }, { { string = '' .. suit_tallies['Clubs'], colour = flip_col }, { string = '' .. mod_suit_tallies['Clubs'], colour = G.C.BLUE } }, { localize('Clubs', 'suits_plural') }),
                                            tally_sprite({ x = 1, y = 1 }, { { string = '' .. suit_tallies['Diamonds'], colour = flip_col }, { string = '' .. mod_suit_tallies['Diamonds'], colour = G.C.BLUE } }, { localize('Diamonds', 'suits_plural') }),
                                        } },
                                    } }
                                }
                            },
                            {
                                n=G.UIT.C,
                                config={align = "cm"},
                                nodes=rank_cols
                            },
                            {
                                n=G.UIT.B,
                                config={w = 0.1, h = 0.1}
                            },
                        }
                    },
                    {
                        n=G.UIT.B,
                        config={w = 0.2, h = 0.1}
                    },
                    {
                        n=G.UIT.C,
                        config={align = "cm", padding = 0.1, r = 0.1, colour = G.C.BLACK, emboss = 0.05},
                        nodes=deck_tables
                    }
                }
            },
            {
                n = G.UIT.R,
                config={align = "cm", minh = 0.4, padding = 0.05},
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
                                    UIBox_button({
                                        label = {" Add Card "},
                                        shadow = true,
                                        scale = 0.75 * 0.4,
                                        colour = G.C.BOOSTER,
                                        button = "DeckCreatorModuleOpenAddCardToDeck",
                                        minh = 0.8,
                                        minw = 3
                                    })
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
                                    UIBox_button({
                                        label = {" Remove All "},
                                        shadow = true,
                                        scale = 0.75 * 0.4,
                                        colour = G.C.BOOSTER,
                                        button = "DeckCreatorModuleDeleteAllCardsFromBaseDeck",
                                        minh = 0.8,
                                        minw = 3
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    G.GAME.blind = nil
    return output
end

return Helper
