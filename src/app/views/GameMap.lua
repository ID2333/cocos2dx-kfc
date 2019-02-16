local GameMap = class("GameMap",function ()
	return cc.Node:create()
end)

import(".Config")
import(".Hero")

function GameMap:ctor()
	self.m_map = { }
end

function GameMap:initMap(mapName)
	for i = 1,#mapName do
		self.m_map[i] = display.newSprite(spriteFrames:getSpriteFrame(mapName[i]))
		self.m_map[i]:setAnchorPoint(cc.p(0,0))
	end

	self.m_parallax = cc.ParallaxNode:create()
	self.m_parallax:addChild(self.m_map[1], 1, cc.p(1.18,0), cc.p(0,360))
	self.m_parallax:addChild(self.m_map[2], 2, cc.p(1,0), cc.p(0,0))
	self.m_parallax:addChild(self.m_map[3], 3, cc.p(0.7,0), cc.p(0,0))

	self:setAnchorPoint(cc.p(0,0))
	self:addChild(self.m_parallax)
end

function GameMap:MoveMap(hero)
	if hero:JudgePosition(display.width,display.height) and hero.m_bHeroDirection == false then
		if hero:getPositionX() >= self.m_map[2]:getContentSize().width - display.width then
			self:setPosition(self:getPositionX() - hero.m_speed,self:getPositionY())
		end
	end

	if hero:JudgePosition(display.width,display.height) and hero.m_bHeroDirection == true then
		if self:getPositionX() <= -10 then
			self:setPosition(self:getPositionX() + hero.m_speed, self:getPositionY())
		end
	end
end

function GameMap:JudgeMap(hero)
	if self:getPositionX() >= -(self.m_map[2]:getContentSize().width - display.width) and hero.m_bHeroDirection == false then
		return false
	else 
		if self:getPositionX() <= -10 and hero.m_bHeroDirection == true then
			return false
		end
	end
	
	return true
end

return GameMap