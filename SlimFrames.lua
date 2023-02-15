-- TODO: these should probably moved to individual frame files / modules
-- NOTE: or maybe we could have some frame initialization code here
-- that loads the coming config DB and then creates a frame based on if the
-- module is enabled or not
local playerFrameEnabled = true
local targetFrameEnabled = true
local focusFrameEnabled = false

-- TODO: need to figure out how to hide these during a cinematic -- maybe a frame strata issue?
-- hide default frames
if playerFrameEnabled then
  -- TODO: player frame keeps popping up sometimes -- figure out how to stop it
  PlayerFrame:Hide()
  PlayerFrame:SetScript('OnShow', function(self) self:Hide() end)
end

if targetFrameEnabled then
  UnregisterUnitWatch(TargetFrame)
  TargetFrame:SetScript('OnUpdate', nil)
  -- the Blizzard target frame uses the Update function to toggle its own visibility
  TargetFrame.Update = function () end
end

if focusFrameEnabled then
  
end
