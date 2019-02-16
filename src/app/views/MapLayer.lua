local MapLayer = class("MapLayer",function ()
	return cc.Scene:create()
end)

function MapLayer:createScene()
	local scene = MapLayer:new()
	scene:init()
	return scene
end

function MapLayer:init()
	--音乐
	if XML:getBoolForKey(MUSIC_KEY) then
		musicVolume = XML:getFloatForKey(MUSICVOL) * 100
		audioEngine:setMusicVolume(musicVolume)

		if(audioEngine:isMusicPlaying()) then
			audioEngine:pauseMusic()
		end
		audioEngine:playMusic("Sound/GameBGM.wav", true)
	else
		audioEngine:pauseMusic()
	end
	--加载资源
	spriteFrames:addSpriteFrames("pnglist/gateMap.plist")

	--地图背景
	display.newSprite(spriteFrames:getSpriteFrame("GateMapBG.png"),display.cx,display.cy):addTo(self)

	--菜单
	local closeItem = createMenuItemSprite("CloseNormal.png", "CloseSelected.png",display.width - 47, display.height - 44,
	 	function() self:closeCallBack() end)
	local challengeItem = createMenuItemSprite("tiaozhanNormal.png", "tiaozhanSelected.png", display.width - 254, 7*display.height/72,
		function() self:challengeCallBack() end)
	cc.Menu:create(closeItem,challengeItem):setPosition(0,0):addTo(self)
	
	--关卡选择
	self:showLevelSeclect()
end

function MapLayer:showLevelSeclect()
	local level = { }
	self.m_selectGateMenu = require("app.views.SelectGate"):new()
	for i=1,3 do
		local pngName = string.format("Gate_%s.png", i)
		level[i] = createMenuItemSprite(pngName, pngName, 0, 0, function() self:level_callBack(i) end)
		self.m_selectGateMenu:addMenuItem(level[i])
	end
	self.m_selectGateMenu:setPosition(display.cx,display.cy + 74):addTo(self)

	cc.Label:createWithSystemFont("1000","Arial",45)
	:setColor(cc.c3b(0, 255, 255))
	:setPosition(300,60)
	:addTo(self)

	cc.Label:createWithSystemFont("10","Arial",45)
	:setColor(cc.c3b(0, 255, 255))
	:setPosition(640,60)
	:addTo(self)
end

function MapLayer:level_callBack(level)
	PlayEffectMusic()
	local levelOn = false
	if level == 2 then
		levelOn = XML:getBoolForKey(GATEONE, false)
	end
	if level == 3 then
		levelOn = XML:getBoolForKey(GATETWO, false)
	end
    if level ~= 1 then
    	if levelOn == true then
    		XML:setIntegerForKey(GAMELEVEL_KEY, level)
    		XML:setIntegerForKey(SELECTGATE, level)
    		XML:flush()
    		g_iSelectGate = level
    		print("level:",level)
    		local scene = require("app.views.GameScene"):createScene()
    		cc.Director:getInstance():replaceScene(scene)
    	end
    else
    	XML:setIntegerForKey(GAMELEVEL_KEY, 1)
    	XML:setIntegerForKey(SELECTGATE, 1)
    	XML:flush()
    	g_iSelectGate = 1
    	print("level:",level)
    	local scene = require("app.views.GameScene"):createScene()
    	cc.Director:getInstance():replaceScene(scene)
    end
end

function MapLayer:closeCallBack()
	PlayEffectMusic()
	local scene = require("app.views.MainScene"):createScene()
	cc.Director:getInstance():replaceScene(scene)
end

function MapLayer:challengeCallBack()
	PlayEffectMusic()
	self.m_selectGateMenu:getCurrentItem():activate()
end


return MapLayer