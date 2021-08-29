pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- game

states = {
	"setup",
	"selection",
	"placement",
	"enemy",
	"resolve",
	"match_end",
	"victory",
	"defeat"
}

function _init ()
	
	-- state stuff
	dbg = "" // debugging var
	sel_deck = 5
	sel_board = 1
	last_placed_index = nil
	last_team_turn = rnd({1,2})
	last_winner = nil
	state	= "resolve"
 //state= "match_end"
	board = {} // 1-16 index
	
	add_random_blocks()
	
 deck = {
		generate_card(),
		generate_card(),
		generate_card(),
		generate_card(),
		generate_card()
	}
	
	ai_deck = {
		generate_ai_card(),
		generate_ai_card(),
		generate_ai_card(),
		generate_ai_card(),
		generate_ai_card()
	}
end

function _draw ()
 cls(22)
 draw_bg()
 map(0, 0)
	draw_deck()
	draw_ai_deck()
	draw_board()
	if state == "selection" then
		run_selection_state()
	elseif state == "placement" then
		run_placement_state()
	elseif state == "resolve" then
		run_resolve_state()
	elseif state == "enemy" then
		run_enemy_state()
	elseif state == "match_end" then
		run_match_end_state()	
	end
	//print(dbg, 0, 120)
end
-->8
-- state logic

function run_selection_state()
	last_team_turn = 1
	if btnp(⬆️) then
		sel_prev_deck()
	elseif btnp(⬇️) then
		sel_next_deck()
	end
	
	if btnp(🅾️) then
		state = "placement"
	end
	
	draw_deck_selector()
	draw_card(
		deck[sel_deck], 
		loc_deck[sel_deck][1],
		loc_deck[sel_deck][2]
	)
end

function run_placement_state()	
	if btnp(➡️) then
		sel_board_add(1)
	elseif btnp(⬅️) then
		sel_board_add(-1)
	elseif btnp(⬆️) then
		sel_board_add(-4)
	elseif btnp(⬇️) then
		sel_board_add(4)
	end
	
	draw_board_selector()
	draw_board_sel_card()
	
	if btnp(🅾️) then
		local exists = board[sel_board]
		if not exists then
			last_placed_index = sel_board
			board[sel_board] = deck[sel_deck]
			deck[sel_deck] = nil
			sel_prev_deck()
			state = "resolve"
		end
	end
end

function run_resolve_state ()
	local i = last_placed_index
	if i ~= nil then
		resolve(i, true, true)		
	end
	local empt1 = is_empty(deck)
	local empt2 = is_empty(ai_deck)
	if empt1 and empt2 then
		state = "match_end"
	elseif last_team_turn == 2 then
		state = "selection"	
	else
		state = "enemy"
	end	
end

