local SetLayer = class("SetLayer",function ()
	return cc.Scene:create()
end)

function SetLayer:createScene()
	local scene = SetLayer:new()
	scene:init()
	return scene
end

function SetLayer:init()
	local musicVolume = XML:getFloatForKey(MUSICVOL) * 100
	local effectVolume = XML:getFloatForKey(SOUNDVOL) * 100
	
	local bg = display.newSprite(spriteFrames:getSpriteFrame("image-0.png"))
	bg:setPosition(display.cx,display.cy)
	self:addChild(bg)

	display.newSprite(spriteFrames:getSpriteFrame("BGPicSet.png"))
	:setPosition(display.cx + 50,display.cy)
	:addTo(self)

	local closeBtn = createMenuItemSprite("closeSetNormal.png","closeSetSelected.png",display.width - 150,display.height - 100,
		function ()
			PlayEffectMusic()
			cc.Director:getInstance():replaceScene(require("app.views.MainScene"):createScene())
		end)

	local saveBtn = createMenuItemSprite("SaveSettings.png","SaveSettings.png",display.cx + 40,display.cy - 190,
		function ()
			PlayEffectMusic()
			cc.Director:getInstance():replaceScene(require("app.views.MainScene"):createScene())
		end)

	local musicOn = createMenuItemSprite("unchecked.png","unchecked.png")
	local musicOff = createMenuItemSprite("Hook.png","Hook.png")
	local effectOn = createMenuItemSprite("unchecked.png","unchecked.png")
	local effectOff = createMenuItemSprite("Hook.png","Hook.png")

	local musicToggle = self:createMenuItemToggle(musicOn,musicOff,369.5,457,"musicSet")
	local effectToggle = self:createMenuItemToggle(effectOn,effectOff,369.5,357,"effectSet")

	if XML:getBoolForKey(MUSIC_KEY) then
		musicToggle:setSelectedIndex(1)
	else
		musicToggle:setSelectedIndex(0)
	end

	if XML:getBoolForKey(SOUND_KEY) then
		effectToggle:setSelectedIndex(1)
	else
		effectToggle:setSelectedIndex(0)
	end

	cc.Menu:create(closeBtn,saveBtn,musicToggle,effectToggle)
	:setPosition(0,0)
	:addTo(self)

	local musicSlider = self:createControlSlider("bgBar.png","progressBar.png","ThumbBtn.png",800,457)
	local function changeMusicVolume()
		XML:setFloatForKey(MUSICVOL, musicSlider:getValue() / 100)
		XML:flush()
		audioEngine:setMusicVolume(XML:getFloatForKey(MUSICVOL) * 100)
	end
	musicSlider:setValue(musicVolume)
	musicSlider:registerControlEventHandler(changeMusicVolume,cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
	self:addChild(musicSlider)

	local effectSlider = self:createControlSlider("bgBar.png","progressBar.png","ThumbBtn.png",800,357)
	local function changeEffectVolume()
		XML:setFloatForKey(SOUNDVOL, effectSlider:getValue() / 100)
		XML:flush()
		audioEngine:setEffectsVolume(XML:getFloatForKey(SOUND_KEY) * 100)
	end
	effectSlider:setValue(effectVolume)
	effectSlider:registerControlEventHandler(changeEffectVolume,cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
	self:addChild(effectSlider)
end

function SetLayer:createMenuItemToggle(btnOn,btnOff,x,y,callBackType)
	local musicToggle = cc.MenuItemToggle:create(btnOn)
	musicToggle:addSubItem(btnOff)
	musicToggle:setPosition(x,y)
	if callBackType == "musicSet" then
		local function callBack()
			self:musicSet(musicToggle)
		end
		musicToggle:registerScriptTapHandler(callBack)
	end
	if callBackType == "effectSet" then
		local function callBack()
			self:effectSet(musicToggle)
		end
		musicToggle:registerScriptTapHandler(callBack)
	end
	
	return musicToggle
end

function SetLayer:musicSet(musicToggle)
	PlayEffectMusic()
	if musicToggle:getSelectedIndex() == 0 then
		XML:setBoolForKey(MUSIC_KEY, false)
		audioEngine:pauseMusic()
	else
		XML:setBoolForKey(MUSIC_KEY, true)
		audioEngine:setMusicVolume(XML:getFloatForKey(MUSICVOL))
		audioEngine:resumeMusic()
	end
	XML:flush()
end

function SetLayer:effectSet(musicToggle)
	if musicToggle:getSelectedIndex() == 0 then
		XML:setBoolForKey(SOUND_KEY, false)
	else
		XML:setBoolForKey(SOUND_KEY, true)
	end
	XML:flush()
end

function SetLayer:createControlSlider(backgroundSprite, pogressSprite, thumbSprite,x,y)
	local controlSlider = cc.ControlSlider:create(display.newSprite(spriteFrames:getSpriteFrame(backgroundSprite)),
	 display.newSprite(spriteFrames:getSpriteFrame(pogressSprite)), 
	 display.newSprite(spriteFrames:getSpriteFrame(thumbSprite))
	 )
	controlSlider:setPosition(x,y)
	controlSlider:setMinimumValue(0)
	controlSlider:setMaximumValue(100)
	controlSlider:setMinimumAllowedValue(0)
	controlSlider:setMaximumAllowedValue(100)
	return controlSlider
end
return SetLayer