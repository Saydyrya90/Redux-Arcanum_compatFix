ReduxArcanumMod = SMODS.current_mod

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--        SMOD CONFIG
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

G.FUNCS.cycle_options = function(args)
    -- G.FUNCS.cycle_update from Galdur
    args = args or {}
    if args.cycle_config and args.cycle_config.ref_table and args.cycle_config.ref_value then
        args.cycle_config.ref_table[args.cycle_config.ref_value] = args.to_key
    end
    local success = SMODS.save_mod_config(ReduxArcanumMod)
    if success then
        sendDebugMessage("Config Saved", "ReduxArcanumDebugLogger")
    else
        sendDebugMessage("Config Not saved", "ReduxArcanumDebugLogger")
    end
end

-- Shamelessly copying Bunco's config tab layout
ReduxArcanumMod.config_tab = function()
    local current_overlapping = ReduxArcanumMod.config.overlapping_cards or 1
    local current_new_content = ReduxArcanumMod.config.new_content or true
    local bunco_linked_acid = ReduxArcanumMod.config.bunco_linked_acid or true
    t = { create_option_cycle {
        label = "Conflicting Cards",
        info = {
            "How to handle known similar cards from other mods",
            "(Requires restart)"
        },
        options = {
            "Remove from this mod",
            "Remove from the other mod",
            "Do nothing"
        },
        w = 5,
        text_scale = 0.4,
        current_option = current_overlapping,
        ref_table = ReduxArcanumMod.config,
        ref_value = "overlapping_cards",
        opt_callback = 'cycle_options',
    },
        create_toggle {
            label = "New Content",
            info = {
                "Include new content and balance changes",
                "(Requires restart)"
            },
            current_option = current_new_content,
            ref_table = ReduxArcanumMod.config,
            ref_value = "new_content"
        }
    }
    if next(SMODS.find_mod("Bunco")) then
        table.insert(t, create_toggle {
            label = "Acid + Bunco Linked Cards",
            info = {
                "When acid destroys a linked card,",
                "treat linked cards as destroyed by Acid",
                "(Won't trigger jokers + returns after blind)"
            },
            current_option = bunco_linked_acid,
            ref_table = ReduxArcanumMod.config,
            ref_value = "bunco_linked_acid"
        })
    end

    for i, _ in ipairs(t) do
        t[i] = {
            n = G.UIT.R,
            config = {
                align = "cm",
                r = 0.1,
                emboss = 0.1,
                outline = 1,
                padding = 0.14
            },
            nodes = { t[i] }
        }
    end

    return {
        n = G.UIT.ROOT,
        config = { align = "cm", minh = G.ROOM.T.h * 0.25, padding = 0.2, r = 0.1, colour = G.C.BLACK },
        nodes = t
    }
end

-- Mod Icon

-- Registers the mod icon
SMODS.Atlas { key = 'modicon', px = 32, py = 32, path = 'modicon.png' }


-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--           LOCALIZATION
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

function ReduxArcanumMod.process_loc_text()
    -- will crash the game if removed
    G.localization.descriptions.Alchemical = G.localization.descriptions.Alchemical or {}
end

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--     ALCHEMICAL INTERFACE
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.load_file("/api/alchemicalAPI.lua")()

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--      ALCHEMICAL UTILS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

function poll_alchemical_edition(_key, _mod, _no_poly)
    _mod = _mod or 1
    local edition_poll = pseudorandom(pseudoseed(_key or 'edition_generic'))
    if ReduxArcanumMod.config.new_content then
        if edition_poll > 1 - 0.003 * _mod * (G.GAME.used_vouchers.v_ReduxArcanum_cauldron and 50 or 1) then
            return { negative = true }
        elseif edition_poll > 1 - 0.006 * G.GAME.edition_rate * _mod and not _no_poly then
            return { polychrome = true }
        end
    else
        if edition_poll > 1 - (G.GAME.used_vouchers.v_ReduxArcanum_cauldron and 0.5 or 0) then
            return { negative = true }
        end
    end
    return nil
end

-- Use this function to apply cauldron effect
function create_alchemical(...)
    local card = create_card("Alchemical", ...)
    local edition = poll_alchemical_edition("random_alchemical", 1, not (card.ability.extra and card.ability.extra > 0))
    card:set_edition(edition)
    return card
end

function add_random_alchemical(self)
    if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
        G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = (function()
                local card = create_alchemical(G.consumeables)
                card:add_to_deck()
                G.consumeables:emplace(card)
                G.GAME.consumeable_buffer = 0
                return true
            end)
        }))
    end
