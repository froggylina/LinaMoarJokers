SMODS.Atlas {
	key = "MoarJokers",
	path = "MoarJokers.png",
	px = 71,
	py = 95
}

SMODS.Joker {
    key = "krakenslayer",
    atlas = "MoarJokers",
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    pos = { x = 0, y = 0 },
    config = { extra = { Xmult = 3, every = 2, loyalty_remaining = 2 } },
    loc_txt = {
        name = 'Bring It Down',
        text = {
            "{C:white,X:mult}X3{} Mult every",
            "{C:attention}#2#{} hands played",
            "{C:inactive}(#3#){}"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.Xmult,
                card.ability.extra.every + 1,
                localize { type = 'variable', key = (card.ability.extra.loyalty_remaining == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = { card.ability.extra.loyalty_remaining } }
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            card.ability.extra.loyalty_remaining = (card.ability.extra.every - 1 - (G.GAME.hands_played - card.ability.hands_played_at_create)) %
                (card.ability.extra.every + 1)
            if not context.blueprint then
                if card.ability.extra.loyalty_remaining == 0 then
                    local eval = function(card) return card.ability.extra.loyalty_remaining == 0 and not G.RESET_JIGGLES end
                    juice_card_until(card, eval, true)
                end
            end
            if card.ability.extra.loyalty_remaining == card.ability.extra.every then
                return {
                    xmult = card.ability.extra.Xmult
                }
            end
        end
    end
}

SMODS.Joker {
	key = 'jevil',
    blueprint_compat = false,
	loc_txt = {
		name = 'Jevil',
                text = {
                    "All played cards",
                    "become {C:attention}Glass{} cards",
                    "when scored",
                },
	},
	config = { extra = {} },
	rarity = 4,
	atlas = 'MoarJokers',
	pos = { x = 2, y = 0 },
	soul_pos = { x = 3, y = 0 },
	cost = 20,
     loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
    end,
    calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint then
            for _, scored_card in ipairs(context.scoring_hand) do
                    scored_card:set_ability('m_glass', nil, true)
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            scored_card:juice_up()
                            return true
                        end
                    }))
                end
            end
        end
}