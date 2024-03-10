local CardUtils = require "CardUtils"

local Helper = {}

Helper.deckEditorAreas = {}
Helper.sums = {}

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

function Helper.tally_item_sprite(pos, value, tooltip, atlas)
    local text_colour = G.C.BLACK
    atlas = atlas or "itemIcons"
    if SMODS.BalamodMode then
        atlas = "ui_"..(G.SETTINGS.colourblind_option and 2 or 1)
    end
    if type(value) == "table" and value[1].string==value[2].string then
        text_colour = value[1].colour or G.C.WHITE
        value = value[1].string
    end
    local t_s = Sprite(0,0,0.5,0.5,G.ASSET_ATLAS[atlas], {x=pos.x or 0, y=pos.y or 0})
    t_s.states.drag.can = false
    t_s.states.hover.can = false
    t_s.states.collide.can = false
    return
    {n=G.UIT.C, config={align = "cm", padding = 0.07,force_focus = true,  focus_args = {type = 'tally_sprite'}, tooltip = {text = tooltip}}, nodes={
        {n=G.UIT.R, config={align = "cm", r = 0.1, padding = 0.04, emboss = 0.05, colour = G.C.JOKER_GREY}, nodes={
            {n=G.UIT.O, config={w=0.5,h=0.5 ,can_collide = false, object = t_s, tooltip = {text = tooltip}}}
        }},
        {n=G.UIT.R, config={align = "cm"}, nodes={
            type(value) == "table" and {n=G.UIT.O, config={object = DynaText({string = value, colours = {G.C.RED}, scale = 0.4, silent = true, shadow = true, pop_in_rate = 10, pop_delay = 4})}} or
                    {n=G.UIT.T, config={text = value or 'NIL',colour = text_colour, scale = 0.4, shadow = true}},
        }},
    }}
end