end

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--          ATLASES
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.Atlas { key = 'arcanum_alchemical', path = 'alchemical_atlas.png', px = 71, py = 95 }
SMODS.Atlas { key = 'arcanum_alchemical_undiscovered', path = 'c_alchemy_undiscovered.png', px = 71, py = 95 }
SMODS.Atlas { key = 'arcanum_alchemical_locked', path = 'c_alchemy_locked.png', px = 71, py = 95 }

SMODS.Atlas({ key = 'ca_booster_atlas', path = 'ca_booster_atlas.png', px = 71, py = 95 })

SMODS.Atlas({ key = 'arcanum_decks', path = 'ca_decks_atlas.png', px = 71, py = 95 })

SMODS.Atlas { key = 'arcanum_joker_atlas', path = 'ca_joker_atlas.png', px = 71, py = 95 }

SMODS.Atlas { key = 'ca_tag_elemental', path = 'tag_elemental.png', px = 34, py = 34 }

SMODS.Atlas({ key = 'arcanum_others', path = 'ca_others_atlas.png', px = 71, py = 95 })

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--          GLOBALS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

function ReduxArcanumMod.reset_game_globals(run_start)
    if run_start then
        -- Globals for a whole run (like Fortune Teller)
    else
        -- Globals for a single blind (like Idol)
        ra_reset_played_alchemicals()
    end
end

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--     ALCHEMICAL CARDS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.load_file("/data/alchemicals.lua")()

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--      ALCHEMICAL BOOSTER
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.load_file("/data/boosters.lua")()

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--            TAGS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.load_file("/data/tags.lua")()

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--            JOKERS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.load_file("/data/jokers.lua")()

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--          OVERRIDES
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

local alias__G_UIDEF_use_and_sell_buttons = G.UIDEF.use_and_sell_buttons;
function G.UIDEF.use_and_sell_buttons(card)
    if (card.ability.set == "Alchemical" or card.ability.name == "c_ReduxArcanum_philosopher_stone") and (G.STATE == G.STATES.SMODS_BOOSTER_OPENED or G.STATE == G.STATES.SPECTRAL_PACK) and (card.area == G.pack_cards and G.pack_cards) then
        return {
            n = G.UIT.ROOT,
            config = { padding = 0, colour = G.C.CLEAR },
            nodes = {
                { n = G.UIT.R, config = { mid = true }, nodes = {} },
                {
                    n = G.UIT.R,
                    config = { ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5 * card.T.w - 0.15, minh = 0.8 * card.T.h, maxw = 0.7 * card.T.w - 0.15, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'select_alchemical', func = 'can_select_alchemical' },
                    nodes = {
                        { n = G.UIT.T, config = { text = localize("b_select"), colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true } }
                    }
                },
            }
        }
    end

    local ret = alias__G_UIDEF_use_and_sell_buttons(card)
    return ret
end

G.FUNCS.can_select_alchemical = function(e)
    if (e.config.ref_table.edition and e.config.ref_table.edition.negative) or #G.consumeables.cards < G.consumeables.config.card_limit then
        e.config.colour = G.C.GREEN
        e.config.button = 'select_alchemical'
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end

