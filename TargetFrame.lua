local function OnEvent(self, event, ...)
  if event == 'PLAYER_TARGET_CHANGED' then
    SlimUnitFrameTemplate_DrawHealth(self)
    SlimUnitFrameTemplate_DrawPower(self)
  end
end

function SlimTargetFrame_OnLoad(self)
  -- register for events
  self:RegisterEvent('PLAYER_TARGET_CHANGED', self.unit)

  -- we don't want this script to override any inherited templates' "OnEvent" handlers
  self:HookScript('OnEvent', OnEvent)
end
