local PauseLayer = class("PauseLayer",function ()
	return cc.Scene:create()
end)

import(".Config")

function PauseLayer:createScene(render)
	local scene = PauseLayer:new()
	scene:init(render)
	return scene
end

function PauseLayer:init(render)
	--背景
	local sprite = cc.Sprite:createWithTexture(render:getSprite():getTexture())
 	sprite:setPosition(display.cx,display.cy)
 	sprite:setFlippedY(true)
 	self:addChild(sprite)

	local spriteOn = cc.Sprite:createWithSpriteFrame(spriteFrames:getSpriteFrame("pauseBG1.png"))
	spriteOn:setPosition(display.cx,display.height + spriteOn:getContentSize().height / 2)
	self:addChild(spriteOn)
	local spriteDown = cc.Sprite:createWithSpriteFrame(spriteFrames:getSpriteFrame("pauseBG2.png"))
	spriteDown:setPosition(display.cx, -(spriteDown:getContentSize().height / 2) )
	self:addChild(spriteDown)
	
	local moveDown = cc.MoveBy:create(0.6, cc.p(0,-(spriteOn:getContentSize().height) ) )
	local moveUp = cc.MoveBy:create(0.6, cc.p(0, spriteDown:getContentSize().height) )
	spriteOn:runAction(moveDown)
	spriteDown:runAction(moveUp)
	--[[
	继续游戏按钮：  X：630.5 Y349.0
	声音按键：X：190.0  Y294.0
	重置键按钮：X346.0 Y：294.0
	返回关卡界面键按钮：X890.0 Y：294.0
	下一关键按钮：X1053.0 Y：294.0
	]]
	--继续游戏
	local resumeItem = createMenuItemSprite("playNormal.png","playSelected.png",spriteOn:getContentSize().width / 2 - 5, 110,function()
		PlayEffectMusic()
		local moveOn = cc.MoveBy:create(0.5, cc.p(0, spriteOn:getContentSize().height))
		local moveDown = cc.MoveBy:create(0.5, cc.p(0, -spriteDown:getContentSize().height))
		local replace = cc.CallFunc:create(function ()
			cc.Director:getInstance():popScene()
		end)

		local resume = cc.Sequence:create(moveOn,replace)
		spriteOn:runAction(resume)
		spriteDown:runAction(moveDown)
	end)

	--返回主界面
	local startItem = createMenuItemSprite("backNormal.png","backSelected.png",890,180,function()
		PlayEffectMusic()
		local scene = require("app.views.MainScene"):createScene()
		cc.Director:getInstance():replaceScene(scene)
	end)

	--重新开始游戏
	local againItem = createMenuItemSprite("againNormal.png","againSelected.png",346,180,function ()
		PlayEffectMusic()
		local scene = require("app.views.GameScene"):createScene()
		cc.Director:getInstance():replaceScene(scene)
	end)

	--下一关
	local nextItem = createMenuItemSprite("nextNormal.png","nextSelected.png",1053,180,function ()
		PlayEffectMusic()
		if g_iSelectGate < 3 then
			g_iSelectGate = g_iSelectGate + 1
			local scene = require("app.views.GameScene"):createScene()
			cc.Director:getInstance():replaceScene(scene)
		end
	end)

	--声音设置
	local musicOn = createMenuItemSprite("musicOn.png","musicOff.png")
	local musicOff = createMenuItemSprite("musicOff.png","musicSelected.png")

	self.musicToggle = cc.MenuItemToggle:create(musicOn)
	self.musicToggle:addSubItem(musicOff)
	self.musicToggle:setPosition(190.0,180.0)
	local function menuItemCallback()
		self:MusicSet()
	end
	self.musicToggle:registerScriptTapHandler(menuItemCallback)
	cc.Menu:create(resumeItem,startItem,againItem,nextItem,self.musicToggle):setPosition(0,0):addTo(spriteOn)
end

function PauseLayer:MusicSet()
	PlayEffectMusic()
	if XML:getBoolForKey(SOUND_KEY) then
		audioEngine:setEffectsVolume(XML:getFloatForKey(SOUNDVOL))
		audioEngine:playEffect("")
	end
	
	if self.musicToggle:getSelectedIndex() == 1 then
		audioEngine:pauseMusic()
	else
		audioEngine:setMusicVolume(XML:getFloatForKey(MUSICVOL))
		audioEngine:resumeMusic()
	end
end

return PauseLayer 