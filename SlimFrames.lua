-- TODO: these should probably moved to individual frame files / modules
-- NOTE: or maybe we could have some frame initialization code here
-- that loads the coming config DB and then creates a frame based on if the
-- module is enabled or not
local playerFrameEnabled = true
local targetFrameEnabled = false
local focusFrameEnabled = false

-- hide default frames
if playerFrameEnabled then
  PlayerFrame:Hide()
end

if targetFrameEnabled then
  
end

if focusFrameEnabled then
  
end
