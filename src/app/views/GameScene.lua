local GameScene = class("GameScene",function ()
	return cc.Scene:create()
end)

function GameScene:ctor()
	self.m_velocity = 10.0
	self.m_bDirection = false
	self.m_bRun = false
	self.m_bJump = false
	self.m_HPBar = nil
	self.m_MPBar = nil
end

function GameScene:createScene()
	local scene = GameScene:new()
	scene:init()
	return scene	
end

function GameScene:init()
	--加载音乐
	self:loadMusic("Sound/GameBGM.wav")

	--加载资源
	spriteFrames:addSpriteFrames("pnglist/mapBefore.plist")
	spriteFrames:addSpriteFrames("pnglist/mapRoad.plist")

	--初始化
	local bgName = string.format("#bgmap%d.png", g_iSelectGate)
	local midName = string.format("MapMiddle%d.png",g_iSelectGate)
	local groundName = string.format("MapGround%d.png",g_iSelectGate)
	local beforeName = string.format("MapBefore%d.png",g_iSelectGate)
	local comboName = string.format("comboBtn%d.png",g_iSelectGate)

	self:showUI(bgName,midName,groundName,beforeName,comboName)

	--英雄
	self.m_hero = require("app.views.Hero").new()
	self.m_hero:InitHeroSprite("idle.png",1)
	self.m_hero:setPosition(100,360)
	self:addChild(self.m_hero)

	--怪物
	local monster = require("app.views.MonsterOne"):createWithMapAndHero(self.m_hero, self.m_map)
	self:addChild(monster)

	self.m_update = self:scheduleUpdate(function (dt)
		self:update(dt)
	end)
end

function GameScene:loadMusic(music)
	if(XML:getBoolForKey(MUSIC_KEY)) then
		musicVolume = XML:getFloatForKey(MUSICVOL) * 100
		audioEngine:setMusicVolume(musicVolume)

		if(audioEngine:isMusicPlaying()) then
			audioEngine:pauseMusic()
		end
		audioEngine:playMusic(music, true)
	else
		audioEngine:pauseMusic()
	end
end

function GameScene:showUI(bgName,midName,groundName,beforeName,comboName)
	--地图背景
	display.newSprite(bgName)
	:setPosition(display.cx,display.cy)
	:addTo(self)

	self.m_map = require("app.views.GameMap"):new()
	self.m_map:initMap({midName,groundName,beforeName})
	self:addChild(self.m_map)

	--创建动作按钮,如拳,脚,跳等动作按钮
	self:createActionButton("quan.png","fist.png",cc.p(display.width - 230, 76), "fist")
	self:createActionButton("jiao.png","foot.png",cc.p(display.width - 73, 76), "foot")
	self:createActionButton("tiao.png","jump.png",cc.p(display.width - 60, 220), "jump")
	self:createActionButton("tiao.png",comboName,cc.p(display.width - 387, 76), "combo")

	--创建暂停按钮
	local pauseGameItem = createMenuItemSprite("pauseNormal.png", "pauseSelected.png", display.width - 50, display.height - 48,
		function()
			self:GamePause()
		end)
	cc.Menu:create(pauseGameItem):setPosition(0,0):addTo(self)

	--创建行走按钮,主要是向前走和向后走
	self:createMoveButton("directionNormal.png","directionSelected.png",cc.p(117,70),"backward")
	self:createMoveButton("directForNor.png","directForSel.png",cc.p(304,70),"forward")

	--状态栏
	local stateBG = display.newSprite(spriteFrames:getSpriteFrame("barGround.png"))
	stateBG:setPosition(cc.p(260,display.height - 60))
	self:addChild(stateBG,2,10)
	--HP和MP进度条
	self:createProgressTimer(stateBG, "HPBar.png", cc.PROGRESS_TIMER_TYPE_BAR, cc.p(0,0.5), cc.p(1,0), 100, cc.p(240,45))
	self:createProgressTimer(stateBG, "MPBar.png", cc.PROGRESS_TIMER_TYPE_BAR, cc.p(0,0.5), cc.p(1,0), 100, cc.p(226,30))
end

function GameScene:createProgressTimer(stateBg,png,Type,MidPoint,ChangeRate,Percentage,pos)
	if png == "HPBar.png" then
		self.m_HPBar = cc.ProgressTimer:create(display.newSprite(spriteFrames:getSpriteFrame(png)))
		self.m_HPBar:setType(Type)
		self.m_HPBar:setMidpoint(MidPoint)
		self.m_HPBar:setBarChangeRate(ChangeRate)
		self.m_HPBar:setPercentage(Percentage)
		self.m_HPBar:setPosition(pos)
		stateBg:addChild(self.m_HPBar)
	end
	if png == "MPBar.png" then
		self.m_MPBar = cc.ProgressTimer:create(display.newSprite(spriteFrames:getSpriteFrame(png)))
		self.m_MPBar:setType(Type)
		self.m_MPBar:setMidpoint(MidPoint)
		self.m_MPBar:setBarChangeRate(ChangeRate)
		self.m_MPBar:setPercentage(Percentage)
		self.m_MPBar:setPosition(pos)
		stateBg:addChild(self.m_MPBar)
	end
