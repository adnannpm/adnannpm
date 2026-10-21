-- Animated tribute to the user's first released game.
-- Background textures sampled from their supplied gameplay screenshot.
-- Rebuilt runner sprite and run cycle; this is not a gameplay recording.
-- Copy first-game-forest.png and first-game-ground.png into the MCP workspace.
local dir=assert(app.params['aseprite_mcp_workspace'])
local forest=Image{fromFile=dir..'/first-game-forest.png'}
local ground=Image{fromFile=dir..'/first-game-ground.png'}
local s=Sprite(384,144,ColorMode.RGB)
s.layers[1].name='Forest / parallax'
local dust=s:newLayer();dust.name='Dust / fleeing'
local runner=s:newLayer();runner.name='Runner / run cycle'
local palette={
 ink=0x251b19, edge=0x422923, skin=0x985f44, lit=0xb87950,
 red=0xb6323c, hat=0x7d2933, white=0xe5eee1, shade=0xb5c9bc,
 eye=0xabe1d7, dark=0x101b17, shirt=0xd18539, gold=0xf0ad52,
 trousers=0x6d4030, boot=0x39291e, mist=0x9eac90,
}
local function color(key)
 local n=palette[key]
 return Color{r=(n>>16)&255,g=(n>>8)&255,b=n&255,a=255}
end
local function rect(img,x,y,w,h,c)
 for yy=y,y+h-1 do for xx=x,x+w-1 do
  if xx>=0 and xx<img.width and yy>=0 and yy<img.height then img:drawPixel(xx,yy,color(c)) end
 end end
end
-- Four strong poses, repeated three times while background advances seamlessly.
local poses={{-6,6,0},{-2,2,-1},{6,-6,0},{2,-2,-1}}
for f=1,24 do
 if f>1 then s:newEmptyFrame() end
 s.frames[f].duration=0.09
 local bg=Image(384,144,ColorMode.RGB)
 for y=0,143 do for x=0,383 do
  if y<114 then bg:drawPixel(x,y,forest:getPixel((x+(f-1)*8)%192,math.min(y,109)))
  else bg:drawPixel(x,y,ground:getPixel((x+(f-1)*12)%96,y-114)) end
 end end
 local old=s.layers[1]:cel(f)
 if old then old.image=bg else s:newCel(s.layers[1],s.frames[f],bg) end
 local fx=Image(384,144,ColorMode.RGB)
 for i=0,5 do
  local age=(f-1+i*4)%24
  local x=140-age*3
  local y=111-math.floor(age/5)-(i%2)*2
  if age<19 then rect(fx,x,y,math.max(1,4-math.floor(age/6)),2,'mist') end
 end
 -- Subtle speed streaks trail behind the player.
 rect(fx,102-(f%3)*4,90,12,1,'mist')
 rect(fx,117-(f%4)*3,100,7,1,'mist')
 s:newCel(dust,s.frames[f],fx)
 local img=Image(384,144,ColorMode.RGB)
 local pose=poses[math.floor((f-1)/3)%4+1]
 local x=154; local y=77+pose[3]
 -- Legs counter-swing underneath a forward-leaning torso.
 for i,offset in ipairs({pose[1],pose[2]}) do
  local lx=x+4+(i-1)*7
  local knee=lx+math.floor(offset/2)
  rect(img,lx,y+25,6,7,'ink');rect(img,lx+1,y+25,4,5,'trousers')
  rect(img,knee,y+30,6,5,'ink');rect(img,knee+1,y+30,4,3,'trousers')
  rect(img,lx+offset,y+33,8,4,'ink');rect(img,lx+offset+1,y+33,6,2,'boot')
 end
 -- Far arm.
 local arm=pose[1]
 rect(img,x+2-math.floor(arm/2),y+19,6,10,'ink')
 rect(img,x+3-math.floor(arm/2),y+20,4,6,'skin')
 -- Orange shirt and dark outline.
 rect(img,x+5,y+17,17,13,'ink');rect(img,x+7,y+18,12,10,'shirt')
 rect(img,x+8,y+19,4,8,'gold');rect(img,x+17,y+20,2,8,'skin')
 -- Head, ear and expressive face, looking right.
 rect(img,x+4,y+1,21,18,'ink');rect(img,x+1,y+7,5,8,'ink')
 rect(img,x+3,y+8,4,5,'skin');rect(img,x+7,y+3,17,13,'skin')
 rect(img,x+19,y+10,7,5,'skin');rect(img,x+8,y+4,13,3,'lit')
 rect(img,x+17,y+7,3,4,'dark');rect(img,x+18,y+7,2,2,'eye')
 rect(img,x+21,y+13,3,2,'eye');rect(img,x+9,y+12,3,2,'eye')
 -- Red cap, animated white feather.
 rect(img,x+5,y-3,17,5,'ink');rect(img,x+3,y+1,23,4,'ink')
 rect(img,x+6,y-2,15,4,'hat');rect(img,x+7,y,16,4,'red')
 rect(img,x+22,y+2,6,3,'red')
 local feather=math.floor((f-1)/3)%2
 rect(img,x+19,y-6+feather,3,7,'shade')
 rect(img,x+20,y-9+feather,4,6,'white');rect(img,x+23,y-10+feather,3,4,'white')
 -- Near arm swings opposite the leading leg.
 local ax=x+13+math.floor(arm/2)
 rect(img,ax,y+20,6,8,'ink');rect(img,ax+1,y+21,4,5,'skin')
 rect(img,ax+3,y+24,5,4,'ink');rect(img,ax+4,y+24,3,2,'lit')
 s:newCel(runner,s.frames[f],img)
end
local tag=s:newTag(1,24);tag.name='forest-escape'
s:saveAs(dir..'/first-game-run.aseprite')
local export=Sprite(s);export:resize(1152,432)
export:saveCopyAs(dir..'/first-game-run.gif')
for i=#export.frames,2,-1 do export:deleteFrame(i) end
export:saveCopyAs(dir..'/first-game-run.png');export:close()
print('Saved first-game tribute: 24-frame run loop, editable layers and preview.')