function run_enemy_state ()
	last_team_turn = 2
	local c = ai_deck[#ai_deck]
	ai_deck[#ai_deck] = nil
	local empty = empty_slots()
	local i = rnd(empty)
	board[i] = c
	last_placed_index = i
	state = "resolve"
end

function run_match_end_state ()
	if last_winner == nil then
		local me = get_team_count(1)
		local ai = get_team_count(2)
	
		if me > ai then
			last_winner = 1 
		else
			last_winner = 2
		end
	end
	
	draw_end_match_bg()
		
	if last_winner == 1 then
		spr(224, 45, 55, 5, 2) 
	elseif last_winner == 2 then
		spr(192, 45, 55, 5, 2) 
	end
	
	if btnp(❎) or btnp(🅾️) then
		_init()
	end
end


-->8
-- draw methods

// card rendering sprites
c_tl=0 // card top left
c_t=1  // card top
c_tr=2
c_r=18
c_br=34
c_b=33
c_bl=32
c_l=16 // card left
c_m=17 // card middle

// arrow sprites
a_tl = 8
a_t = 9
a_tr = 10
a_l1 = 24
a_l2 = 40
a_r1 = 26
a_r2 = 42
a_bl = 56
a_b = 57
a_br = 58

// block sprite
block_spr = 11

loc_deck = {
	{6, 6},
	{6, 13},
	{6, 20},
	{6, 27},
	{6, 34},
	{6, 41},
}

loc_ai_deck = {6, 75}

loc_board = {
	{38, 6},
	{58, 6},
	{78, 6},
	{98, 6},
	
	{38, 34},
	{58, 34},
	{78, 34},
	{98, 34},
	
	{38, 62},
	{58, 62},
	{78, 62},
	{98, 62},
	
	{38, 90},
	{58, 90},
	{78, 90},
	{98, 90}
}

function draw_bg ()
	for i=0,7 do
		for j=0,7 do
			spr(128, j*16, i*16, 2, 2)
		end
	end
end

function draw_deck ()
	for i=1,6 do
		if deck[i] ~= nil then
			if not is_placing(i) then
			 draw_card(
			 	deck[i],
			 	loc_deck[i][1],
			 	loc_deck[i][2]
			 )
			end
		end
	end
end

function draw_ai_deck ()
	for i=1,6 do
		if ai_deck[i] ~= nil then
			local x = loc_ai_deck[1]
			local y = loc_ai_deck[2]+(i*3)
			pal(1, 5)
			pal(15, 1)
		 draw_card_base(x, y)
		 spr(132, x+4, y+8, 2, 2)
		 pal()
		end
	end
end

function draw_board () 
	for i=1,16 do
		if board[i] == "block" then
			draw_block(
				loc_board[i][1],
				loc_board[i][2]
			)
		elseif board[i] ~= nil then
			draw_card(
				board[i],
				loc_board[i][1],
				loc_board[i][2]
			)
		end
	end
end

function draw_card (card, x, y)
	if card.team == 2 then
		pal(15, 14)
	end
	draw_card_base(x, y)
	pal()
	draw_c_arrows(x, y, card)
	draw_c_sprite(x, y, card)
	draw_c_stats(x, y, card)
end

function draw_card_base (x, y)
	pal(2,2)
	spr(c_tl, x, y) 
	spr(c_t, x+8, y)
	spr(c_tr, x+16, y)
	spr(c_l, x, y+8)
	spr(c_m, x+8, y+8)
	spr(c_r, x+16, y+8)
	spr(c_l, x, y+16)
	spr(c_m, x+8, y+16)
	spr(c_r, x+16, y+16)
	spr(c_bl, x, y+24) 
	spr(c_b, x+8, y+24)
	spr(c_br, x+16, y+24)	
	pal()
end

function draw_c_arrows(x,y,card)
	if card.arrows[1]>0 then
		spr(a_tl, x, y)
	end
	if card.arrows[2]>0 then
		spr(a_t, x+8, y)
	end
	if card.arrows[3]>0 then
		spr(a_tr, x+16, y)
	end
	if card.arrows[4]>0 then
		spr(a_l1, x, y+8)
		spr(a_l2, x, y+16)
	end
	if card.arrows[5]>0 then
		spr(a_r1, x+16, y+8)
		spr(a_r2, x+16, y+16)
	end
	if card.arrows[6]>0 then
		spr(a_bl, x, y+24)
	end
	if card.arrows[7]>0 then
		spr(a_b, x+8, y+24)
	end
	if card.arrows[8]>0 then
		spr(a_br, x+16, y+24)
	end
end

function draw_c_sprite(x, y, card)
	spr(card.sprite, x+8, y+8)
end

function draw_c_stats(x,y,card)
	// attack color 9
	// magic color  12
	local s = card.stats
	x = x+8
	y = y+16
	
	if s[1] > s[2] then
		draw_stat(9, 1, s[1], x, y)
	else
		draw_stat(12, 1, s[2], x, y)
	end	

	draw_stat(9, 2, s[3], x, y)
	draw_stat(12, 3, s[4], x, y)
end

function draw_stat(
	color_num,
	column,
	quantity,
	tilex,
	tiley
)	
	local x = tilex+(3*(column-1))
	
	if quantity == 0 then 
		local y = tiley+6
		pset(x  ,y,color_num)
		pset(x+1,y,color_num)
		return
	end	
	
	for i=1,quantity do
		local y = (tiley+7)-(2*i)
		pset(x  ,y  ,color_num)
		pset(x+1,y+1,color_num)
		pset(x+1,y  ,color_num)
		pset(x  ,y+1,color_num)
	end 
end

function draw_block (x, y)
	spr(11, x, y, 3, 4)
end

function draw_deck_selector ()
	local loc = loc_deck[sel_deck]
	local x =	loc[1]
	local y = loc[2]
	draw_selector(x-8, y+12)
end

function draw_board_selector ()
	local loc = loc_board[sel_board]
	local x =	loc[1]
	local y = loc[2]
	
	local existing = board[sel_board]
	local off_x = 0
	local off_y = 0
	
	if existing then
		off_x = 4
		off_y = 4
	end
	
	draw_selector(
		x - 6 + off_x,
	 y + 12 + off_y
	)
end

sel_board_spr = 48
curr_sel_b_s = sel_board_spr
sel_board_anim_t = 0

function draw_selector (x, y)
	local t = sel_board_anim_t	
	local diff = time() - t
	
	if diff > 0.15 then
		curr_sel_b_s += 1
		sel_board_anim_t = time()
		local last = sel_board_spr+1
		if curr_sel_b_s > last then
			curr_sel_b_s = sel_board_spr
		end	
	end
	
	spr(curr_sel_b_s, x, y)
end

function draw_board_sel_card ()
	local i = sel_board
	local existing = board[i]
	
	local off_x = 0
	local off_y = 0
	
	if existing then
		off_x = 4
		off_y = 4
	end
	
	draw_card(
		deck[sel_deck],
		loc_board[i][1] + off_x,
		loc_board[i][2] + off_y
	)
end

function draw_end_match_bg ()
	pal(13, 0)
	map(16, 7, 0, 42, 16, 5)
	pal()
end
-->8
-- helpers

function rndi (i)
	return flr(rnd(i))+1
end

function rn1 ()
	return flr(rnd(2))
end

-- return random # from a to b
function rand(a,b)
  if (a>b) a,b=b,a
  return a+flr(rnd(b-a+1))
end--rand(..)

function is_placing(deck_index)
	return (
		sel_deck == deck_index 
		and state == "placement"
	)
end

function sel_board_add (int)
	local new = sel_board + int
	if new >= 1 and new <= 16 then
		sel_board = new
	end
end

function sel_prev_deck ()	
	if is_empty(deck) then 
		return
	end
 repeat
	 sel_deck = sel_deck - 1
		if sel_deck < 1 then
			sel_next_deck()
		end	
	until (deck[sel_deck] ~= nil)
end

function sel_next_deck ()
 if is_empty(deck) then 
		return
	end
 repeat
	 sel_deck = sel_deck + 1
		if sel_deck > 6 then
			sel_prev_deck()
		end	
	until (deck[sel_deck] ~= nil)
end

function board_i_to_pos (index)
	local i = index-1
	local y = flr(i / 4)
	local x = i % 4
	return {x, y}
end

function board_pos_to_i (x, y)
	local i = y * 4 + x
	return i + 1
end

function get_adjacent (i)
	local pos = board_i_to_pos(i)
	local x = pos[1]
	local y = pos[2]
	local coords = {
		{x-1, y-1},
		{x  , y-1},
		{x+1, y-1},
		{x-1, y  },
		{x+1, y  },
		{x-1, y+1},
		{x  , y+1},
		{x+1, y+1},
	}
	local cards_i = {}
	
	for c in all(coords) do
		local x = c[1]
		local y = c[2]
		local i = board_pos_to_i(x,y)
		if board[i] ~= nil then
			add(cards_i, i) 
		end
	end
	
	return cards_i
end

function tostring(any)
  if (type(any)~="table") return tostr(any)
  local str = "{"
  for k,v in pairs(any) do
    if (str~="{") str=str..","
    str=str..tostring(k).."="..tostring(v)
  end
  return str.."}"
end

function debug (any)
	print(tostring(any))
end

function points_to (card_i, tar_i)
	if areblk(card_i, tar_i) then
		return false
	end
	local c = board[card_i]	
	local cpos = board_i_to_pos(card_i)
	local cx = cpos[1]
	local cy = cpos[2]
	local t = board[tar_i]
	local tpos = board_i_to_pos(tar_i)
	local tx = tpos[1]
	local ty = tpos[2]
	local arr_map = {
		{-1,-1},
		{0 ,-1},
		{1 ,-1},
		{-1, 0},
		{1 , 0},
		{-1, 1},
		{0 , 1},
		{1 , 1},
	}
	
	for k,v in pairs(c.arrows) do
		if v == 1 then
			local rel_pos = arr_map[k]
			local x_rel = rel_pos[1]
			local y_rel = rel_pos[2]
			local x = cx + x_rel
			local y = cy + y_rel
			if x == tx and y == ty then
				return true
			end
		end
	end
	return false
end

function resolve (i, can_battle, can_combo)
	local card = board[i]
	local adj = get_adjacent(i)
	
	for k,tar_i in pairs(adj) do
		local c1 = card
		local c2 = board[tar_i]
		
		if same_team(i, tar_i) then
			return
		end
		
		if points_to(i, tar_i) then
			if points_to(tar_i, i) then
				if can_battle then
					if battle(c1, c2) then
						flip_card(tar_i)
						resolve(tar_i, false, true)
					else
						flip_card(i)
						resolve(i, false, true)
					end
				end
			else
				flip_card(tar_i)
				if can_combo then
					resolve(tar_i, false, false)
				end
			end
		end			
	end
end

function same_team (i, tar_i)
	local c_1 = board[i]
	local c_2 = board[tar_i]
	if isblk(i) or isblk(tar_i) then
		return nil
	end
	return c_1.team == c_2.team
end

function flip_card (i)
	dbg = dbg.." flipping "..i
	local team = board[i].team
	if team == 1 then
		board[i].team = 2
	else
		board[i].team = 1
	end
end

function empty_slots ()
	local empty = {}
	for i=1,16 do
		if board[i] == nil then
			add(empty, i)
		end
	end
	return empty
end

function is_empty (tbl)
	return next(tbl) == nil
end

function get_team_count(team)
	local qty = 0
	for i=1,#board do
		if not isblk(i) then
			if board[i] ~= nil then
				if board[i].team == team then
					qty += 1
				end
			end
		end
	end
	return qty
end

function add_random_blocks ()
	local qty =	rand(0,6)
	
	for i=0,qty do
		// this is flawed because
		// sometimes we override
		// but solving this makes it
		// overly complex so who cares
		local slot = rand(1, 16)
		board[slot] = "block"
		
	end
end

function isblk (index)
	return board[index] == "block"
end

function areblk (i1, i2)
	return isblk(i1) or isblk(i2)
end
-->8
-- cards

// cards definitions
c = {}

// spr  id, a, ma,d, md
c[1] = {64, -1, 0, 1, 1}
c[2] = {65, 1, 0, 0, 1}
c[3] = {66, 3, 0, 2, 4}

// example instanced card
card = { 
	kind = 20,
	// att, m-att, def, m-def
	stats = {0, 2, 1, 1},
	// tl, t, tr, l, r, bl, b, br
	arrows = {0, 1, 0, 0, 1, 1, 1, 0} 
}

function generate_card ()
	local id = rndi(#c)
	return {
		team = 1, // 2 is ai
		kind = id,
		sprite = c[id][1],
		stats = {
			c[id][2],
			c[id][3],
			c[id][4],
			c[id][5]
		},
		arrows = {
			rn1(),
			rn1(),
			rn1(),
			rn1(),
			rn1(),
			rn1(),
			rn1(),
			rn1(),
		}
	}
end

function generate_ai_card()
	local card = generate_card()
	card.team = 2
	return card
end
-->8
-- battle logic

// returns true if c1 wins
function battle (c1, c2)
	
	// phase 1
	local a1 = c1.stats[1]
	local a2 = c1.stats[2]
	local str = get_higher(a1,a2)
	local att = get_rnd_pow(str)
	local d = nil
	if a1 > a2 then
		d = c2.stats[3]
	else
		d = c2.stats[4]
	end	
	local def = get_rnd_pow(d)
	
	// phase 2
	local att2 = rand(0, att)
	local def2 = rand(0, def)
	
	// phase 3
	local c1str = att - att2
	local c2str = def - def2
	
	return c1str > c2str	
end

function get_rnd_pow (str)
	local lo = str * 16
	local hi = lo + 15
	return rand(lo, hi)
end

function get_higher (v1, v2)
	if v1 > v2 then
		return v1
	else
		return v2
	end
end
__gfx__
000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dd5ddddd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000055555555555555555555000000000000000000
000111111111111111111000000000000000000000000000dddddddd000000000000000000000000000000000051111115111111111115000000000000000000
0001ffffffffffffffff1000000000555555555555000000dddddddd000000000000000000000000000000000051555555555555555515000000000000000000
0001ffffffffffffffff1000000005555555555555500000ddddd5dd000000000000022200022000222000000051511111551111111515000000000000000000
0001ffffffffffffffff1000000055511111111115550000dddddddd000000000000022000222200022000000051511111151111111515000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000dddddddd000000000000020000000000002000000051511111151111111515000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000dddddddd000000000000000000000000000000000051511111155111111515000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000dddddddd000000000000000000000000000000000051555511115551111515000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000dddddddd000000000000000000000000000000000055551111111155111515000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000dddddddd000000000000000000000000000000000051511111111115515555000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000ddd5dddd000000000000000000000000000000000051511111111115555515000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000dddddddd000000000000000000000000000000000051511111115551111515000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000dddddddd000000000000002000000000020000000051511111155511111515000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000dddddddd000000000000022000000000022000000051511111551551111515000000000000000000
0001ffffffffffffffff10000000551dddddddddd1550000dddddddd000000000000022000000000022000000051511111511155111515000000000000000000
0001ffffffffffffffff1000000055511111111115550000dddddddd000000000000002000000000020000000051511111511111551515000000000000000000
0001ffffffffffffffff1000000005555555555555500000dddddddd000000000000000000000000000000000051511111511111155515000000000000000000
0001ffffffffffffffff1000000000555555555555000000dddddddd000000000000000000000000000000000051511115511111115515000000000000000000
000111111111111111111000000000000000000000000000d5dddddd000000000000000000000000000000000051511155111111111555000000000000000000
000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000051511551111111111515000000000000000000
000000000000000000000000000000000000000000000000ddddddd5000000000000000000000000000000000051511555111111111515000000000000000000
000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000051511551511151111515000000000000000000
00011000000000000000000000000000dddd1550dddd155000000000000000000000020000000000002000000055555515511155511515000000000000000000
0001f100000110000000000000000000dddd15501111555000000000000000000000022000222200022000000051511115111111555515000000000000000000
0001af100001f1000000000000000000dddd15505555550000000000000000000000022200022000222000000051511115111111115555000000000000000000
0001aaf10001af100000000000000000dddd15505555500000000000000000000000000000000000000000000051555555555555555515000000000000000000
0001aa910001a9100000000055555000dddd15500000000000000000000000000000000000000000000000000051111115111111111115000000000000000000
0001a910000191000000000055555500dddd15500000000000000000000000000000000000000000000000000055555555555555555555000000000000000000
00019100000110000000000011115550dddd15500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000110000000000000000000dddd1550dddd15500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00980900000330000000008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0090090000333000088a0a8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900990033333300008a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099009032323330000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009009333333330000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000990033223300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9999991999999999ffff2fff77777fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444421994444444ff6f2f6fffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444421944444444ffff2fffffff777f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444421944444444ffff2fffff77ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242421424424424ffff2fffffffffff000000555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424221244242442ff6f2f6fffffffff000005005050000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222221222222222ffff2fffffffffff000050050005000000055055055555000000000000000000000000000000000000000000000000000000000000000000
11111111111111114444444442222244000050005005000000050505000500000000000000000000000000000000000000000000000000000000000000000000
9999999999991999fffffffffff2ffff000050050005000000050005000500000000000000000000000000000000000000000000000000000000000000000000
4444444444441944ff7777ffff646fff000050005005000000050005000500000000000000000000000000000000000000000000000000000000000000000000
4444444444441944ffffff77fff4ffff000005050050000000050005000500000000000000000000000000000000000000000000000000000000000000000000
4444242424441944fffffffffff4ffff000000555500000000050005000500000000000000000000000000000000000000000000000000000000000000000000
2422424242241424fffffffffff4ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4244242424421242fff7777fff646fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222222221222fffffffffff2ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111114422244222222244000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009000000009999000009999000099999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00099000000095555900095555990955555950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00959000000095990900095995590095999500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09959000000959009590959559950095955000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00959000000959009590959005500095900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00959000000959009590955999000955999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00959000000959009590095555900095550950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00959000000959009590009999590095999500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00959000000959009090000000959095955000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00959000000950995090099900959095900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00959999990090550950955599595095999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00950000950090000950090055950095000950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999999500059999500059999500099999500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055555000005555000005555000055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000009900990000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09999000000099990095909559000000099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00955900000955900995900905900000959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00900900900900900095900095590000959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00590909590909500095900095059000959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090595059509000095900095905900959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00059050005095000095900095990590959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00009000000090000095900095959059959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00005900900950000095900095905905959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000909590900000095900095900590509000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000909590900000099500099500059095000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000595059500000095000095000005950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000050005000000050000050000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0304043303040404040404040404040500808180818081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1306143413141414140614141414141500909190919091000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314163413141606141414141414161500808180818081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314143413161416141416140614141500909190919091000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314063413141414140614141414141500808180818081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1316143413061414161426141414161500909190919091000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314143413141426141414141414141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314163413141414141414161406141504040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2324243513141614141416141414141514141414141414141414141414141414140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304043313141406141414141414141514141414141414141414141414141414140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1306143413161414161414141414261514141414141414141414141414141414140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314163413141426161414141614141524242424242424242424242424242424240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314143413141414141414061414141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314263413141614142614141614061500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1316143413161426141414161414141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2324243523242424242424242424242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
