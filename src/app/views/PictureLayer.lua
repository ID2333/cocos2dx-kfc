local PictureLayer = class("PictureLayer",function()
	return cc.Scene:create()
end)

function PictureLayer:createScene()
	local scene = PictureLayer:new()
	scene:init()
	return scene
end

function PictureLayer:init()
	self.m_beforeSel = 0
	self.m_monsterPng = {}
	self.m_monsterLabel = {}

	local bg = display.newSprite("PhotoGalleryBackground.png", display.cx, display.cy)
	self:addChild(bg)

	local closeItem = createMenuItemSprite("GalleryOffNormal.png", "GalleryOffSelected.png", display.cx + 580, display.cy + 320,
	function()
		PlayEffectMusic()
		local scene = require("app.views.MainScene"):createScene()
		cc.Director:getInstance():replaceScene(scene)
	end)
	
	cc.Menu:create(closeItem)
	:setPosition(0,0)
	:addTo(bg)

	self.m_woodMonsterText = display.newSprite(spriteFrames:getSpriteFrame("Text.png"))
	self.m_woodMonsterText:setPosition(display.cx + 460, display.cy)
	self:addChild(self.m_woodMonsterText)

	self:createMonsterPic("ManWood.png", cc.p(display.cx + 50, display.cy), "木\n桩\n怪", cc.p(display.cx + 256, display.cy - 120), 1)
	self:createMonsterPic("ManLion.png", cc.p(display.cx + 50, display.cy), "狮\n子\n怪", cc.p(display.cx + 256, display.cy - 120), 2)
	self:createMonsterPic("ManStone.png", cc.p(display.cx + 50, display.cy), "石\n头\n怪", cc.p(display.cx + 256, display.cy - 120), 3)

	self.m_monsterPng[2]:setVisible(false)
	self.m_monsterLabel[2]:setVisible(false)
	self.m_monsterPng[3]:setVisible(false)
	self.m_monsterLabel[3]:setVisible(false)

	self.m_listView = ccui.ListView:create()
	self.m_listView:setDirection(SCROLLVIEW_DIR_VERTICAL)
	self.m_listView:setTouchEnabled(true)
	self.m_listView:setBounceEnabled(true)
	self.m_listView:setAnchorPoint(0,0)
	self.m_listView:setPosition(0,display.height / 4)
	self.m_listView:setContentSize(cc.size(445, 500))
	self.m_listView:ignoreContentAdaptWithSize(false)
	self.m_listView:addEventListener(function ()
		self:selectedItemEvent()
	end)
	bg:addChild(self.m_listView)

	local default_button = ccui.Button:create("Cell_0.png", "CellSel_0.png", "", UI_TEX_TYPE_PLIST)
	default_button:setName("Title Button")

	local default_item = ccui.Layout:create()
	default_item:setTouchEnabled(true)
	default_item:setContentSize(default_button:getContentSize())
	default_item:addChild(default_button)

	default_button:setPosition(default_item:getContentSize().width / 2, default_item:getContentSize().height / 2)
	self.m_listView:setItemModel(default_item)

	self:createLayout("CellSel_0.png", "Cell_0.png", "one Button", default_button:getContentSize() )
	self:createLayout("CellSel_1.png", "Cell_1.png", "two Button", default_button:getContentSize() )
	self:createLayout("CellSel_2.png", "Cell_2.png", "three Button", default_button:getContentSize() )
	self:createLayout("CellSel_3.png", "Cell_3.png", "four Button", default_button:getContentSize() )
end

function PictureLayer:createMonsterPic(monsterPng, monsterPngPos, monsterLabel, monsterLabelPos, index)
	if #self.m_monsterPng == 0 or index > #self.m_monsterPng then
		table.insert(self.m_monsterPng, display.newSprite(spriteFrames:getSpriteFrame(monsterPng) ) )
		index = #self.m_monsterPng
	else
		table.insert(self.m_monsterPng, index, display.newSprite(spriteFrames:getSpriteFrame(monsterPng) ) )
	end
	self.m_monsterPng[index]:setPosition(monsterPngPos)
	self:addChild(self.m_monsterPng[index])
	
	if #self.m_monsterLabel == 0 or index > #self.m_monsterLabel then
		table.insert(self.m_monsterLabel, cc.Label:createWithSystemFont(monsterLabel, "", 30) )
		index = #self.m_monsterLabel
	else
		table.insert(self.m_monsterLabel, index, cc.Label:createWithSystemFont(monsterLabel, "", 30) )
	end
	self.m_monsterLabel[index]:setPosition(monsterLabelPos)
	self.m_monsterLabel[index]:setColor(cc.c3b(0, 255,255))
	self:addChild(self.m_monsterLabel[index])
end

function PictureLayer:selectedItemEvent()
	for i=1,3 do
		self.m_monsterPng[i]:setVisible(false)
		self.m_monsterLabel[i]:setVisible(false)
	end
	self.m_woodMonsterText:setVisible(false)

	local index = self.m_listView:getCurSelectedIndex()
	if 0 == index then
		self.m_woodMonsterText:setVisible(true)
	end

	if index < 3 then
		self.m_monsterPng[index + 1]:setVisible(true)
		self.m_monsterLabel[index + 1]:setVisible(true)
	end
end

function PictureLayer:createLayout(normalPng, selectedPng, buttonName, buttonSize)
	local button = ccui.Button:create(normalPng, selectedPng, "", UI_TEX_TYPE_PLIST)
	button:setName(buttonName)
	button:setScale9Enabled(true)
	button:setContentSize(buttonSize)
	local item = ccui.Layout:create()
	item:setContentSize(button:getContentSize())
	button:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)
	item:addChild(button)

	self.m_listView:pushBackCustomItem(item)
end
return PictureLayer