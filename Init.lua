-- get refs to Ace libs
local configDialog = LibStub('AceConfigDialog-3.0')

-- register the addon with Ace
SlimFrames = LibStub('AceAddon-3.0'):NewAddon('SlimFrames', 'AceConsole-3.0')

-- register slash commands
SlimFrames:RegisterChatCommand('sf', 'ToggleOptionsDialog')
SlimFrames:RegisterChatCommand('slimframes', 'ToggleOptionsDialog')

function SlimFrames:ToggleOptionsDialog()
  if configDialog.OpenFrames['SlimFrames'] then
    configDialog:Close('SlimFrames')
  else
    configDialog:Open('SlimFrames')
  end
end

-- internal modifier to get scale looking right
local internalScaleMultiplier = 1.35

-- TODO: consider making the options config dynamic for each frame so we don't have to have such a large
-- object for options

-- TODO: add options for configuring what text to show on frames and their behaviors
-- ex: percentage vs abs value

-- register addon config
local optionsConfig = {
  name = 'SlimFrames',
  handler = SlimFrames,
  type = 'group',
  childGroups = 'tab',
  args = {
    general = {
      name = 'General',
      type = 'group',
      inline = true,
      args = {
        scale = {
          order = 10,
          name = 'Scale',
          desc = 'Adjusts the scale of all SlimFrames frames',
          type = 'range',
          min = 0.6,
          max = 2,
          step = 0.01,
          isPercent = true,
          get = function () return SlimFrames.db.global.scale end,
          set = function (info, val)
            SlimFrames.db.global.scale = val
            SlimFrames:SetMasterScale()
          end
        },
        smooth = {
          order = 20,
          name = 'Smooth updates',
          desc = 'Toggles whether health and power bars smoothly animate on updates',
          type = 'toggle',
          get = function(info) return SlimFrames.db.global.smoothEnabled end,
          set = function(info, val)
            SlimFrames.db.global.smoothEnabled = val
          end,
          width = 'full'
        },
        showAbsoluteHealth = {
          order = 30,
          width = 'full',
          name = 'Show absolute health value',
          desc = 'Toggles showing an absolute value segment of health info',
          type = 'toggle',
          get = function(info) return SlimFrames.db.global.showAbsoluteHealth end,
          set = function(info, val)
            SlimFrames.db.global.showAbsoluteHealth = val
            SlimFrames:RedrawPlayerFrame()
          end
        },
        showPercentHealth = {
          order = 40,
          width = 'full',
          name = 'Show percent health value',
          desc = 'Toggles showing a percent value segment of health info',
          type = 'toggle',
          get = function(info) return SlimFrames.db.global.showPercentHealth end,
          set = function(info, val)
            SlimFrames.db.global.showPercentHealth = val
            SlimFrames:RedrawPlayerFrame()
          end
        }
      }
    },
    player = {
      name = 'Player Frame',
      type = 'group',
      args = {
        enable = {
          order = 10,
          width = 'full',
          name = 'Enable',
          desc = 'Toggles the player frame',
          type = 'toggle',
          get = function(info) return SlimFrames.db.global.playerEnabled end,
          set = function(info, val)
            SlimFrames.db.global.playerEnabled = val
          end
        },
        width = {
          order = 20,
          name = 'Width',
          desc = 'Sets the width of the player frame',
          type = 'range',
          min = 80,
          max = 400,
          step = 1,
          isPercent = false,
          get = function () return SlimFrames.db.global.playerWidth end,
          set = function (info, val)
            SlimFrames.db.global.playerWidth = val
            SlimFrames:RedrawPlayerFrame()
          end
        },
        healthHeight = {
          order = 21,
          name = 'Health height',
          desc = 'Sets the width of the health bar portion of the player frame',
          type = 'range',
          min = 15,
          max = 100,
          step = 1,
          isPercent = false,
          get = function () return SlimFrames.db.global.playerHealthHeight end,
          set = function (info, val)
            SlimFrames.db.global.playerHealthHeight = val
            SlimFrames:RedrawPlayerFrame()
          end
        },
        powerHeight = {
          order = 22,
          name = 'Power height',
          desc = 'Sets the width of the power bar portion of the player frame',
          type = 'range',
          min = 0,
          max = 50,
          step = 1,
          isPercent = false,
          get = function () return SlimFrames.db.global.playerPowerHeight end,
          set = function (info, val)
            SlimFrames.db.global.playerPowerHeight = val
            SlimFrames:RedrawPlayerFrame()
          end,
        },
				dummySeparator0 = {
					type = "description",
					name = " ",
					order = 14,
					width = "full",
				},
        xPos = {
          order = 30,
          name = 'X position',
          desc = 'Sets the x position of the player frame',
          type = 'range',
          softMin = -999,
          softMax = 999,
          min = -2000,
          max = 2000,
          step = 10,
          isPercent = false,
          get = function () return SlimFrames.db.global.playerX end,
          set = function (info, val)
            SlimFrames.db.global.playerX = val
            SlimFrames:RedrawPlayerFrame()
          end
        },
        yPos = {
          order = 31,
          name = 'Y position',
          desc = 'Sets the y position of the player frame',
          type = 'range',
          softMin = -999,
          softMax = 999,
          min = -2000,
          max = 2000,
          step = 1,
          isPercent = false,
          get = function () return SlimFrames.db.global.playerY end,
          set = function (info, val)
            SlimFrames.db.global.playerY = val
            SlimFrames:RedrawPlayerFrame()
          end
        },
				dummySeparator1 = {
					type = "description",
					name = " ",
					order = 40,
					width = "full",
				},
        centerHorizontally = {
          order = 41,
          name = 'Center horizontally',
          desc = 'Center the player frame horizontally with respect to the screen',
          type = 'execute',
          func = function ()
            SlimFrames.db.global.playerX = 0
            SlimFrames:RedrawPlayerFrame()
          end
        },
        centerVertically = {
          order = 42,
          name = 'Center vertically',
          desc = 'Center the player frame vertically with respect to the screen',
          type = 'execute',
          func = function ()
            SlimFrames.db.global.playerY = 0
            SlimFrames:RedrawPlayerFrame()
          end
        }
      }
    },
    target = {
      name = 'Target Frame',
      type = 'group',
      args = {
        enable = {
          name = 'Enable',
          desc = 'Toggles the target frame',
          type = 'toggle',
          get = function(info) return SlimFrames.db.global.targetEnabled end,
          set = function(info, val) SlimFrames.db.global.targetEnabled = val end
        }
      }
    }
  }
}
LibStub('AceConfig-3.0'):RegisterOptionsTable('SlimFrames', optionsConfig, nil)

