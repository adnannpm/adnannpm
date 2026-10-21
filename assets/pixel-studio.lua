-- Original profile artwork. Run with Aseprite's execute_lua tool.
-- Outputs are relative to the workspace passed by the tool.
local dir = assert(app.params['aseprite_mcp_workspace'])
local s = Sprite(384, 144, ColorMode.RGB)
s.layers[1].name = 'Studio / animated scene'
local colors = {
  bg=0x101827, wall=0x172338, panel=0x21344a, edge=0x35516a,
  dark=0x0b1220, teal=0x55d6be, light=0xb4f4df, muted=0x71969e,
  wood=0x72505a, top=0xb17a75, skin=0xe8b49a, hair=0x242334,
  shirt=0x407c8b, shadow=0x214858, gold=0xe8bf80, white=0xe1ede9,
}
local function col(name)
  local n = colors[name]
  return Color{r=(n >> 16)&255,g=(n >> 8)&255,b=n&255,a=255}
end
local glyphs = {
 A={'01110','11011','11011','11111','11011','11011','11011'},
 D={'11110','11011','11011','11011','11011','11011','11110'},
 N={'11011','11111','11111','11111','11011','11011','11011'},
 P={'11110','11011','11011','11110','11000','11000','11000'},
 I={'111','010','010','010','010','010','111'},
 X={'11011','11011','01110','00100','01110','11011','11011'},
 E={'11111','11000','11000','11110','11000','11000','11111'},
 L={'11000','11000','11000','11000','11000','11000','11111'},
 S={'01111','11000','11000','01110','00011','00011','11110'},
 T={'11111','00100','00100','00100','00100','00100','00100'},
 U={'11011','11011','11011','11011','11011','11011','01110'},
 O={'01110','11011','11011','11011','11011','11011','01110'},
}
for f=1,12 do
  if f>1 then s:newEmptyFrame() end
  s.frames[f].duration=0.2
  local img=Image(384,144,ColorMode.RGB)
  local function rect(x,y,w,h,c)
    for yy=y,y+h-1 do for xx=x,x+w-1 do
      if xx>=0 and xx<384 and yy>=0 and yy<144 then img:drawPixel(xx,yy,col(c)) end
    end end
  end
  local function text(str,x,y,scale,c)
    for ch in str:gmatch('.') do
      local g=glyphs[ch]
      if g then
        for row,line in ipairs(g) do for i=1,#line do
          if line:sub(i,i)=='1' then rect(x+(i-1)*scale,y+(row-1)*scale,scale,scale,c) end
        end end
        x=x+(#g[1]+1)*scale
      else x=x+4*scale end
    end
  end
  -- Quiet title panel and architectural frame.
  rect(0,0,384,144,'bg'); rect(0,132,384,12,'dark')
  rect(16,22,24,2,'teal'); rect(44,22,5,2,'edge')
  text('ADNAN',16,36,3,'white')
  text('PIXEL STUDIO',17,67,1,'teal')
  rect(17,86,95,1,'panel'); rect(17,94,55,2,'muted'); rect(17,101,76,2,'edge')
  for i=0,3 do rect(17+i*8,117,4,4,i==math.floor((f-1)/3) and 'teal' or 'panel') end
  rect(153,14,215,118,'wall'); rect(153,14,2,118,'panel')
  -- Window, moon and skyline.
  rect(267,24,86,63,'edge'); rect(270,27,80,57,'dark')
  rect(325,33,10,10,'gold'); rect(329,31,8,10,'dark')
  local stars={{278,33},{300,39},{342,48},{312,30},{284,51},{336,59}}
  for i,p in ipairs(stars) do rect(p[1],p[2],1,1,(f+i)%6<2 and 'light' or 'edge') end
  for i=0,8 do
    local h=8+(i*7)%18
    rect(271+i*9,83-h,8,h,'panel')
    rect(273+i*9,86-h,2,2,'muted')
  end
  rect(307,27,2,57,'edge'); rect(270,60,80,2,'edge')
  -- Shelf and books.
  rect(174,32,66,3,'wood'); rect(178,35,3,6,'edge'); rect(232,35,3,6,'edge')
  for i=0,4 do rect(177+i*7,19+(i%2)*3,5,13-(i%2)*3,i%2==0 and 'shirt' or 'top') end
  rect(220,26,12,6,'gold'); rect(223,22,6,6,'gold'); rect(225,20,2,2,'light')
  -- Floorboards and ambient pool.
  rect(155,115,213,17,'panel')
  for x=163,360,25 do rect(x,116,1,16,'wall') end
  rect(222,126,94,3,'shadow'); rect(216,129,108,2,'shadow')
  -- Desk and monitor with game viewport.
  rect(181,91,159,4,'top'); rect(181,95,159,5,'wood')
  rect(188,100,5,27,'wood'); rect(330,100,5,27,'wood')
  rect(210,48,65,40,'dark'); rect(213,51,59,33,'shadow')
  rect(213,51,59,3,'edge'); rect(216,52,1,1,'teal'); rect(219,52,1,1,'gold')
  rect(217,58,13,1,'teal'); rect(217,62,9,1,'muted'); rect(220,66,12,1,'gold')
  rect(217,70,11,1,'teal'); rect(220,74,7,1,'muted')
  rect(237,57,32,23,'bg'); rect(237,76,32,4,'shirt')
  rect(241,70,8,2,'teal'); rect(260,65,7,2,'teal')
  local jump=({0,1,3,5,6,5,3,1,0,0,0,0})[f]
  rect(252,70-jump,4,5,'gold'); rect(253,69-jump,2,1,'white')
  rect(238,61,1,1,'light'); rect(266,59,1,1,'light')
  rect(238,88,9,3,'edge'); rect(233,90,20,1,'muted')
  -- Keyboard, cup, tiny plant.
  rect(216,94,42,3,'dark')
  for x=219,253,4 do rect(x,94,2,1,'muted') end
  rect(282,83,7,8,'white'); rect(289,85,3,4,'muted'); rect(290,86,1,2,'wall')
  local steam=math.floor((f-1)/4)
  rect(284+steam%2,78-steam,1,3,'muted'); rect(286,73-steam,1,2,'edge')
  rect(319,84,11,7,'wood'); rect(321,82,7,3,'top'); rect(324,67,2,16,'teal')
  rect(319,70,5,3,'shirt'); rect(316,67,5,3,'teal'); rect(326,74,6,3,'teal'); rect(330,71,3,3,'shirt')
  -- Seated developer, headphones and typing hands.
  local bob=(f==5 or f==6) and 1 or 0
  rect(264,103,13,18,'dark'); rect(271,119,3,10,'edge'); rect(260,129,26,2,'dark')
  rect(252,91+bob,18,21,'shirt'); rect(253,91+bob,4,15,'teal')
  rect(250,111,22,6,'dark'); rect(250,116,6,10,'shadow'); rect(245,125,11,3,'dark')
  rect(256,71+bob,14,18,'skin'); rect(254,69+bob,16,8,'hair')
  rect(266,74+bob,6,12,'hair'); rect(253,76+bob,3,7,'skin')
  rect(255,69+bob,15,2,'muted'); rect(268,72+bob,3,11,'edge'); rect(267,77+bob,5,7,'teal')
  rect(254,86+bob,8,5,'skin')
  rect(247,95+bob,10,5,'shirt'); rect(237,94+(f%2),12,3,'skin')
  -- Small tower and power light.
  rect(302,102,18,26,'dark'); rect(305,106,12,1,'edge'); rect(305,110,12,1,'edge')
  rect(308,119,3,2,'teal')
  rect(0,0,384,1,'panel'); rect(0,143,384,1,'panel')
  local old=s.layers[1]:cel(f)
  if old then old.image=img else s:newCel(s.layers[1],s.frames[f],img) end
end
local tag=s:newTag(1,12); tag.name='studio-loop'
s:saveAs(dir..'/pixel-studio.aseprite')
local out=Sprite(s)
out:resize(1152,432)
out:saveCopyAs(dir..'/pixel-studio.gif')
for i=#out.frames,2,-1 do out:deleteFrame(i) end
out:saveCopyAs(dir..'/pixel-studio.png')
out:close()
print('Saved editable studio, 12-frame GIF and preview PNG.')