end

function GameScene:createActionButton(buttonBg,buttonPng,buttonPos,Buttontype)
	--背景框
	local bg = display.newSprite(spriteFrames:getSpriteFrame(buttonBg))
	bg:setPosition(buttonPos)
	
	--按钮回调
	local function callBack()
		self:Attack(Buttontype)
	end

	--按钮添加到背景框
	local btnPic = ccui.Scale9Sprite:createWithSpriteFrame(spriteFrames:getSpriteFrame(buttonPng))
	local bgSize = bg:getContentSize()
	local btn = cc.ControlButton:create(btnPic)
	btn:registerControlEventHandler(callBack,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
	btn:setPosition(bgSize.width / 2, bgSize.height / 2)
	if Buttontype == "combo" then
		self:addChild(bg,11,11)
		bg:addChild(btn, 3, 15)
	else
		self:addChild(bg)
		bg:addChild(btn)
	end
end

function GameScene:createMoveButton(normalPng,selectedPng,pos,direction)
	local function TouchDown()
		if direction == "backward" then
			self:backward(1)
		end
		if direction == "forward" then
			self:forward(1)
		end
	end
	local function DragOutSide()
		if direction == "backward" then
			self:backward(2)
		end
		if direction == "forward" then
			self:forward(2)
		end
	end
	local function UpInside()
		if direction == "backward" then
			self:backward(3)
		end
		if direction == "forward" then
			self:forward(3)
		end
	end
	local backwardBG = ccui.Scale9Sprite:createWithSpriteFrame(spriteFrames:getSpriteFrame(normalPng))
	local backwardSelBG = ccui.Scale9Sprite:createWithSpriteFrame(spriteFrames:getSpriteFrame(selectedPng))
	local backwardBtn = cc.ControlButton:create(backwardBG)
	backwardBtn:setBackgroundSpriteForState(backwardSelBG, cc.CONTROL_STATE_HIGH_LIGHTED)
	backwardBtn:setZoomOnTouchDown(false)
	backwardBtn:setPosition(pos)
	backwardBtn:registerControlEventHandler(TouchDown,cc.CONTROL_EVENTTYPE_TOUCH_DOWN)
	backwardBtn:registerControlEventHandler(DragOutSide,cc.CONTROL_EVENTTYPE_DRAG_OUTSIDE)
	backwardBtn:registerControlEventHandler(UpInside,cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
	self:addChild(backwardBtn)
end

function GameScene:Attack(Buttontype)
	if self.m_hero.m_bIsRunning or self.m_hero.m_bIsAttack or self.m_hero.m_bIsHurt or self.m_hero.m_bIsJumping or self.m_bJump then
		return
	end
	if "fist" == Buttontype then
		print("fist")
		PlayEffectMusic()
		self.m_hero:AttackAnimation("fist", 0.1, self.m_bDirection)
	end
	if "foot" == Buttontype then
		print("foot")
		PlayEffectMusic()
		self.m_hero:AttackAnimation("leg", 0.1, self.m_bDirection)
	end
	if "jump" == Buttontype then
		print("jump")
		PlayEffectMusic("Jump.wav")
		self.m_bJump = true
	end
	if "combo" == Buttontype then
		if self.m_hero.m_bCanCrazy then
			return
		end
		PlayEffectMusic("combo.wav")
		self.m_hero.m_bCanCrazy = true
		if 1 == g_iSelectGate then
			self.m_hero:AttackAnimation("combo", 0.1, self.m_bDirection)
		end
		if 2 == g_iSelectGate then
			self.m_hero:AttackAnimation("bakandao",0.1,self.m_bDirection)
		end
		if 3 == g_iSelectGate then
			self.m_hero:AttackAnimation("gun", 0.1, m_bDirection)
		end
		print("combo")

	end
end

function GameScene:GamePause()
	local render = cc.RenderTexture:create(display.width, display.height)
	render:begin()

	cc.Director:getInstance():getRunningScene():visit()

	render:endToLua()
	render:retain()
	
	local scene = require("app.views.PauseLayer"):createScene(render)
	cc.Director:getInstance():pushScene(scene)
end

function GameScene:backward(Type)
	print("touch backward:",Type)
	if self.m_hero.m_bIsAttack and self.m_hero.m_bIsJumping then
		return 
	end
	if Type == 1 then
		self.m_bRun = true
		self.m_bDirection = true
	end
	if Type == 2 then
		self.m_bRun = false
		self.m_hero:StopAnimation()
	end 
	if Type == 3 then
		self.m_bRun = false
		self.m_hero:StopAnimation()
	end
end

function GameScene:forward(Type)
	print("touch forward:",Type)
	if self.m_hero.m_bIsAttack and self.m_hero.m_bIsJumping then
		return 
	end
	if Type == 1 then
		self.m_bRun = true
		self.m_bDirection = false
	end
	if Type == 2 then
		self.m_bRun = false
		self.m_hero:StopAnimation()
	end 
	if Type == 3 then
		self.m_bRun = false
		self.m_hero:StopAnimation()
	end
end

function GameScene:getVelocity()
	self.m_velocity = self.m_velocity - 0.3
	return self.m_velocity
end

function GameScene:update(dt)
	self:heroJump()
	self:heroMove()
	self:heroSkillCollision()
	self:showHeroComboPic()
	self:heroCollision()
	self:monsterCollision()

	if self.m_hero.m_bIsDead then
		performWithDelay(self,function ()
			self:gameVictoryOrOver(false)
		end, 3)
		self:unscheduleUpdate()
	end

	if g_flag3 == false then
		local noMonster = true
		for i,monster in ipairs(g_monsterShowList) do
			
			if monster.m_isDead == false then
				noMonster = false
			end
		end

		if noMonster then
			performWithDelay(self,function ()
				self:gameVictoryOrOver(true)
			end, 2)
			self:unscheduleUpdate()
		end
	end
end

function GameScene:heroJump()
	if self.m_bJump then
		local x = self.m_hero:getPositionX()
		local y = self.m_hero:getPositionY()
		local moveX = x - self.m_hero.m_speed
		if not self.m_bDirection then
			moveX = x + self.m_hero.m_speed
		end

		self:getVelocity()
		if self.m_velocity >= 0.1 then
			self.m_hero:JumpDownAnimation("jumpup", 0.1, self.m_bDirection)
		else
			self.m_hero:JumpDownAnimation("jumpdown",0.1,self.m_bDirection)
		end
		--超出边界
		if (self.m_bDirection and  x < 8) or (not self.m_bDirection and x > display.width - 8) then
			self.m_hero:setPosition(x,y + self.m_velocity)
		else
			if not self.m_hero:JudgePosition(display.width) or self.m_map:JudgeMap(self.m_hero) then
				self.m_hero:setPosition(moveX,y + self.m_velocity)
			else
				self.m_hero:setPosition(x,y + self.m_velocity)
			end
			self.m_map:MoveMap(self.m_hero)
		end

		if self.m_hero:getPositionY() <= 359 then
			self.m_hero:JumpEnd()
			self.m_hero:setPositionY(360)
			self.m_velocity = 10
			self.m_bJump = false
		end
	end
end

function GameScene:heroMove()
	local x = self.m_hero:getPositionX()
	local y = self.m_hero:getPositionY()
	
	if self.m_bRun and not self.m_bDirection and not self.m_hero.m_bIsHurt and not self.m_hero.m_bIsAttack and not self.m_hero.m_bIsJumping then
		self.m_hero:SetAnimation("run", 0.07, self.m_bDirection)

		if x <= display.width - 8 then
			if not self.m_hero:JudgePosition(display.width) or self.m_map:JudgeMap(self.m_hero) then
				self.m_hero:setPosition(x + self.m_hero.m_speed,y)
			end
			self.m_map:MoveMap(self.m_hero)
		end
	else
		if self.m_bRun and self.m_bDirection and not self.m_hero.m_bIsHurt and not self.m_hero.m_bIsJumping then
			self.m_hero:SetAnimation("run", 0.07, self.m_bDirection)

			if x >= 8 then
				if not self.m_hero:JudgePosition(display.width) or self.m_map:JudgeMap(self.m_hero) then
					self.m_hero:setPosition(x - self.m_hero.m_speed,y)
				end
			end
			self.m_map:MoveMap(self.m_hero)
		end
	end		
end

function GameScene:showHeroComboPic()
	local node = self:getChildByTag(10)
	local btnNode = self:getChildByTag(11)
	local comboBtn = btnNode:getChildByTag(15)

	self.m_MPBar:setPercentage(self.m_hero.m_CurrentMP)
	if self.m_MPBar:getPercentage() >= 100 then
		comboBtn:setColor(cc.c3b(255,255,255))
		comboBtn:setEnabled(true)
	else
		comboBtn:setEnabled(false)
		comboBtn:setColor(cc.c3b(120,120,120))
	end
end

function GameScene:isAttackMonster(hero,monster)
	local heroX = hero:getPositionX()
	local monsterX = monster:getPositionX() + self.m_map:getPositionX()

	if hero.m_bHeroDirection then
		if monsterX < heroX then
			return true
		end
	else
		if monsterX > heroX then
			return true
		end
	end

	return false
end

function GameScene:heroCollision()
	if self.m_hero.m_bIsAttack then

		for i = 1, #g_monsterShowList do

			if not g_monsterShowList[i].m_isDead and self:isAttackMonster(self.m_hero,g_monsterShowList[i]) and 
			not self.m_hero.m_bIsJumping then

				local x = self.m_hero:getPositionX() - (g_monsterShowList[i]:getPositionX() + self.m_map:getPositionX())
				local dis = math.abs(x)
			
				if dis <= 150 then
					if g_monsterShowList[i].m_type == 1 then
						g_monsterShowList[i]:hurtAnimation("monsterHurt", g_monsterShowList[i].m_monsterDirection, 0.2, 1)
					end
					if g_monsterShowList[i].m_type == 2 then
						g_monsterShowList[i]:hurtAnimation("lionHurt", g_monsterShowList[i].m_monsterDirection, 0.2, 1)
					end
					if g_monsterShowList[i].m_type == 3 then
						g_monsterShowList[i]:hurtAnimation("stoneHurt", g_monsterShowList[i].m_monsterDirection, 0.2, 1)
					end
				end
 			end
		end
	end
end

function GameScene:monsterCollision()
	for i = 1,#g_monsterShowList do
		local monster = g_monsterShowList[i]

		if not monster.m_isDead then
			if monster.m_isAttack and not self.m_hero.m_bIsDead and not self.m_hero.m_bIsJumping then
				local x = self.m_hero:getPositionX() - (monster:getPositionX() + self.m_map:getPositionX())
				local dis = math.abs(x)

				if dis <= 130 then
					self.m_hero:HurtByMonsterAnimation("hurt", 0.2, self.m_bDirection)
					self.m_HPBar:setPercentage(self.m_hero.m_percentage)
				end
			end
		end
	end
end

function GameScene:heroSkillCollision()
	if self.m_hero.m_bIsAttack and self.m_hero.m_bCanCrazy then

		for i = 1,#g_monsterShowList do
			local monster = g_monsterShowList[i]

			if not monster.m_isDead and self:isAttackMonster(self.m_hero, monster) and not self.m_hero.m_bIsJumping then
				local x = self.m_hero:getPositionX() - (monster:getPositionX() + self.m_map:getPositionX())
				local dis = math.abs(x)

				if dis <= 350 then
					monster:hurtAnimation("monsterHurt", monster.m_monsterDirection, 0.2, 1)
				end
			end
		end
	end
end

function GameScene:gameVictoryOrOver(isVictory)
	self:loadMusic("Sound/victory.wav")
	local png1 = "faliure.png"
	local png2 = "tili.png"
	if isVictory == true then
		if g_iSelectGate == 1 then
			XML:setBoolForKey(GATEONE, true)
		end
		if g_iSelectGate == 2 then
			XML:setBoolForKey(GATETWO, true)
		end
		if g_iSelectGate == 3 then
			XML:setBoolForKey(GATETHREE, true)
		end
		png1 = "victory.png"
		png2 = "jinbi.png"
	end
	--弹出游戏结束界面
	local bgSprite = display.newSprite(spriteFrames:getSpriteFrame("heiping.png"))
	bgSprite:setPosition(display.cx,display.cy)
	self:addChild(bgSprite)

	display.newSprite(spriteFrames:getSpriteFrame("bgTitle.png"))
	:setPosition(display.cx + 23, display.cy + 17)
	:addTo(bgSprite)

	display.newSprite(spriteFrames:getSpriteFrame(png1))
	:setPosition(display.cx, display.cy + 227)
	:addTo(bgSprite)

	display.newSprite(spriteFrames:getSpriteFrame("tili.png"))
	:setPosition(display.cx, display.cy - 23)
	:addTo(bgSprite)

	display.newSprite(spriteFrames:getSpriteFrame(png2))
	:setPosition(display.cx, display.cy - 27)
	:addTo(bgSprite)

	display.newSprite(spriteFrames:getSpriteFrame("tipsNext.png"))
	:setPosition(display.cx, display.cy - 227)
	:addTo(bgSprite)

	local function onTouchBegan(touch, event)
		local scene = require("app.views.MapLayer"):createScene()
		cc.Director:getInstance():replaceScene(scene)
		return false
	end
	local disPatcher = self:getEventDispatcher()

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	disPatcher:addEventListenerWithSceneGraphPriority(listener, self)

end
return GameScene