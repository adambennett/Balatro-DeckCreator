local Helper = {}

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
            e.config.ref_table.current_option = e.config.ref_table.current_option - 10
            if e.config.ref_table.current_option <= 0 then e.config.ref_table.current_option = #e.config.ref_table.options end
        elseif e.config.ref_value == 'lll' then
            --cycle left x100
            e.config.ref_table.current_option = e.config.ref_table.current_option - 100
            if e.config.ref_table.current_option <= 0 then e.config.ref_table.current_option = #e.config.ref_table.options end
        elseif e.config.ref_value == 'r' then
            --cycle right
            e.config.ref_table.current_option = e.config.ref_table.current_option + 1
            if e.config.ref_table.current_option > #e.config.ref_table.options then e.config.ref_table.current_option = 1 end
        elseif e.config.ref_value == 'rr' then
            --cycle right x10
            e.config.ref_table.current_option = e.config.ref_table.current_option + 10
            if e.config.ref_table.current_option > #e.config.ref_table.options then e.config.ref_table.current_option = 1 end
        elseif e.config.ref_value == 'rrr' then
            --cycle right x100
            e.config.ref_table.current_option = e.config.ref_table.current_option + 100
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

    -- Add new buttons for increments of 10 and 100
    -- This requires creating new UI elements similar to existing arrows
    -- and assigning them appropriate callback functions or identifiers.

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
            args.multiArrows and {
                n = G.UIT.C,
                config = {
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
            args.multiArrows and {
                n = G.UIT.C,
                config = {
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
    return t
end

--[[function copy_table(O)
    local O_type = type(O)
    local copy
    if O_type == 'table' then
        copy = {}
        for k, v in next, O, nil do
            copy[copy_table(k)] = copy_table(v)
        end
        setmetatable(copy, copy_table(getmetatable(O)))
    else
        copy = O
    end
    return copy
end

function lighten(colour, percent, no_tab)
    if no_tab then
        return
        colour[1]*(1-percent)+percent,
        colour[2]*(1-percent)+percent,
        colour[3]*(1-percent)+percent,
        colour[4]
    end
    return {
        colour[1]*(1-percent)+percent,
        colour[2]*(1-percent)+percent,
        colour[3]*(1-percent)+percent,
        colour[4]
    }
end

function darken(colour, percent, no_tab)
    if no_tab then
        return
        colour[1]*(1-percent),
        colour[2]*(1-percent),
        colour[3]*(1-percent),
        colour[4]
    end
    return {
        colour[1]*(1-percent),
        colour[2]*(1-percent),
        colour[3]*(1-percent),
        colour[4]
    }
end]]

return Helper
