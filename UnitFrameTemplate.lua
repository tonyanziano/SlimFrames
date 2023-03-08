local dump = DevTools_Dump

-- darken an RGB color by 25%
local function darkenColor(r, g, b)
  r = r * 0.75
  g = g * 0.75
  b = b * 0.75
  return r, g, b
end

-- turn a large number into a shortened representation if necessary
-- ex. 1230000 -> 1.23M  |  539240 -> 539.2K
function prettyPrintNumber(n)
  if n >= 1000000 then
    return format('%.2f M', n / 1000000)
  elseif n >= 1000 then
    return format('%.1f K', n /  1000)
  else
    return n
  end
end

local function getMenuFunctionForUnit(frame, unit)
  if unit == 'player' then
    return function()
      ToggleDropDownMenu(1, nil, PlayerFrameDropDown, frame, 0, 0);
    end
  elseif unit == 'target' then
    return function()
      -- NOTE: due to how the Blizzard target frame code is organized,
      -- the target frame dropdown is a property of an inherited template
      -- and not a global like the other dropdown frames
      ToggleDropDownMenu(1, nil, TargetFrame.DropDown, frame, 0, 0);
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

-- static health bar colors
local allyR, allyG, allyB = 23/255, 163/255, 32/255
local allyBgR, allyBgG, allyBgB = darkenColor(allyR, allyG, allyB)
local enemyR, enemyG, enemyB = 150/255, 20/255, 20/255
local enemyBgR, enemyBgG, enemyBgB = darkenColor(enemyR, enemyG, enemyB)
local neutralR, neutralG, neutralB = 219/255, 198/255, 61/255
local neutralBgR, neutralBgG, neutralBgB = darkenColor(neutralR, neutralG, neutralB)

function SlimUnitFrameTemplate_DrawHealth(self)
  if not UnitExists(self.unit) then
    return
  end

  local min = UnitHealth(self.unit)
  local max = UnitHealthMax(self.unit)
  local val
  if max == 0 then
    val = 0  -- prevent against dividing by 0
  else
    val = Round(min / max * 100)
  end

  if SlimFrames.db.global.smoothEnabled then
    self.health:SetSmoothedValue(val)
  else
    self.health:SetValue(val)
  end

  if UnitIsPlayer(self.unit) then
    local _, class = UnitClass(self.unit)
    local r, g, b = GetClassColor(class)
    local bgR, bgG, bgB = darkenColor(r, g, b)
    self.health:SetStatusBarColor(r, g, b)
    self.health.bg:SetVertexColor(bgR, bgG, bgB)
  else
    if UnitIsFriend('player', self.unit) then
      self.health:SetStatusBarColor(allyR, allyG, allyB)
      self.health.bg:SetVertexColor(allyBgR, allyBgG, allyBgB)
    elseif UnitIsEnemy('player', self.unit) then
      self.health:SetStatusBarColor(enemyR, enemyG, enemyB)
      self.health.bg:SetVertexColor(enemyBgR, enemyBgG, enemyBgB)
    else
      self.health:SetStatusBarColor(neutralR, neutralG, neutralB)
      self.health.bg:SetVertexColor(neutralBgR, neutralBgG, neutralBgB)
    end
  end
  
  if val == 0 then
    self.health.text:SetText('DEAD')
  else
    if SlimFrames.db.global.showAbsoluteHealth and SlimFrames.db.global.showPercentHealth then
      self.health.text:SetText(format('%s | %s', prettyPrintNumber(min), val .. '%'))
    elseif SlimFrames.db.global.showAbsoluteHealth then
      self.health.text:SetText(prettyPrintNumber(min))
    elseif SlimFrames.db.global.showPercentHealth then
      self.health.text:SetText(val .. '%')
    else
      -- hide health text
      self.health.text:SetText('')
    end
  end
  self.health.name:SetText(UnitName(self.unit))
end

-- taken from FrameXML
function SlimUnitFrameTemplate_GetPowerColors(self)
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

function SlimUnitFrameTemplate_DrawPower(self)
  if not UnitExists(self.unit) then
    return
  end

  local r, g, b = SlimUnitFrameTemplate_GetPowerColors(self)
  local bgR, bgG, bgB = darkenColor(r, g, b)
  local powerType = UnitPowerType(self.unit)
  local min = UnitPower(self.unit, powerType)
  local max = UnitPowerMax(self.unit, powerType)
  local val
  if max == 0 then
    val = 0  -- prevent against dividing by 0
  else
    val = Round(min / max * 100)
  end
  
  if SlimFrames.db.global.smoothEnabled then
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
    SlimUnitFrameTemplate_DrawHealth(self)
    SlimUnitFrameTemplate_DrawPower(self)
  elseif event == 'UNIT_HEALTH' then
    SlimUnitFrameTemplate_DrawHealth(self)
  elseif event == 'UNIT_POWER_FREQUENT' then
    SlimUnitFrameTemplate_DrawPower(self)
  end
end

function SlimUnitFrameTemplate_OnLoad(self)
  self:RegisterForClicks('LeftButtonUp', 'RightButtonUp');
  if self.unit ~= 'player' then
    RegisterUnitWatch(self)
  end
  
  -- configure dropdown menu on right click
  local showmenu = getMenuFunctionForUnit(self, self.unit)
  SecureUnitButton_OnLoad(self, self.unit, showmenu)

  -- register for events
  self:RegisterEvent('PLAYER_ENTERING_WORLD')
  self:RegisterUnitEvent('UNIT_HEALTH', self.unit)
  self:RegisterUnitEvent('UNIT_POWER_FREQUENT', self.unit)
  
  -- we don't want this script to override any inherited templates' "OnEvent" handlers
  self:HookScript('OnEvent', OnEvent)
end
