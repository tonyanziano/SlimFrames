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
          order = 20,
          name = 'Scale',
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
          order = 30,
          name = 'Smooth updates',
          desc = 'Toggles whether health and power bars smoothly animate on updates',
          type = 'toggle',
          get = function(info) return SlimFrames.db.global.smoothEnabled end,
          set = function(info, val)
            SlimFrames.db.global.smoothEnabled = val
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
          order = 100,
          name = 'Health height',
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
          order = 100,
          name = 'Power height',
          type = 'range',
          min = 0,
          max = 50,
          step = 1,
          isPercent = false,
          get = function () return SlimFrames.db.global.playerPowerHeight end,
          set = function (info, val)
            SlimFrames.db.global.playerPowerHeight = val
            SlimFrames:RedrawPlayerFrame()
          end
        },
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
    scale = 1,
    smoothEnabled = true,
    playerEnabled = true,
    playerWidth = 150,
    playerHealthHeight = 15,
    playerPowerHeight = 5,
    targetEnabled = true
  },
  profile = {
    scale = 1,
    smoothEnabled = true,
    playerEnabled = true,
    playerWidth = 150,
    playerHealthHeight = 15,
    playerPowerHeight = 5,
    targetEnabled = true
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

  SlimPlayerFrame:SetSize(SlimFrames.db.global.playerWidth, frameHeight)
  SlimPlayerFrame.health:SetHeight(healthHeight)
  SlimPlayerFrame.power:SetHeight(powerHeight)
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

function SlimFrames:OnInitialize()
  -- register DB / persistent storage
  self.db = LibStub('AceDB-3.0'):New('SlimFramesDB', defaults)
  self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
  self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

  -- TODO: need to figure out how to hide these during a cinematic -- maybe a frame strata issue?
  -- hide default frames
  if self.db.global.playerEnabled then
    -- TODO: player frame keeps popping up sometimes -- figure out how to stop it
    PlayerFrame:Hide()
    PlayerFrame:SetScript('OnShow', function(self) self:Hide() end)
  else
    SlimPlayerFrame:Hide() -- might need to call some function on the target frame here that disables itself
  end

  if self.db.global.targetEnabled then
    UnregisterUnitWatch(TargetFrame)
    TargetFrame:SetScript('OnUpdate', nil)
    -- the Blizzard target frame uses the Update function to toggle its own visibility
    TargetFrame.Update = function () end
  else
    SlimTargetFrame:Hide() -- might need to call some function on the target frame here that disables itself
  end

  -- if petFrameEnabled then

  -- end

  -- if focusFrameEnabled then
    
  -- end

  self:RedrawAllFrames()
end
