local MonsterOne = class("MonsterOne",function ()
	return cc.Node:create()
end)

import(".Config")
function MonsterOne:initMonster(hero,map)
	self.m_map = map
	self.m_hero = hero
	print("MonsterOne",hero.m_bIsDead)
	g_monsterOneList = {}
	g_monsterTwoList = {}
	g_monsterThreeList = {}
	g_monsterShowList = {}

	local monster1 = require("app.views.Monster"):new()
	monster1:initMonsterSprite("monsterWalk5.png","monsterA","monsterDie","monsterWalk","monsterDie6.png",1)
	monster1.m_type = 1
	monster1:setVisible(true)
	monster1:setPosition(1100,365)
	self.m_map:addChild(monster1)
	monster1:startListen(self.m_hero,self.m_map)
	table.insert(g_monsterShowList, monster1)
	g_flag1 = false

	local monster2 = require("app.views.Monster"):new()
	monster2:initMonsterSprite("monsterWalk5.png", "monsterA", "monsterDie", "monsterWalk", "monsterDie6.png", 1)
	monster2.m_type = 1
	monster2:setVisible(false)
	monster2:setPosition(2000,365)
	self.m_map:addChild(monster2)
	table.insert(g_monsterTwoList, monster2)

	local monster3 = require("app.views.Monster"):new()
	monster3:initMonsterSprite("monsterWalk5.png", "monsterA", "monsterDie", "monsterWalk", "monsterDie6.png", 1)
	monster3.m_type = 1
	monster3:setVisible(false)
	monster3:setPosition(-150,365)
	self.m_map:addChild(monster3)
	table.insert(g_monsterTwoList, monster3)
	g_flag2 = true

	--第三波
	for i=1,3 do
		local monster = require("app.views.Monster"):new()
		monster:initMonsterSprite("monsterWalk5.png", "monsterA", "monsterDie", "monsterWalk", "monsterDie6.png", 1)
		monster.m_type = 1
		if i == 1 or i == 2 then
			monster:setPosition(-100 * i,365)
		else
			monster:setPosition(2000,365)
		end
		monster:setVisible(false)
		self.m_map:addChild(monster)
		table.insert(g_monsterThreeList, monster)
	end
	g_flag3 = true

	self:scheduleUpdate(function ()
		self:updateMonster()
	end)
end

function MonsterOne:updateMonster()
	if g_flag1 == false and g_flag2 == true then
		local noMonster = true
		for i = 1,#g_monsterShowList do
			if not g_monsterShowList[i].m_isDead then
				noMonster = false
			end
		end

		if noMonster then
			performWithDelay(self,function() 
				self:showSecMon()
			end, 4)
		end
	end

	if g_flag2 == false and g_flag3 == true then
		local noMonster = true

		for i = 1,#g_monsterShowList do
			if not g_monsterShowList[i].m_isDead then
				noMonster = false
			end
		end

		if noMonster then
			performWithDelay(self,function() 
				self:showThrMon()
			end, 3)
		end
	end
end

function MonsterOne:showSecMon()
	for i,monster in ipairs(g_monsterTwoList) do
		monster:setVisible(true)
		monster:startListen(self.m_hero,self.m_map)
		table.insert(g_monsterShowList,monster)
	end
	g_flag2 = false
end

function MonsterOne:showThrMon()
	for i = 1,#g_monsterThreeList do
		g_monsterThreeList[i]:setVisible(true)
		g_monsterThreeList[i]:startListen(self.m_hero,self.m_map)
		table.insert(g_monsterShowList,g_monsterThreeList[i])
	end
	g_flag3 = false
end

function MonsterOne:createWithMapAndHero(hero,map)
	local monsterOne = MonsterOne:new()
	monsterOne:initMonster(hero,map)
	return monsterOne
end

return MonsterOne
