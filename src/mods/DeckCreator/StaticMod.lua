local Utils = require "Utils"
local Helper = require "GuiElementHelper"

local StaticMod = {
    isToggle = true,
    options = {},
    callback = nil,
    setter = false,
    setterUUID = nil,
    label = "",
    property = "",
    multiArrows = false,
    minorArrows = false,
    doubleArrowsOnly = false,
    scale = 0.8,
    group = "",
    pageNumber = -1,
    groupPageNumber = -1,
}

function StaticMod:new(args)
    o = {}
    setmetatable(o, self)
    self.__index = self

    if args ~= nil then

        if args.isToggle == nil or args.isToggle == true then
            o.isToggle = true
        else
            o.isToggle = false
        end

        o.options = args.options or {}
        o.callback = args.callback or nil
        o.label = args.label or "UNDEFINED_LABEL"
        o.property = args.property or "UNDEFINED_KEY"
        o.scale = 0.8
        o.group = args.group
        o.multiArrows = args.multiArrows or false
        o.minorArrows = args.minorArrows or false
        o.doubleArrowsOnly = args.doubleArrowsOnly or false
        o.scale = args.scale or 0.8

        if o.isToggle == false and args.callback == nil then
            o.setter = true
        end
    end

    return o
end

function StaticMod:generate_ui_element()
    if self.isToggle then
        return create_toggle({
            label = self.label,
            ref_table = Utils.getCurrentEditingDeck().config,
            ref_value = self.property
        })
    else
        if self.setter then
            self.setterUUID = Utils.uuid()
            self.callback = 'DeckCreatorModuleChange' .. self.property .. '_' .. self.setterUUID
            G.FUNCS[self.callback] = function(args)
                Utils.getCurrentEditingDeck().config[self.property] = args.to_val
            end
        end
        return Helper.createOptionSelector({
            label = self.label,
            scale = self.scale,
            options = self.options,
            opt_callback = self.callback,
            current_option = (Utils.getCurrentEditingDeck().config[self.property]),
            multiArrows = self.multiArrows,
            minorArrows = self.minorArrows,
            doubleArrowsOnly = self.doubleArrowsOnly
        })
    end
end



return StaticMod