function Helper.calculateDeckEditorSums()
    local unplayed_only = false
    local flip_col = G.C.WHITE
    Helper.sums.total_cards = 0
    Helper.sums.suit_tallies = {['Spades']  = 0, ['Hearts'] = 0, ['Clubs'] = 0, ['Diamonds'] = 0}
    Helper.sums.mod_suit_tallies = {['Spades']  = 0, ['Hearts'] = 0, ['Clubs'] = 0, ['Diamonds'] = 0}
    Helper.sums.rank_tallies = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    Helper.sums.mod_rank_tallies = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    Helper.sums.rank_name_mapping = {2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A'}
    Helper.sums.face_tally = 0
    Helper.sums.mod_face_tally = 0
    Helper.sums.num_tally = 0
    Helper.sums.mod_num_tally = 0
    Helper.sums.ace_tally = 0
    Helper.sums.mod_ace_tally = 0
    Helper.sums.wheel_flipped = 0

    for k, v in ipairs(G.playing_cards) do
        Helper.sums.total_cards = Helper.sums.total_cards + 1
        if v.ability.name ~= 'Stone Card' and (not unplayed_only or ((v.area and v.area == G.deck) or v.ability.wheel_flipped)) then
            if v.ability.wheel_flipped and unplayed_only then Helper.wheel_flipped = Helper.wheel_flipped + 1 end
            --For the suits
            Helper.sums.suit_tallies[v.base.suit] = (Helper.sums.suit_tallies[v.base.suit] or 0) + 1
            Helper.sums.mod_suit_tallies['Spades'] = (Helper.sums.mod_suit_tallies['Spades'] or 0) + (v:is_suit('Spades') and 1 or 0)
            Helper.sums.mod_suit_tallies['Hearts'] = (Helper.sums.mod_suit_tallies['Hearts'] or 0) + (v:is_suit('Hearts') and 1 or 0)
            Helper.sums.mod_suit_tallies['Clubs'] = (Helper.sums.mod_suit_tallies['Clubs'] or 0) + (v:is_suit('Clubs') and 1 or 0)
            Helper.sums.mod_suit_tallies['Diamonds'] = (Helper.sums.mod_suit_tallies['Diamonds'] or 0) + (v:is_suit('Diamonds') and 1 or 0)

            --for face cards/numbered cards/aces
            local card_id = v:get_id()
            Helper.sums.face_tally = Helper.sums.face_tally + ((card_id ==11 or card_id ==12 or card_id ==13) and 1 or 0)
            Helper.sums.mod_face_tally = Helper.sums.mod_face_tally + (v:is_face() and 1 or 0)
            if card_id > 1 and card_id < 11 then
                Helper.sums.num_tally = Helper.sums.num_tally + 1
                if not v.debuff then Helper.sums.mod_num_tally = Helper.sums.mod_num_tally + 1 end
            end
            if card_id == 14 then
                Helper.sums.ace_tally = Helper.sums.ace_tally + 1
                if not v.debuff then Helper.sums.mod_ace_tally = Helper.sums.mod_ace_tally + 1 end
            end

            --ranks
            Helper.sums.rank_tallies[card_id - 1] = Helper.sums.rank_tallies[card_id - 1] + 1
            if not v.debuff then Helper.sums.mod_rank_tallies[card_id - 1] = Helper.sums.mod_rank_tallies[card_id - 1] + 1 end
        end
    end

    Helper.sums.modded = (Helper.sums.face_tally ~= Helper.sums.mod_face_tally) or
            (Helper.sums.mod_suit_tallies['Spades'] ~= Helper.sums.suit_tallies['Spades']) or
            (Helper.sums.mod_suit_tallies['Hearts'] ~= Helper.sums.suit_tallies['Hearts']) or
            (Helper.sums.mod_suit_tallies['Clubs'] ~= Helper.sums.suit_tallies['Clubs']) or
            (Helper.sums.mod_suit_tallies['Diamonds'] ~= Helper.sums.suit_tallies['Diamonds'])

    if Helper.sums.wheel_flipped > 0 then flip_col = mix_colours(G.C.FILTER, G.C.WHITE,0.7) end

    Helper.sums.rank_cols = {}
    Helper.sums.rank_tallies_strings = {}
    for i = #Helper.sums.rank_tallies, 1, -1 do
        Helper.sums.rank_tallies_strings[i] = tostring(Helper.sums.rank_tallies[i])
    end
    for i = 13, 1, -1 do
        local mod_delta = Helper.sums.mod_rank_tallies[i] ~= Helper.sums.rank_tallies[i]
        Helper.sums.rank_cols[#Helper.sums.rank_cols+1] = {
            n=G.UIT.R,
            config={align = "cm", padding = 0.07},
            nodes={
                {
                    n=G.UIT.C,
                    config={align = "cm", r = 0.1, padding = 0.04, emboss = 0.04, minw = 0.5, colour = G.C.L_BLACK},
                    nodes={
                        {n=G.UIT.T, config={text = Helper.sums.rank_name_mapping[i],colour = G.C.JOKER_GREY, scale = 0.35, shadow = true}},
                    }
                },
                {
                    n=G.UIT.C,
                    config={align = "cr", minw = 0.4},
                    nodes={
                        mod_delta and {n=G.UIT.O, config={object = DynaText({string = {{string = Helper.sums.rank_tallies[i], colour = flip_col},{string = Helper.sums.mod_rank_tallies[i], colour = G.C.BLUE}}, colours = {G.C.RED}, scale = 0.4, y_offset = -2, silent = true, shadow = true, pop_in_rate = 10, pop_delay = 4})}} or
                                {n=G.UIT.T, config={text = Helper.sums.rank_tallies[i] or 'NIL',colour = flip_col, scale = 0.45, shadow = true}},
                    }
                }
            }
        }
    end
end

function Helper.calculateStartingItemsSums()

    Helper.sums.item_tallies = {
        ['Joker']  = 0,
        ['Consumable'] = 0,
        -- ['Tag'] = 0,
        ['Voucher'] = 0,
        ['Tarot'] = 0,
        ['Planet'] = 0,
        ['Spectral'] = 0
    }

    for k,v in pairs(CardUtils.startingItems.jokers) do
        Helper.sums.item_tallies["Joker"] = (Helper.sums.item_tallies["Joker"] or 0) + 1
    end
    for k,v in pairs(CardUtils.startingItems.tarots) do
        Helper.sums.item_tallies["Consumable"] = (Helper.sums.item_tallies["Consumable"] or 0) + 1
        Helper.sums.item_tallies["Tarot"] = (Helper.sums.item_tallies["Tarot"] or 0) + 1
    end
    for k,v in pairs(CardUtils.startingItems.planets) do
        Helper.sums.item_tallies["Consumable"] = (Helper.sums.item_tallies["Consumable"] or 0) + 1
        Helper.sums.item_tallies["Planet"] = (Helper.sums.item_tallies["Planet"] or 0) + 1
    end
    for k,v in pairs(CardUtils.startingItems.spectrals) do
        Helper.sums.item_tallies["Consumable"] = (Helper.sums.item_tallies["Consumable"] or 0) + 1
        Helper.sums.item_tallies["Spectral"] = (Helper.sums.item_tallies["Spectral"] or 0) + 1
    end
    for k,v in pairs(CardUtils.startingItems.vouchers) do
        Helper.sums.item_tallies["Voucher"] = (Helper.sums.item_tallies["Voucher"] or 0) + 1
    end
    --[[for k,v in pairs(CardUtils.startingItems.tags) do
        Helper.sums.item_tallies["Tag"] = (Helper.sums.item_tallies["Tag"] or 0) + 1
    end]]

    Helper.sums.start_item_cols = {}
    for k,v in pairs(Helper.sums.item_tallies) do
        if k ~= 'Consumable' then
            Helper.sums.start_item_cols[#Helper.sums.start_item_cols+1] = {
                n=G.UIT.R,
                config={align = "cm", padding = 0.07},
                nodes={
                    {
                        n=G.UIT.C,
                        config={align = "cm", r = 0.1, padding = 0.04, emboss = 0.04, minw = 0.5, colour = G.C.L_BLACK},
                        nodes={
                            --{n=G.UIT.T, config={text = k == 'Tarot' and 'R' or string.sub(k, 1, 1), colour = G.C.JOKER_GREY, scale = 0.35, shadow = true}},
                            {n=G.UIT.T, config={text = string.sub(k, 1, 1), colour = G.C.JOKER_GREY, scale = 0.35, shadow = true}},
                        }
                    },
                    {
                        n=G.UIT.C,
                        config={align = "cr", minw = 0.4},
                        nodes={
                            {n=G.UIT.T, config={text = tostring(v) or 'NIL',colour = G.C.WHITE, scale = 0.45, shadow = true}},
                        }
                    }
                }
            }
        end
    end
end

return Helper
