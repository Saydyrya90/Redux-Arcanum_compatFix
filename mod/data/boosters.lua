-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--      ALCHEMICAL BOOSTER
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.Booster.update_pack = function(self, dt)
    if G.buttons then G.buttons:remove(); G.buttons = nil end
    if G.shop then G.shop.alignment.offset.y = G.ROOM.T.y+11 end

    if not G.STATE_COMPLETE then
        G.STATE_COMPLETE = true
        G.CONTROLLER.interrupt.focus = true
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                if self.particles and type(self.particles) == "function" then self:particles() end
                G.booster_pack = UIBox{
                    definition = self:create_UIBox(),
                    config = {align="tmi", offset = {x=0,y=G.ROOM.T.y + 9}, major = G.hand, bond = 'Weak'}
                }
                G.booster_pack.alignment.offset.y = -2.2
                G.ROOM.jiggle = G.ROOM.jiggle + 3
                self:ease_background_colour()
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        if self.draw_hand == true then G.FUNCS.draw_from_deck_to_hand() end

                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.5,
                            func = function()
                                G.CONTROLLER:recall_cardarea_focus('pack_cards')
                                return true
                            end}))
                        return true
                    end
                }))  
                return true
            end
        }))  
    end
end

function add_booster(booster)
    SMODS.Booster {
        key = booster.key,
        loc_txt = {
            group_name = 'Alchemy Pack',
            name = booster.name,
            text = {
                'Choose {C:attention}#1#{} of up to',
                "{C:attention}#2#{C:alchemical} Alchemical{} cards to",
                "add to your consumeables"
            }
        },

        kind = "Alchemical",

        loc_vars = function(self, info_queue, card)
            return { vars = { card.ability.choose, card.ability.extra } }
        end,
        config = { extra = booster.extra, choose = booster.choose, name = "Alchemical" },

        create_card = function(self, card)
            local card = create_alchemical(G.pack_cards, nil, nil, true, true, nil, 'alc')
            return card
        end,

        ease_background_colour = function(self)
            ease_colour(G.C.DYN_UI.MAIN, HEX('4d7796'))
            ease_background_colour { new_colour = darken(G.C.BLACK, 0.2), special_colour = darken(G.C.ORANGE, 0.2), contrast = 3 }
        end,

        pos = booster.pos,
        atlas = 'ca_booster_atlas',

        weight = booster.weight or 1,

        cost = booster.cost or 4,

        in_pool = function() return true end
    }
end

for i = 1, 7 do
    local extra
    local choose
    local name
    local pos
    local cost
    local weight = 1
    if i < 5 then
        name = "Alchemy Pack"
        choose = 1
        extra = 2
        cost = 4
    elseif i < 7 then
        name = "Jumbo Alchemy Pack"
        choose = 1
        extra = 4
        cost = 6
    else
        name = "Mega Alchemy Pack"
        choose = 2
        extra = 4
        cost = 8
        weight = 0.25
    end

    pos = { x = (i - 1) % 4, y = math.floor((i - 1) / 4) }

    add_booster({
        key = "alchemy_" .. i,
        name = name,
        extra = extra,
        choose = choose,
        pos = pos,
        weight = weight,
        cost = cost
    })
end