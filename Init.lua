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
      args = {
        -- more options go here
      }
    },
    player = {
      name = 'Player Frame',
      type = 'group',
      args = {
        enable = {
          order = 10,
          name = 'Enable',
          desc = 'Toggles the player frame',
          type = 'toggle',
          get = function(info) return SlimFrames.db.global.playerEnabled end,
          set = function(info, val) SlimFrames.db.global.playerEnabled = val end
        },
        width = {
          order = 20,
          name = 'Width',
          type = 'range',
          min = 80,
          max = 400,
          isPercent = false,
          get = function () return SlimFrames.db.global.playerWidth end,
          set = function (info, val) SlimFrames.db.global.playerWidth = val end
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
    -- vigorScale = {
    --   name = 'EncounterBar frame scale',
    --   type = 'range',
    --   order = 10,
    --   min = 0.2,
    --   max = 1.5,
    --   isPercent = true,
    --   get = function() return SlimFrames.db.global.vigorScale end,
    --   set = function(info, val)
    --     SlimFrames.db.global.vigorScale = val
    --   end
    -- }
  }
}
LibStub('AceConfig-3.0'):RegisterOptionsTable('SlimFrames', optionsConfig, nil)

local optionsDefaults = {
  global = {
    playerEnabled = true,
    playerWidth = 150,
    playerHeight = 20,
    targetEnabled = true
  }
}

-- main code

function SlimFrames:OnInitialize()
  -- register DB / persistent storage
  self.db = LibStub('AceDB-3.0'):New('SlimFramesDB', optionsDefaults)
end
