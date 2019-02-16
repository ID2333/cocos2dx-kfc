local HelpLayer = class("HelpLayer",function ()
	return cc.Scene:create()
end)

function HelpLayer:createScene()
	local scene = HelpLayer:new()
	scene:init()
	return scene
end

function HelpLayer:init()
	display.newSprite("logo.png")
	:setPosition(display.cx, display.cy)
	:addTo(self)
	
	--创建关闭按钮
	local closeItem = createMenuItemSprite("GalleryOffNormal.png","GalleryOffSelected.png", display.cx + 580, display.cy + 320,
	function ()
		PlayEffectMusic()
		local scene = require("app.views.MainScene"):createScene()
		cc.Director:getInstance():replaceScene(scene)
	end)

	cc.Menu:create(closeItem)
	:setPosition(0,0)
	:addTo(self)
	
end

return HelpLayer