local defaults = {
  global = {
    -- general
    scale = 1,
    smoothEnabled = true,
    showPercentHealth = true,
    showAbsoluteHealth = true,
    -- player
    playerEnabled = true,
    playerWidth = 150,
    playerHealthHeight = 15,
    playerPowerHeight = 5,
    playerX = -140,
    playerY = -100,
    -- target
    targetEnabled = true,
    targetX = 140,
    targetY = -100,
  },
  profile = {
    -- general
    scale = 1,
    smoothEnabled = true,
    showHealthAsPercent = true,
    -- player
    playerEnabled = true,
    playerWidth = 150,
    playerHealthHeight = 15,
    playerPowerHeight = 5,
    playerX = -140,
    playerY = -100,
    -- target
    targetEnabled = true,
    targetX = 140,
    targetY = -100,
  }
}

-- main code

function SlimFrames:SetMasterScale()
  SlimMasterFrame:SetScale(SlimFrames.db.global.scale * internalScaleMultiplier)
end

function SlimFrames:RedrawPlayerFrame()
  local healthHeight = SlimFrames.db.global.playerHealthHeight
  local powerHeight = SlimFrames.db.global.playerPowerHeight
  local frameHeight = healthHeight + powerHeight

  SlimPlayerFrame:ClearAllPoints()
  SlimPlayerFrame:SetPoint('CENTER', nil, 'CENTER', SlimFrames.db.global.playerX, SlimFrames.db.global.playerY)
  SlimPlayerFrame:SetSize(SlimFrames.db.global.playerWidth, frameHeight)
  SlimPlayerFrame.health:SetHeight(healthHeight)
  SlimPlayerFrame.power:SetHeight(powerHeight)

  -- call regular drawing functions
  SlimUnitFrameTemplate_DrawHealth(SlimPlayerFrame)
  SlimUnitFrameTemplate_DrawPower(SlimPlayerFrame)
end

function SlimFrames:RedrawAllFrames()
  self:SetMasterScale()
  self:RedrawPlayerFrame()
end

function SlimFrames:RefreshConfig()
  -- update all frames that depend on config
  if SlimFrames.db.global.playerEnabled then
    SlimFrames:RedrawPlayerFrame()
  end
end

-- small function that is used to force a frame to hide itself
-- (used in conjunction with an 'OnShow' event handler)
function forceHideFrame(self)
  SF:log(format('Force hiding %s frame', self:GetName()))
  self:Hide()
end

function SlimFrames:OnInitialize()
  -- register DB / persistent storage
  self.db = LibStub('AceDB-3.0'):New('SlimFramesDB', defaults)
  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

  if self.db.global.playerEnabled then
    UnregisterUnitWatch(PlayerFrame)
    PlayerFrame:UnregisterAllEvents()
    PlayerFrame:SetScript('OnEvent', nil)
    PlayerFrame:SetScript('OnLoad', nil)
    PlayerFrame:SetScript('OnUpdate', nil)
    PlayerFrame:HookScript('OnShow', forceHideFrame)
    PlayerFrame:Hide()
  else
    SlimPlayerFrame:Hide() -- might need to call some function on the target frame here that disables itself
  end

  if self.db.global.targetEnabled then
    UnregisterUnitWatch(TargetFrame)
    TargetFrame:UnregisterAllEvents()
    TargetFrame:SetScript('OnEvent', nil)
    TargetFrame:SetScript('OnLoad', nil)
    TargetFrame:SetScript('OnUpdate', nil)
    TargetFrame:HookScript('OnShow', forceHideFrame)
    TargetFrame:Hide()
  else
    SlimTargetFrame:Hide() -- might need to call some function on the target frame here that disables itself
  end

  -- if petFrameEnabled then

  -- end

  -- if focusFrameEnabled then
    
  -- end

  self:RedrawAllFrames()
end
