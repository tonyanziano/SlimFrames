FUnitFrameTemplateMixin = {}

local dump = DevTools_Dump

local function getMenuFunctionForUnit(frame, unit)
  if unit == 'player' then
    return function()
      ToggleDropDownMenu(1, nil, PlayerFrameDropDown, frame, 0, 0);
    end
  elseif unit == 'target' then
    return function()
      ToggleDropDownMenu(1, nil, TargetFrameDropDown, frame, 0, 0);
    end
  elseif strfind(unit, 'party', 0) then
    return function()
      ToggleDropDownMenu(1, nil, PartyFrameDropDown, frame, 0, 0);
    end
  elseif unit == 'pet' then
    return function()
      ToggleDropDownMenu(1, nil, PetFrameDropDown, frame, 0, 0);
    end
  end
  return nil
end

function FUnitFrameTemplateMixin:DrawHealth()
  if not UnitExists(self.unit) then
    return
  end

  local min = UnitHealth(self.unit)
  local max = UnitHealthMax(self.unit)
  local val = Round(min / max * 100)
  self.health:SetValue(val)

  if self.unit == 'player' then
    local _, class = UnitClass(self.unit)
    local r, g, b = GetClassColor(class)
    self.health:SetStatusBarColor(r, g, b)
  else
    -- TODO: color red for enemy and green for ally / neutral
    self.health:SetStatusBarColor(0, 1, 0, 1)
  end
  self.health.text:SetText(val .. '%')
  self.health.name:SetText(UnitName(self.unit))
end

-- taken from FrameXML
function FUnitFrameTemplateMixin:GetPowerColors()
  local powerType, powerToken, altR, altG, altB = UnitPowerType(self.unit)
  local info = PowerBarColor[powerToken]
  local r, g, b

  if info then
    --The PowerBarColor takes priority
    r, g, b = info.r, info.g, info.b
  elseif not altR then
    -- Couldn't find a power token entry. Default to indexing by power type or just mana if  we don't have that either.
    info = PowerBarColor[powerType] or PowerBarColor['MANA']
    r, g, b = info.r, info.g, info.b
  else
    r, g, b = altR, altG, altB
  end

  return r, g, b
end

function FUnitFrameTemplateMixin:DrawPower()
  if not UnitExists(self.unit) then
    return
  end

  local r, g, b = self:GetPowerColors()
  local powerType = UnitPowerType(self.unit)
  local min = UnitPower(self.unit, powerType)
  local max = UnitPowerMax(self.unit, powerType)
  local val = Round(min / max * 100)
  self.power:SetValue(val)
  self.power:SetStatusBarColor(r, g, b, 1)
  -- self.power.text:SetText(val .. '%')
end

local function OnEvent(self, event, ...)
  local unit, powerType = ...;
  if event == 'UNIT_HEALTH' then
    self:DrawHealth()
  elseif event == 'UNIT_POWER_FREQUENT' then
    self:DrawPower()
  elseif event == 'PLAYER_TARGET_CHANGED' then
    self:DrawHealth()
    self:DrawPower()
  end
end

function FUnitFrameTemplateMixin:OnLoad()
  self:RegisterForClicks('LeftButtonUp', 'RightButtonUp');
  if self.unit ~= 'player' then
    RegisterUnitWatch(self)
  end
  local showmenu = getMenuFunctionForUnit(self, self.unit)
  SecureUnitButton_OnLoad(self, self.unit, showmenu)

  -- initial draw
  self:DrawHealth()
  self:DrawPower()

  -- register for events
  self:RegisterUnitEvent('UNIT_HEALTH', self.unit)
  self:RegisterUnitEvent('UNIT_POWER_FREQUENT', self.unit)
  if self.unit == 'target' then
    self:RegisterEvent('PLAYER_TARGET_CHANGED', self.unit)
  end
  -- we don't want this script to override any inherited templates' "OnEvent" handlers
  self:HookScript('OnEvent', OnEvent)
end
