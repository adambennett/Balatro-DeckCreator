local DeckCreator = {}

local Persistence = require "Persistence"
local GUI = require "GUI"

function DeckCreator.LoadCustomDecks()
    GUI.registerGlobals()
    GUI.registerCreateDeckButton()
    Persistence.loadAllDecks()

    local Backapply_to_runRef = Back.apply_to_run
    function Back.apply_to_run(arg)
        Backapply_to_runRef(arg)

        if arg.effect.config.reroll_cost then
            G.GAME.starting_params.reroll_cost = arg.effect.config.reroll_cost
            if arg.effect.config.reroll_discount then
                G.GAME.starting_params.reroll_cost = arg.effect.config.reroll_cost - arg.effect.config.reroll_discount
            end
        end
    end
end

return DeckCreator
