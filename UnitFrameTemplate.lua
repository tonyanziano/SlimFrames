SlimUnitFrameTemplateMixin = {}

local dump = DevTools_Dump
local smoothEnabled = true

-- darken an RGB color by 25%
local function darkenColor(r, g, b)
  r = r * 0.75
  g = g * 0.75
  b = b * 0.75
  return r, g, b
end

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

function SlimUnitFrameTemplateMixin:DrawHealth()
  if not UnitExists(self.unit) then
    return
  end

  local min = UnitHealth(self.unit)
  local max = UnitHealthMax(self.unit)
  local val = Round(min / max * 100)
  
  -- TODO: add smooth option
  if smoothEnabled then
    self.health:SetSmoothedValue(val)
  else
    self.health:SetValue(val)
  end

  if self.unit == 'player' then
    local _, class = UnitClass(self.unit)
    local r, g, b = GetClassColor(class)
    local bgR, bgG, bgB = darkenColor(r, g, b)
    self.health:SetStatusBarColor(r, g, b)
    self.health.bg:SetVertexColor(bgR, bgG, bgB)
  else
    -- TODO: color red for enemy and green for ally / neutral
    self.health:SetStatusBarColor(0, 1, 0, 1)
  end
  self.health.text:SetText(val .. '%')
  self.health.name:SetText(UnitName(self.unit))
end

-- taken from FrameXML
function SlimUnitFrameTemplateMixin:GetPowerColors()
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

function SlimUnitFrameTemplateMixin:DrawPower()
  if not UnitExists(self.unit) then
    return
  end

  local r, g, b = self:GetPowerColors()
  local bgR, bgG, bgB = darkenColor(r, g, b)
  local powerType = UnitPowerType(self.unit)
  local min = UnitPower(self.unit, powerType)
  local max = UnitPowerMax(self.unit, powerType)
  local val = Round(min / max * 100)
  
  
  -- TODO: add smooth option
  if smoothEnabled then
    self.power:SetSmoothedValue(val)
  else
    self.power:SetValue(val)
  end
  self.power:SetStatusBarColor(r, g, b, 1)
  self.power.bg:SetVertexColor(bgR, bgG, bgB)
  -- self.power.text:SetText(val .. '%')
end

local function OnEvent(self, event, ...)
  if event == 'PLAYER_ENTERING_WORLD' then
    self:DrawHealth()
    self:DrawPower()
  elseif event == 'UNIT_HEALTH' then
    self:DrawHealth()
  elseif event == 'UNIT_POWER_FREQUENT' then
    self:DrawPower()
  elseif event == 'PLAYER_TARGET_CHANGED' then
    self:DrawHealth()
    self:DrawPower()
  end
end

-- TODO: consider moving to SlimUnitFrameTemplate_OnLoad pattern
function SlimUnitFrameTemplateMixin:OnLoad()
  self:RegisterForClicks('LeftButtonUp', 'RightButtonUp');
  if self.unit ~= 'player' then
    RegisterUnitWatch(self)
  end
  local showmenu = getMenuFunctionForUnit(self, self.unit)
  SecureUnitButton_OnLoad(self, self.unit, showmenu)

  -- register for events
  self:RegisterEvent('PLAYER_ENTERING_WORLD')
  self:RegisterUnitEvent('UNIT_HEALTH', self.unit)
  self:RegisterUnitEvent('UNIT_POWER_FREQUENT', self.unit)
  if self.unit == 'target' then
    self:RegisterEvent('PLAYER_TARGET_CHANGED', self.unit)
  end
  -- we don't want this script to override any inherited templates' "OnEvent" handlers
  self:HookScript('OnEvent', OnEvent)
end
