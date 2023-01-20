local function OnEvent(self, event, ...)
  local addonName = ...
  if event == 'ADDON_LOADED' and addonName == 'FigHud' then
    -- let the Blizzard layout cache position the frame to its last known location
    self:SetMovable(true)
  elseif event == 'PLAYER_ENTERING_WORLD' then
    self:SetMovable(false)
  end
end

function DraggableFrameTemplate_OnLoad(self)
  self:RegisterForDrag("LeftButton")
  self:RegisterEvent('ADDON_LOADED')
  self:RegisterEvent('PLAYER_ENTERING_WORLD')
  self:HookScript('OnEvent', OnEvent)
end

function DraggableFrameTemplate_OnDragStart(self)
  self:SetMovable(true)
  self:StartMoving()
end

function DraggableFrameTemplate_OnDragStop(self)
  self:StopMovingOrSizing()
end
