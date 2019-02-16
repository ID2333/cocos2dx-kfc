local MainLogo = class("MainLogo",cc.load("mvc").ViewBase)

import(".Config")

function MainLogo:onCreate()

    display.newSprite("logo.png",display.cx,display.cy):addTo(self)
    if not XML:getBoolForKey("_IS_EXISTED") then
        MainLogo:initUserData()
        XML:setBoolForKey("_IS_EXISTED",true)
    end
    XML:setFloatForKey(SOUNDVOL,0.8)
    XML:setFloatForKey(MUSICVOL,0.35)
    XML:flush()

    self.m_iNumOfLoad = 0
    
    --图片异步加载
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:addImageAsync("pnglist/startGame.png", function() self:loadingTextureCallBack() end)
    textureCache:addImageAsync("pnglist/gameLayer.png", function() self:loadingTextureCallBack() end)
    textureCache:addImageAsync("pnglist/setLayer.png", function() self:loadingTextureCallBack() end)
    textureCache:addImageAsync("pnglist/cheatsLayer.png", function() self:loadingTextureCallBack() end)
    textureCache:addImageAsync("pnglist/gateMap.png", function() self:loadingTextureCallBack() end)
    textureCache:addImageAsync("pnglist/pauseLayer.png", function() self:loadingTextureCallBack() end)
    textureCache:addImageAsync("pnglist/hero.png", function() self:loadingTextureCallBack() end)
    textureCache:addImageAsync("pnglist/heroComobo.png", function() self:loadingTextureCallBack() end)
    textureCache:addImageAsync("pnglist/heroGun.png", function() self:loadingTextureCallBack() end)
    textureCache:addImageAsync("pnglist/galleryLayer.png", function() self:loadingTextureCallBack() end)

    cc.SimpleAudioEngine:getInstance():preloadMusic("Sound/startBGM.mp3")
    cc.SimpleAudioEngine:getInstance():preloadEffect("Sound/button.wav")
end

function MainLogo:nextScene()
   
   local scene = require("app.views.MainScene"):createScene()
   cc.Director:getInstance():replaceScene(scene)
end

function MainLogo:initUserData()
    XML:setIntegerForKey(GAMELEVEL_KEY,1)
    XML:setIntegerForKey(HEROENERGY_KEY,10)
    XML:setIntegerForKey(HEROCOIN_KEY,1000)
    XML:setBoolForKey(SOUND_KEY,true)
    XML:setBoolForKey(MUSIC_KEY,true)
    XML:flush()
end

function MainLogo:loadingTextureCallBack()
    local spriteFrams = cc.SpriteFrameCache:getInstance()
    if(self.m_iNumOfLoad == 0) then
        spriteFrams:addSpriteFrames("pnglist/startGame.plist")
        print("startGame.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
    end
    if(self.m_iNumOfLoad == 1) then
        spriteFrams:addSpriteFrames("pnglist/gameLayer.plist")
        print("gameLayer.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
    end
    if(self.m_iNumOfLoad == 2) then
        spriteFrams:addSpriteFrames("pnglist/setLayer.plist")
        print("setLayer.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
    end
    if(self.m_iNumOfLoad == 3) then
        spriteFrams:addSpriteFrames("pnglist/cheatsLayer.plist")
        print("cheatsLayer.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
    end
    if(self.m_iNumOfLoad == 4) then
        spriteFrams:addSpriteFrames("pnglist/gateMap.plist")
        print("gateMap.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
    end
    if(self.m_iNumOfLoad == 5) then
        spriteFrams:addSpriteFrames("pnglist/pauseLayer.plist")
        print("pauseLayer.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
    end
    if(self.m_iNumOfLoad == 6) then
        spriteFrams:addSpriteFrames("pnglist/hero.plist")
        print("hero.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
    end
    if(self.m_iNumOfLoad == 7) then
        spriteFrams:addSpriteFrames("pnglist/heroComobo.plist")
        print("heroComobo.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
    end
    if(self.m_iNumOfLoad == 8) then
        spriteFrams:addSpriteFrames("pnglist/heroGun.plist")
        print("heroGun.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
    end
    if(self.m_iNumOfLoad == 9) then
        spriteFrams:addSpriteFrames("pnglist/galleryLayer.plist")
        print("galleryLayer.plist加载成功;m_iNumOfLoad:",self.m_iNumOfLoad)
        performWithDelay(self,function() self:nextScene() end, 1)
    end
    self.m_iNumOfLoad = self.m_iNumOfLoad + 1

end


return MainLogo