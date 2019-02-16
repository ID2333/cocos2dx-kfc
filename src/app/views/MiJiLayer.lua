local MiJiLayer = class("MiJiLayer",function ()
	return cc.Scene:create()
end)

function MiJiLayer:ctor()
	self.flag = true
end

function MiJiLayer:createScene()
	local scene = MiJiLayer:new()
	scene:init()
	return scene
end

function MiJiLayer:init()
	display.newSprite(spriteFrames:getSpriteFrame("CheatsBackground.png"), display.cx, display.cy)
	:addTo(self)

	local interface_1 = display.newSprite(spriteFrames:getSpriteFrame("CheatsInterface1.png"), display.cx, display.cy - 10)
	self:addChild(interface_1)
	local interface_2 = display.newSprite(spriteFrames:getSpriteFrame("CheatsInterface2.png"), display.cx, display.cy - 10)
	interface_2:setVisible(false)
	self:addChild(interface_2)

	local closeItem = createMenuItemSprite("OffNormal.png","OffSelected.png",display.width - 164, display.height - 132, 
	function()
		PlayEffectMusic()
		local scene = require("app.views.MainScene"):createScene()
		cc.Director:getInstance():replaceScene(scene)
	end)

	local nextRightItem = createMenuItemSprite("PageTurnNormal.png","PageTurnSelected.png", display.width - 55, display.cy - 14,
	function()
		PlayEffectMusic()
		if self.flag then
			interface_2:setVisible(true)
			self.flag = false
		else
			interface_2:setVisible(false)
			self.flag = true
		end
	end)

	local nextLeftItem = createMenuItemSprite("PageTurnNormal.png","PageTurnSelected.png", 55, display.cy - 14,
	function()
		PlayEffectMusic()
		if self.flag then
			interface_2:setVisible(true)
			self.flag = false
		else
			interface_2:setVisible(false)
			self.flag = true
		end
	end,true)

	cc.Menu:create(closeItem, nextRightItem, nextLeftItem)
	:setPosition(0,0)
	:addTo(self)
end

return MiJiLayer