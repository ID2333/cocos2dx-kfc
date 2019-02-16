local Hero = class("Hero",function ()
	return cc.Node:create()
end)

function Hero:InitHeroSprite(heroName,level)
	self.m_bCanCrazy = false
	self.m_bIsAction = false
	self.m_bIsJumping = false
	self.m_bHeroDirection = false
	self.m_bIsRunning = false
	self.m_bIsAttack = false
	self.m_bIsHurt = false
	self.m_bIsDead = false

	self.m_CurrentMP = 0.0
	self.m_TotleMP = 100.0
	self.m_speed = 5

	self.m_HeroName = heroName
	self.m_TotleHP = 300 * level
	self.m_CurrentHP = self.m_TotleHP
	self.m_percentage = 100

	self.m_actionTool = require("app.views.ActionTool")
	self.m_HeroSprite = display.newSprite(spriteFrames:getSpriteFrame(heroName))
	self:addChild(self.m_HeroSprite)
end

--英雄脸朝向.左为true,右为false
function Hero:SetAnimation(frameName,delay,run_direction)
	if self.m_bHeroDirection ~= run_direction then
		self.m_bHeroDirection = run_direction
		self.m_HeroSprite:setFlippedX(run_direction)
	end
	if self.m_bIsRunning or self.m_bIsHurt or self.m_bIsAttack then
		return
	end
	local action = self.m_actionTool:animationWithFrameName(frameName, -1, delay)
	self.m_HeroSprite:runAction(cc.RepeatForever:create(action))
	self.m_bIsRunning = true
end

function Hero:StopAnimation()
	if not self.m_bIsRunning then
		return
	end
	self:StopAllActionAndRestoreFrame(self.m_HeroName)
	self.m_bIsRunning = false
end

function Hero:StopAllActionAndRestoreFrame(frameName)
	self.m_HeroSprite:stopAllActions()
	self:removeChild(self.m_HeroSprite, true)
	self.m_HeroSprite = display.newSprite(spriteFrames:getSpriteFrame(frameName))
	self.m_HeroSprite:setFlippedX(self.m_bHeroDirection)
	self:addChild(self.m_HeroSprite)
end

function Hero:JumpUpAnimation(nameEach,delay,runDirection)
	if self.m_bHeroDirection ~= runDirection then
		self.m_bHeroDirection = runDirection
		self.m_HeroSprite:setFlippedX(runDirection)
	end

	if self.m_bIsHurt or self.m_bIsAttack or self.m_bIsDead then
		return
	end

	local action = self.m_actionTool:animationWithFrameName(nameEach, -1, delay)
	self.m_HeroSprite:runAction(action)
	self.m_bIsJumping = true
end

function Hero:JumpDownAnimation(nameEach,delay,runDirection)
	if self.m_bHeroDirection ~= runDirection then
		self.m_bHeroDirection = runDirection
		self.m_HeroSprite:setFlippedX(runDirection)
	end

	if self.m_bIsHurt or self.m_bIsAttack then
		return
	end

	local action = self.m_actionTool:animationWithFrameName(nameEach, -1, delay)
	self.m_HeroSprite:runAction(action)
	self.m_bIsJumping = true
end

function Hero:AttackAnimation(nameEach,delay,runDirection)
	if self.m_bHeroDirection ~= runDirection then
		self.m_bHeroDirection = runDirection
		self.m_HeroSprite:setFlippedX(self.m_bHeroDirection)
	end

	if self.m_bIsJumping or self.m_bIsAttack then
		return;
	end

	local action = self.m_actionTool:animationWithFrameName(nameEach, 1, delay)
	local callFunc = cc.CallFunc:create(function ()
			self:AttackEnd()
		end)
	self.m_bIsAttack = true
	self.m_HeroSprite:runAction(cc.Sequence:create(action,callFunc))
end

function Hero:JumpEnd()
	self:StopAllActionAndRestoreFrame(self.m_HeroName)
	self.m_bIsJumping = false
end

function Hero:AttackEnd()
	self.m_HeroSprite:setFlippedX(self.m_bHeroDirection)
	self.m_bIsAttack = false
	if self.m_bCanCrazy then
		self.m_bCanCrazy = false
		self.m_CurrentMP = 0
	end
end

function Hero:HurtByMonsterAnimation(nameEach,delay,runDirection)
	if self.m_bIsHurt or self.m_bIsDead then
		return
	end

	if self.m_bIsRunning or self.m_bIsAttack then
		self:StopAllActionAndRestoreFrame(m_HeroName)

		self.m_bIsRunning = false
		self.m_bIsAttack = false
	end

	local action = self.m_actionTool:animationWithFrameName(nameEach, 1, delay)
	local callFunc = cc.CallFunc:create(function ()
			self:HurtByMonsterEnd()
		end)
	self.m_bIsHurt = true
	self.m_HeroSprite:runAction(cc.Sequence:create(action,callFunc))
end

function Hero:HurtByMonsterEnd()
	self.m_CurrentHP = self.m_CurrentHP - 20
	self.m_bIsHurt = false
	self.m_percentage = self.m_CurrentHP / self.m_TotleHP * 100
	if self.m_CurrentHP < 0 then
		self:DeadAnimation("dead",0,self.m_bHeroDirection)
	end
end

function Hero:DeadAnimation(nameEach,delay,runDirection)
	self.m_HeroSprite:stopAllActions()
	if self.m_bHeroDirection ~= runDirection then
		self.m_bHeroDirection = runDirection
		self.m_HeroSprite:setFlippedX(runDirection)
	end

	local action = self.m_actionTool:animationWithFrameName(nameEach, 1, delay)
	local callFunc = cc.CallFunc:create(function ()
			self:DeadEnd()
		end)
	self.m_HeroSprite:runAction(cc.Sequence:create(action,delay,callFunc))
	--cc.Director:getInstance():getScheduler():setTimeScale(0.5)
end

function Hero:DeadEnd()
	self.m_bIsDead = true
	self:StopAllActionAndRestoreFrame("monsterDie6.png")
end


function Hero:JudgePosition(width)
	if self:getPositionX() > (width /2 + 2) or self:getPositionX() < (width /2 - 2) then
		return false
	else
		return true
	end
end

return Hero