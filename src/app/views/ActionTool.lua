local ActionTool = class("ActionTool")

function ActionTool:animationWithFrameName(eachName,loops,delay)
	local index = 0
	local spriteFrame = {}

	while true do
		index = index + 1
		local name = string.format("%s%d.png",eachName,index)
		local frame = spriteFrames:getSpriteFrame(name)
		if not frame then
			break
		end
		table.insert(spriteFrame,frame)
	end

	local animation = cc.Animation:createWithSpriteFrames(spriteFrame)
	animation:setDelayPerUnit(delay)
	animation:setRestoreOriginalFrame(true)
	local animate = cc.Animate:create(animation)

	return animate
end

function ActionTool:animationWithFrameAndNum(frameName,frameCount,delay)
	local frame = nil
	local animation = cc.Animation:create()

	for i=1,frameCount do
		local name = string.format("%s%d.png", frameName,i)
		frame = spriteFrames:getSpriteFrame(name)
		animation:addSpriteFrame(frame)
	end

	animation:setDelayPerUnit(delay)
	animation:setRestoreOriginalFrame(true)
	local animate = cc.Animate:create(animation)
	return animate
end

return ActionTool
