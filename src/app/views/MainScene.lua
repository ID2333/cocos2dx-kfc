local MainScene = class("MainScene",function ()
    return cc.Scene:create()
end)

import(".Config")

function MainScene:createScene()
    local scene = MainScene:new()
    scene:init()
    return scene
end

function MainScene:init()
    --加载资源
    self:loadSpriteFrames(spriteFrames)

    --音乐设置
    if(XML:getBoolForKey(MUSIC_KEY)) then
        audioEngine:setMusicVolume(XML:getFloatForKey(MUSICVOL) * 100)
       
        if(audioEngine:isMusicPlaying()) then
            audioEngine:pauseMusic()
            audioEngine:playMusic("Sound/startBGM.mp3",true)
        else
            audioEngine:playMusic("Sound/startBGM.mp3", true)
        end
    else
        audioEngine:pauseMusic()
    end
    
    --菜单背景
    display.newSprite(spriteFrames:getSpriteFrame("MainMenuBackground.png"),display.cx,display.cy):addTo(self)
    display.newSprite(spriteFrames:getSpriteFrame("Title.png"),display.cx,display.cy + 186):addTo(self)

    --加载菜单按钮
    self:loadMenuButton()
end

function MainScene:loadSpriteFrames(spriteFrames)
    spriteFrames:addSpriteFrames("pnglist/galerLayer.plist")
    spriteFrames:addSpriteFrames("pnglist/monster.plist")
    spriteFrames:addSpriteFrames("pnglist/resultLayer.plist")
    spriteFrames:addSpriteFrames("pnglist/mapBg.plist")
    spriteFrames:addSpriteFrames("pnglist/mapMid.plist")
end

function MainScene:loadMenuButton()
    --------------------------------------------帮助按钮----------------------------------------------------------
    local helpItem = createMenuItemSprite("HelpNormal.png","HelpSelected.png",display.width - 62,display.height - 473,
    function() self:nextScene(3) end)
    --------------------------------------------图集按钮-----------------------------------------------------------
    local atlasItem = createMenuItemSprite("PhotoGalleryNormal.png","PhotoGallerySelected.png",display.width - 62,
    display.height - 73,function() self:nextScene(5) end)
    --------------------------------------------设置按钮-----------------------------------------------------------
    local setItem = createMenuItemSprite("SetNormal.png","SetSelected.png",display.width - 62,
    display.height - 346,function() self:nextScene(2) end)
    --------------------------------------------秘籍按钮-----------------------------------------------------------
    local esotericallyItem = createMenuItemSprite("CheatsNormal.png", "CheatsSelected.png", display.width - 62,
    display.height - 209,function() self:nextScene(4) end)
    --------------------------------------------闯关模式-----------------------------------------------------------
    local breakthroughItem = createMenuItemSprite("EmigratedNormal.png", "EmigratedSelected.png", display.cx - 240,
    display.cy - 86, function() self:nextScene(1) end)
    --------------------------------------------挑战模式-----------------------------------------------------------
    local challengeItem = createMenuItemSprite("ChallengeNormal.png", "ChallengeSelected.png",display.cx - 240,
    display.cy - 256, function() self:nextScene(1) end)
    cc.Menu:create(helpItem,atlasItem,setItem,esotericallyItem,challengeItem,breakthroughItem):addTo(self):setPosition(cc.p(0,0)) 
end

function MainScene:nextScene(index)
    --挑战模式和闯关模式
    if index == 1 then
        PlayEffectMusic() 
        cc.Label:createWithSystemFont("测试","",30)
        :setPosition(display.cx,display.cy)
        :addTo(self)
        local scene = require("app.views.MapLayer"):createScene()
        cc.Director:getInstance():replaceScene(scene)
    end
    --设置
    if index == 2 then
        PlayEffectMusic() 
        local scene = require("app.views.SetLayer"):createScene()
        cc.Director:getInstance():replaceScene(scene)
    end
    --帮助
    if index == 3 then
        PlayEffectMusic()
        local scene = require("app.views.HelpLayer"):createScene()
        cc.Director:getInstance():replaceScene(scene)
    end
    --秘籍
    if index == 4 then
        PlayEffectMusic()
        local scene = require("app.views.MiJiLayer"):createScene()
        cc.Director:getInstance():replaceScene(scene)
    end
    --图集
    if index == 5 then
        PlayEffectMusic()
        local scene = require("app.views.PictureLayer"):createScene()
        cc.Director:getInstance():replaceScene(scene)
    end
end
return MainScene
