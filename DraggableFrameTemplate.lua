local function OnEvent(self, event, ...)
  local addonName = ...
  if event == 'ADDON_LOADED' and addonName == 'FigHud' then
    -- let the Blizzard layout cache position the frame to its last known location
    self:SetMovable(true)
  elseif event == 'PLAYER_LOGIN' then
    -- after the frame is positioned from its last-known position, save it again in the layout cache
    self:StopMovingOrSizing()
  end
end

function DraggableFrameTemplate_OnLoad(self)
  self:RegisterForDrag("LeftButton")
  self:RegisterEvent('ADDON_LOADED')
  self:RegisterEvent('PLAYER_LOGIN')
  self:HookScript('OnEvent', OnEvent)
end

function DraggableFrameTemplate_OnDragStart(self)
  self:SetMovable(true)
  self:StartMoving()
end

function DraggableFrameTemplate_OnDragStop(self)
  self:StopMovingOrSizing()
end
