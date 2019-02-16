local SelectGate = class("SelectGate",function()
	return cc.Layer:create()
end)

--菜单缩小比例
local MENU_SCALE = 0.3
--菜单倾斜角度
local MENU_ASLOPE = 60
--calcFunction(x)为 x/(x+a) a为常数
local CALC_A = 1
--动画运行时间
local ANIMATION_DURATION = 0.3
--菜单项大小与屏幕的比例
local CONTENT_SIZE_SCALE = 2.0 / 3.0
--菜单项长度与菜单长度的比例,滑动一个菜单项的长度,菜单项变化一下
local ITEM_SIZE_SCALE = 1.0 / 4

function SelectGate:ctor()
	self.m_index = 1
	self.m_lastIndex = 1
	self.m_selectedItem = nil
	self.m_items = { }

	local winSize = cc.Director:getInstance():getWinSize()
	self:ignoreAnchorPointForPosition(false)
	self:setContentSize(winSize.width * CONTENT_SIZE_SCALE,winSize.height * CONTENT_SIZE_SCALE)
	self:setAnchorPoint(cc.p(0.5,0.5))

	local function onTouchBegan(touch, event)
		if self:TouchBegan(touch,event) then
			return true
		end
		return false
	end

	local function onTouchMoved(touch, event)
		self:TouchMoved(touch,event)
		return
	end

	local function onTouchEnded(touch, event)
		self:TouchEnded(touch,event)
		return
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function SelectGate:addMenuItem(item)
	item:setPosition(self:getContentSize().width / 2,self:getContentSize().height / 2)
	self:addChild(item)
	table.insert(self.m_items,item)
	self:reset()

	self:updatePositionWithAnimation()
end

function SelectGate:updatePosition()
	local menuSize = self:getContentSize()
	for i=1,#self.m_items do
		local x = self:calcFunction(i - self.m_index,menuSize.width / 2)
		self.m_items[i]:setPosition(cc.p(menuSize.width / 2 + x, menuSize.height / 2))
		--设置绘制顺序
		self.m_items[i]:setLocalZOrder(-math.abs( (i - self.m_index) * 100) )
		--设置伸缩比例
		self.m_items[i]:setScale(1.0 - math.abs(self:calcFunction(i - self.m_index, MENU_SCALE)))
		--设置倾斜
		local orbit = cc.OrbitCamera:create(0,
		 	1,
		  	0,
		   	self:calcFunction(i - self.m_lastIndex, MENU_ASLOPE),
		    self:calcFunction(i - self.m_lastIndex, MENU_ASLOPE) - self:calcFunction(i - self.m_index, MENU_ASLOPE),
		    0, 
		    0
		)
		self.m_items[i]:runAction(orbit)
	end
end

function SelectGate:updatePositionWithAnimation()
	--停止所有动作
	for i = 1, #self.m_items do
		self.m_items[i]:stopAllActions()
	end

	local menuSize = self:getContentSize()
	for i = 1, #self.m_items do

		self.m_items[i]:setLocalZOrder(-math.abs((i - self.m_index) * 100))
		local x = self:calcFunction(i - self.m_index,menuSize.width / 2)
		local moveTo = cc.MoveTo:create(ANIMATION_DURATION, cc.p(menuSize.width / 2 + x,menuSize.height / 2))
		self.m_items[i]:runAction(moveTo)

		local scaleTo = cc.ScaleTo:create(ANIMATION_DURATION,(1 - math.abs(self:calcFunction(i - self.m_index,MENU_SCALE))))
		self.m_items[i]:runAction(scaleTo)

		local orbit = cc.OrbitCamera:create(ANIMATION_DURATION,
			1,
			0,
			self:calcFunction(i - self.m_lastIndex,MENU_ASLOPE),
		    self:calcFunction(i - self.m_index,MENU_ASLOPE) - self:calcFunction(i - self.m_lastIndex,MENU_ASLOPE),
		    0,
		    0
		)
		self.m_items[i]:runAction(orbit)
	end
	performWithDelay(self,function() 
		self:actionEndCallBack()
	end, ANIMATION_DURATION)
end

function SelectGate:actionEndCallBack()
	self.m_selectedItem = self:getCurrentItem()
	if self.m_selectedItem then
		self.m_selectedItem:selected()
	end
end

function SelectGate:getCurrentItem()
	if #self.m_items == 0 then
		return nil
	end
	return self.m_items[self.m_index]
end

function SelectGate:reset()
	self.m_lastIndex = 1
	self.m_index = 1
end

function SelectGate:setIndex(index)
	self.m_lastIndex = self.m_index
	self.m_index = index
end

function SelectGate:rectify(forward)
	local index = self.m_index
	if index < 1 then 
		index = 1
	end
	if index > #self.m_items then
		index = #self.m_items
	end	
	
	if forward then
		index = math.floor(index + 0.4)
	else
		index = math.floor(index + 0.6)
	end
	self:setIndex(math.floor(index))
end

function SelectGate:calcFunction(index,width)
	return width * index / (index + CALC_A)
end

function SelectGate:TouchBegan(touch, event)
	print("TouchBegan")
	for i=1,#self.m_items do
		self.m_items[i]:stopAllActions()
	end
	
	if self.m_selectedItem then
		self.m_selectedItem:unselected()
	end

	local pos = self:convertToNodeSpace(touch:getLocation())
	local size = self:getContentSize()
	local rect = cc.rect(0,0,size.width,size.height)

	if cc.rectContainsPoint(rect,pos) then
		return true
	end
	return false
end

function SelectGate:TouchMoved(touch, event)
	print("TouchMoved")
	local size = self:getContentSize()
	local xDelta = touch:getDelta().x
	self.m_lastIndex = self.m_index
	self.m_index = self.m_index - xDelta / (size.width * ITEM_SIZE_SCALE)
	self:updatePosition()
end

function SelectGate:TouchEnded(touch, event)
	print("TouchEnded")
	local size = self:getContentSize()
	local xDelta = touch:getLocation().x - touch:getStartLocation().x
	self:rectify(xDelta > 0)
	if math.abs(xDelta) < size.width / 24 and self.m_selectedItem then
		self.m_selectedItem:activate()
	end
	self:updatePositionWithAnimation()
end
return SelectGate