G.FUNCS.select_alchemical = function(e, mute, nosave)
    e.config.button = nil
    local card = e.config.ref_table
    local area = card.area
    local prev_state = G.STATE
    local dont_dissolve = nil
    local delay_fac = 1

    -- G.TAROT_INTERRUPT = G.STATE
    if card.ability.set == 'Booster' then G.GAME.PACK_INTERRUPT = G.STATE end

    G.CONTROLLER.locks.use = true
    if G.booster_pack and not G.booster_pack.alignment.offset.py and (G.GAME.pack_choices and G.GAME.pack_choices < 2) then
        inc_career_stat('c_ReduxArcanum_alchemy_pack_used', 1)
        check_for_unlock({type = 'career_stat', statname = 'c_ReduxArcanum_alchemy_pack_used'})
        G.booster_pack.alignment.offset.py = G.booster_pack.alignment.offset.y
        G.booster_pack.alignment.offset.y = G.ROOM.T.y + 29
    end
    if G.shop and not G.shop.alignment.offset.py then
        inc_career_stat('c_ReduxArcanum_alchemicals_bought', 1)
        check_for_unlock({type = 'career_stat', statname = 'c_ReduxArcanum_alchemicals_bought'})
        G.shop.alignment.offset.py = G.shop.alignment.offset.y
        G.shop.alignment.offset.y = G.ROOM.T.y + 29
    end
    if G.blind_select and not G.blind_select.alignment.offset.py then
        G.blind_select.alignment.offset.py = G.blind_select.alignment.offset.y
        G.blind_select.alignment.offset.y = G.ROOM.T.y + 39
    end
    if G.round_eval and not G.round_eval.alignment.offset.py then
        G.round_eval.alignment.offset.py = G.round_eval.alignment.offset.y
        G.round_eval.alignment.offset.y = G.ROOM.T.y + 29
    end

    if card.children.use_button then
        card.children.use_button:remove(); card.children.use_button = nil
    end
    if card.children.sell_button then
        card.children.sell_button:remove(); card.children.sell_button = nil
    end
    if card.children.price then
        card.children.price:remove(); card.children.price = nil
    end

    if card.area then card.area:remove_card(card) end

    if (card.ability.set == "Alchemical" or card.ability.name == "c_ReduxArcanum_philosopher_stone") then
        card:add_to_deck()
        G.consumeables:emplace(card)
        play_sound('card1', 0.8, 0.6)
        play_sound('generic1')
        dont_dissolve = true
        delay_fac = 0.2
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
            if not dont_dissolve then card:start_dissolve() end
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.1,
                func = function()
                    G.STATE = prev_state
                    -- G.TAROT_INTERRUPT = nil
                    G.CONTROLLER.locks.use = false

                    if (prev_state == G.STATES.SMODS_BOOSTER_OPENED) and G.booster_pack then
                        if area == G.consumeables then
                            G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
                            G.booster_pack.alignment.offset.py = nil
                        elseif G.GAME.pack_choices and G.GAME.pack_choices > 1 then
                            if G.booster_pack.alignment.offset.py then
                                G.booster_pack.alignment.offset.y = G.booster_pack.alignment.offset.py
                                G.booster_pack.alignment.offset.py = nil
                            end
                            G.GAME.pack_choices = G.GAME.pack_choices - 1
                            inc_career_stat('c_ReduxArcanum_alchemy_pack_used', 1)
                            check_for_unlock({type = 'career_stat', statname = 'c_ReduxArcanum_alchemy_pack_used'})
                        else
                            G.CONTROLLER.interrupt.focus = true

                            G.FUNCS.end_consumeable(nil, delay_fac) -- Will reset G.GAME.PACK_INTERRUPT
                        end
                    else
                        if G.shop then
                            check_for_unlock({type = 'career_stat', statname = 'c_ReduxArcanum_alchemicals_bought'})
                            G.shop.alignment.offset.y = G.shop.alignment.offset.py
                            G.shop.alignment.offset.py = nil
                        end
                        if G.blind_select then
                            G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                            G.blind_select.alignment.offset.py = nil
                        end
                        if G.round_eval then
                            G.round_eval.alignment.offset.y = G.round_eval.alignment.offset.py
                            G.round_eval.alignment.offset.py = nil
                        end
                        if area and area.cards[1] then
                            G.E_MANAGER:add_event(Event({
                                func = function()
                                    G.E_MANAGER:add_event(Event({
                                        func = function()
                                            G.CONTROLLER.interrupt.focus = nil
                                            if card.ability.set == 'Voucher' then
                                                G.CONTROLLER:snap_to({ node = G.shop:get_UIE_by_ID('next_round_button') })
                                            elseif area then
                                                G.CONTROLLER:recall_cardarea_focus(area)
                                            end
                                            return true
                                        end
                                    }))
                                    return true
                                end
                            }))
                        end
                    end
                    return true
                end
            }))
            return true
        end
    }))
end


-- Override for Steammodded dependencies
-- Ensures objects dependent on 'CodexArcanum' will also load with 'ReduxArcanum'

-- SMODS.GameObject.check_dependencies_ra_ref = SMODS.GameObject.check_dependencies
-- function SMODS.GameObject:check_dependencies()
--     if self.dependencies then
--             if type(self.dependencies) == 'string' then self.dependencies = { self.dependencies } end
--             for i, v in ipairs(self.dependencies) do
--                 if v == "CodexArcanum" then self.dependencies[i] = "ReduxArcanum"
--             end
--         end
--     end
--     return self:check_dependencies_ra_ref()
-- end


-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--     TAROTS (and spectral)
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.load_file("/data/tarots.lua")()

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--           VOUCHERS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.load_file("/data/vouchers.lua")()

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--     DECKS AND CARD SLEEVES
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.load_file("/data/decks.lua")()

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--          BOSS BLINDS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

SMODS.load_file("/data/blind.lua")()

-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-
--          EDITIONS
-- -+-+-+-+-+-+-+-+-+-+-+-+-+-+-

-- Alchemical Polychromes

SMODS.Edition:take_ownership('polychrome', {
    calculate = function(self, card, context)
        if card.ability.set == "Alchemical" then
            return
        end
        if context.post_joker or (context.main_scoring and context.cardarea == G.play) then
            return {
                x_mult = card.edition.x_mult
            }
        end
    end
}, true)
