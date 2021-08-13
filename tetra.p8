pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
// game

states = {
	"setup",
	"selection",
	"placement",
	"enemy",
	"resolve",
	"victory",
	"defeat"
}

function _init ()
	sel_deck = 6
	sel_board = 1
	state	= "selection"
 deck = {
		generate_card(),
		generate_card(),
		generate_card(),
		generate_card(),
		generate_card(),
		generate_card(),
	}
	board = {
		// cards here
		generate_card()
	}
end

function _draw ()
 cls(22)
 draw_bg()
 map(0, 0)
	draw_deck()
	draw_board()
	if state == "selection" then
		run_selection_state()
	elseif state == "placement" then
		run_placement_state()
	end
end
-->8
// draw

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

loc_deck = {
	{6, 6},
	{6, 13},
	{6, 20},
	{6, 27},
	{6, 34},
	{6, 41},
}

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

function draw_board () 
	for i=1,16 do
		if board[i] ~= nil then
			draw_card(
				board[i],
				loc_board[i][1],
				loc_board[i][2]
			)
		end
	end
end

function draw_card (card, x, y)
	draw_card_base(x, y)
	draw_arrows(x, y, card)
	draw_c_sprite(x, y, card)
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

function draw_arrows(x, y, card)
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

function draw_deck_selector ()
	local loc = loc_deck[sel_deck]
	local x =	loc[1]
	local y = loc[2]
	spr(48, x-8, y+12)
end

function draw_board_selector ()
	local loc = loc_board[sel_board]
	local x =	loc[1]
	local y = loc[2]
	spr(48, x-8, y+12)
end

function draw_board_sel_card ()
	local i = sel_board
	draw_card(
		deck[sel_deck],
		loc_board[i][1],
		loc_board[i][2]
	)
end


-->8
// cards

// cards definitions
c = {}

// sprite id, a, ma, d, md
c[1] = {64, 0, 2, 1, 1}
c[2] = {65, 1, 0, 1, 1}
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
	local id = rndi(3)
	return {
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
-->8
// helpers

function rndi (i)
	return flr(rnd(i))+1
end

function rn1 ()
	return flr(rnd(2))
end

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

function sel_deck_add (int)
	local new = sel_deck + int
	if new >= 1 and new <= 6 then
		sel_deck = new
	end
end
-->8
// state logic

function run_selection_state()
	if btnp(⬆️) then
		sel_deck_add(-1)
	elseif btnp(⬇️) then
		sel_deck_add(1)
	end
	
	if btnp(4) then
		if deck[sel_deck] ~= nil then
			state = "placement"
		end
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
	elseif btnp(🅾️) then
		state = "resolve"
		 
	end 
	
	draw_board_selector()
	draw_board_sel_card()
end



__gfx__
000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dd5ddddd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
000111111111111111111000000000000000000000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
0001ffffffffffffffff1000000000555555555555000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
0001ffffffffffffffff1000000005555555555555500000ddddd5dd000000000000022200022000222000000000000000000000000000000000000000000000
0001ffffffffffffffff1000000055511111111115550000dddddddd000000000000022000222200022000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000dddddddd000000000000020000000000002000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000ddd5dddd000000000000000000000000000000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000dddddddd000000000000002000000000020000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000dddddddd000000000000022000000000022000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000551ddddddddddd550000dddddddd000000000000022000000000022000000000000000000000000000000000000000000000
0001ffffffffffffffff10000000555dddddddddd5550000dddddddd000000000000002000000000020000000000000000000000000000000000000000000000
0001ffffffffffffffff1000000005555555555555500000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
0001ffffffffffffffff1000000000555555555555000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
000111111111111111111000000000000000000000000000d5dddddd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000ddddddd5000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000ddddd550ddddd55000000000000000000000020000000000002000000000000000000000000000000000000000000000
00000f00000000000000000000000000ddddd550dddd555000000000000000000000022000222200022000000000000000000000000000000000000000000000
00000af0000000000000000000000000ddddd5505555550000000000000000000000022200022000222000000000000000000000000000000000000000000000
00000aaf000000000000000000000000ddddd5505555500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000aa9000000000000000055555000ddddd5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000a90000000000000000055555500ddddd5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000900000000000000000011115550ddddd5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ddddd550ddddd5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
4242421424424424ffff2fffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2424221244242442ff6f2f6fffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222221222222222ffff2fffffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111114444444442222244000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9999999999991999fffffffffff2ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444441944ff7777ffff646fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444441944ffffff77fff4ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444242424441944fffffffffff4ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2422424242241424fffffffffff4ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4244242424421242fff7777fff646fff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2222222222221222fffffffffff2ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111114422244222222244000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0304043303040404040404040404040500808180818081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314143413141414141414141414141500909190919091000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314163413141606141414141414161500808180818081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314143413141416141416140614141500909190919091000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314063413141414140614141414141500808180818081000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1316143413141414161426141414161500909190919091000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314143413141426141414141414141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314163413141414141414161406141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314143413141614141416141414141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2324243513141406141414141414141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013141414161414141414261500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013141426161414141614141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013141414141414061414141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013141614142614141614061500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000013141426141414161414141500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000023242424242424242424242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
