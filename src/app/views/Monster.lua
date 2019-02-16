local Monster = class("Monster", function ()
	return cc.Node:create()
end)

function Monster:ctor()
	self.m_isRunning = false
	self.m_monsterDirection = true
	self.m_monsterName = nil
	self.m_isAttack = false
	self.m_hero = nil
	self.m_map = nil
	self.m_monsterA = nil
	self.m_monsterWalk = nil
	self.m_monsterDie = nil
	self.m_dieName = nil
	self.m_monsterSprite = nil
	self.m_HP = 0
	self.m_dis = 10000
	self.m_type = 0
	self.m_isHurt = false
	self.m_isDead = false
	self.m_hero = nil
	self.m_map = nil

	self.m_isOn = false
end

function Monster:initMonsterSprite(name,a,die,walk,dieLast,level)
	self.m_monsterName = name 
	self.m_monsterA = a
	self.m_monsterWalk = walk
	self.m_monsterDie = die
	self.m_dieName = dieLast

	self.m_HP = 100 * (1 + 0.3 * level)
	self.m_monsterSprite = display.newSprite(spriteFrames:getSpriteFrame(name))
	self:addChild(self.m_monsterSprite)
end

function Monster:setAnimation(name_each, runDirection, delay, loops)
	if self.m_monsterDirection ~= runDirection then
		self.m_monsterDirection = runDirection
		self.m_monsterSprite:setFlippedX(runDirection)
	end
	if self.m_isHurt or self.m_isAttack or self.m_isRunning or self.m_isDead then
		return
	end

	local action = require("app.views.ActionTool"):animationWithFrameName(name_each, -1, delay)
	self.m_monsterSprite:runAction(cc.RepeatForever:create(action))
	self.m_isRunning = true
end

function Monster:stopAnimation()
	if not self.m_isRunning then
		return
	end
	self:stopAllActionAndRestoreFrame(self.m_monsterName)
	self.m_isRunning = false
end

function Monster:stopAllActionAndRestoreFrame(name)
	self.m_monsterSprite:stopAllActions()
	self:removeChild(self.m_monsterSprite, true)
	self.m_monsterSprite = display.newSprite(spriteFrames:getSpriteFrame(name))
	self.m_monsterSprite:setFlippedX(self.m_monsterDirection)
	self:addChild(self.m_monsterSprite)
end

function Monster:AttackAnimation(name_each, runDirection, delay, loops)
	if self.m_isRunning or self.m_isAttack or self.m_isHurt or self.m_isDead then
		return 
	end

	self.m_isAttack = true
	local action = require("app.views.ActionTool"):animationWithFrameName(name_each, 1, delay)
	local callFunc = cc.CallFunc:create(function ()
		self:stopAllActionAndRestoreFrame(self.m_monsterName)
		self.m_isAttack = false
	end)

	self.m_monsterSprite:runAction(cc.Sequence:create(action,callFunc))
end

function Monster:hurtAnimation(name_each,runDirection,delay,loops)
	if self.m_isHurt or self.m_isDead then
		return
	end

	if self.m_isRunning or self.m_isAttack then
		self:stopAllActionAndRestoreFrame(self.m_monsterName)
		self.m_isRunning = false
		self.m_isAttack = false
	end

	local action = require("app.views.ActionTool"):animationWithFrameName(name_each, 1, delay)
	local callFunc = cc.CallFunc:create(function ()
		self:hurtEnd()
	end)
	self.m_monsterSprite:runAction(cc.Sequence:create(action,callFunc))
	self.m_isHurt = true
end

function Monster:hurtEnd()
	self.m_isHurt = false
	if self.m_hero.m_bCanCrazy then
		self.m_HP = self.m_HP - 100
	else
		self.m_HP = self.m_HP - 30
	end

	if self.m_HP <= 0 then
		self:deadAnimation(self.m_monsterDie, self.m_monsterDirection, 0.1, 1)
	end
end

function Monster:deadAnimation(name_each,runDirection,delay,loops)
	self.m_isDead = true

	local action = require("app.views.ActionTool"):animationWithFrameName(name_each, 1, delay)
	local callFunc = cc.CallFunc:create(function()
		self:deadEnd()
	end)
	self.m_monsterSprite:runAction(cc.Sequence:create(action,callFunc))

	if self.m_hero.m_CurrentMP < 100 then
		self.m_hero.m_CurrentMP = self.m_hero.m_CurrentMP + 50
		if self.m_hero.m_CurrentMP > 100 then
			self.m_hero.m_CurrentMP = 100
		end
	end
end

function Monster:deadEnd()
	self:stopAllActionAndRestoreFrame(self.m_dieName)
	local blink = cc.Blink:create(3,3)
	local callFunc = cc.CallFunc:create(function ()
		self:removeAllChildren()
	end)
	self.m_monsterSprite:runAction(cc.Sequence:create(blink,callFunc))
end

function Monster:followRun(hero,map)
	local x = hero:getPositionX() - (self:getPositionX() + map:getPositionX())
	self.m_dis = math.abs(x)

	if x > 1280 then
		return
	end

	if self.m_dis <= 120 then
		
		self:stopAnimation()
		self:performWithDealy(function()
			self:AttackAnimation(self.m_monsterA,self.m_monsterDirection,0.08,-1)
		end, 2.5)
		return
	end

	if x < -100 then
		self.m_monsterDirection = false
		self.m_monsterSprite:setFlippedX(self.m_monsterDirection)

		if self.m_isAttack then
			return
		end

		self:setAnimation(self.m_monsterWalk,self.m_monsterDirection,0.1,-1)
		self:setPosition(self:getPositionX() - 1.5, self:getPositionY())
	else
		if x > 100 then
			self.m_monsterDirection = true
			self.m_monsterSprite:setFlippedX(self.m_monsterDirection)

			if self.m_isAttack then
				return
			end

			self:setAnimation(self.m_monsterWalk,self.m_monsterDirection,0.1,-1)
			self:setPosition(self:getPositionX() + 1.5, self:getPositionY())
		end
	end
end

function Monster:startListen(hero,map)
	self.m_hero = hero
	self.m_map = map

	schedule(self,function ()
		self:updateMonster()
	end,1)
	self:scheduleUpdate(function()
		self:update()
	end)
end

function Monster:updateMonster()
	if self.m_isDead or self.m_hero.m_bIsDead then
		return
	end

	local x = self.m_hero:getPositionX() - (self:getPositionX() + self.m_map:getPositionX())
	self.m_dis = math.abs(x)
end

function Monster:update()
	if self.m_isDead or self.m_hero.m_bIsDead then
		return
	end

	if self.m_dis < 1280 and self.m_hero.m_bIsDead == false then
		self:followRun(self.m_hero,self.m_map)
	end
end

function Monster:performWithDealy(callback,delay)
	if self.m_isOn == false then
		self.m_isOn = true
		local delayTime = cc.DelayTime:create(delay)
		local callFunc = cc.CallFunc:create(callback)
		local callFuncEnd = cc.CallFunc:create(function ()
			self.m_isOn = false
		end)
		local action = cc.Sequence:create(delayTime,callFunc,callFuncEnd)
		self:runAction(action)
	end
end


return Monster