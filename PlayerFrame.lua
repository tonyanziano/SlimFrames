SlimPlayerFrameMixin = {}

local function OnEvent(self, event, ...)
  if event == 'PLAYER_ENTERING_WORLD'
  or event == 'PLAYER_REGEN_DISABLED'
  or event == 'PLAYER_REGEN_ENABLED'
  or event == 'PLAYER_UPDATE_RESTING' then
    DrawStatusIcons(self)
  end
end

function DrawStatusIcons(self)
  if not self.areStateIconsSet then
    self.restIcon:SetTexCoord(0, 0.5, 0, 0.5)
    self.combatIcon:SetTexCoord(0.5, 1, 0, 0.5)
    self.areStateIconsSet = true
  end

  local isInCombat = UnitAffectingCombat(self.unit)
  local isRested = GetRestState()
  if isInCombat then
    self.combatIcon:Show()
  else
    self.combatIcon:Hide()
  end
  if isRested then
    self.restIcon:Show()
  else
    self.restIcon:Hide()
  end
end

function SlimPlayerFrame_OnLoad(self)
  -- register for events
  self:RegisterEvent('PLAYER_ENTERING_WORLD')
  self:RegisterEvent('PLAYER_REGEN_DISABLED')
  self:RegisterEvent('PLAYER_REGEN_ENABLED')
  self:RegisterEvent('PLAYER_UPDATE_RESTING')
  -- we don't want this script to override any inherited templates' "OnEvent" handlers
  self:HookScript('OnEvent', OnEvent)
end