XML = cc.UserDefault:getInstance()
audioEngine = cc.SimpleAudioEngine:getInstance()
spriteFrames = cc.SpriteFrameCache:getInstance()

--全局变量
g_iSelectGate = 0
g_monsterOneList = {}
g_monsterTwoList = {}
g_monsterThreeList = {}
g_monsterShowList = {}

g_flag1 = false
g_flag2 = false
g_flag3 = false
g_flag4 = false
g_flag5 = false

SOUND_KEY        =   "soundClose"            -- 背景音效
MUSIC_KEY        =   "musicClose"            -- 背景音乐
SOUNDVOL         =   "soundVolume"           -- 音效音量
MUSICVOL         =   "musicVolume"           -- 音乐音量
EXP_KEY          =   "heroCurrentExp"        -- 英雄当前经验
GAMELEVEL_KEY    =   "gameLevel"             -- 当前关卡
HEROLEVEL_KEY    =   "heroLevel"             -- 当前等级
HEROCOIN_KEY     =   "heroCoin"              -- 英雄金币
HEROENERGY_KEY   =   "heroEnergy"            -- 英雄体力
HEROHP_KEY       =   "heroHP"                -- 英雄血量
HEROMP_KEY       =   "heroMP"                -- 英雄能量
HEROAPOWER_KEY   =   "heroAPower"            -- 英雄普攻伤害
HEROABILITY_KEY  =   "heroAbility"           -- 英雄能力等级
SELECTGATE       =   "selectGate"            -- 选择的关卡
GATEONE          =   "gateOne"               -- 第一关
GATETWO          =   "gateTwo"               -- 第二关
GATETHREE        =   "gateThree"             -- 第三关
GAMEOVER         =   "gameOver"              -- 游戏结束结果

--全局函数
PlayEffectMusic = function(music)
	music = music or "button.wav"
	music = "Sound/"..music
	if XML:getBoolForKey(SOUND_KEY) then
		audioEngine:setEffectsVolume(XML:getFloatForKey(SOUNDVOL))
		audioEngine:playEffect(music)
	end
end

createMenuItemSprite = function(normalImage,selectedImage,x,y,callback,flippedX,flippedY)
	x = x or 0
	y = y or 0
	flippedX = flippedX or false
	flippedY = flippedY or false
	callback = callback or nil

	local normalItem = display.newSprite(spriteFrames:getSpriteFrame(normalImage))
	local selectedItem =  display.newSprite(spriteFrames:getSpriteFrame(selectedImage))
	normalItem:setFlippedX(flippedX)
    normalItem:setFlippedY(flippedY)

    selectedItem:setFlippedX(flippedX)
    selectedItem:setFlippedY(flippedY)
    local item = cc.MenuItemSprite:create(normalItem,selectedItem)
    item:setPosition(x,y)
    if callback then
        item:registerScriptTapHandler(callback)
    end
    return item
end