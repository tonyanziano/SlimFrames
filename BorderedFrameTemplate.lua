
local minBorderSize = 1

local function SlimBorderedFrameTemplate_RedrawBorder(frame)
  SF:log(format('Drawing border for %s', frame:GetName()))

  if frame.isBorderHidden then
    -- iterate through each border texture and hide them
    table.foreach(frame.borders, function(_, b) b:Hide() end)
  else
    -- iterate through each border texture and show them
    table.foreach(frame.borders, function(_, b) b:Show() end)

    local left, right, top, bottom = frame.left, frame.right, frame.top, frame.bottom
    local borderSize = frame.borderSize

    -- adjust border sizes
    PixelUtil.SetWidth(left, borderSize, minBorderSize)
    PixelUtil.SetWidth(right, borderSize, minBorderSize)
    PixelUtil.SetHeight(top, borderSize, minBorderSize)
    PixelUtil.SetHeight(bottom, borderSize, minBorderSize)

    -- adjust border colors
    local r, g, b, a = frame.borderColorR, frame.borderColorG, frame.borderColorB, frame.borderColorA
    left:SetColorTexture(r, g, b, a)
    right:SetColorTexture(r, g, b, a)
    top:SetColorTexture(r, g, b, a)
    bottom:SetColorTexture(r, g, b, a)

    -- set border positions relative to frame
    left:ClearAllPoints()
    PixelUtil.SetPoint(left, 'TOPRIGHT', frame, 'TOPLEFT', 0, borderSize)
    PixelUtil.SetPoint(left, 'BOTTOMRIGHT', frame, 'BOTTOMLEFT', 0, -borderSize)

    right:ClearAllPoints()
    PixelUtil.SetPoint(right, 'TOPLEFT', frame, 'TOPRIGHT', 0, borderSize)
    PixelUtil.SetPoint(right, 'BOTTOMLEFT', frame, 'BOTTOMRIGHT', 0, -borderSize)

    top:ClearAllPoints()
    PixelUtil.SetPoint(top, 'BOTTOMLEFT', frame, 'TOPLEFT', -borderSize, 0)
    PixelUtil.SetPoint(top, 'BOTTOMRIGHT', frame, 'TOPRIGHT', borderSize, 0)

    bottom:ClearAllPoints()
    PixelUtil.SetPoint(bottom, 'TOPLEFT', frame, 'BOTTOMLEFT', -borderSize, 0)
    PixelUtil.SetPoint(bottom, 'TOPRIGHT', frame, 'BOTTOMRIGHT', borderSize, 0)
  end
end

function SlimBorderedFrameTemplate_OnLoad(frame)
  frame.redrawBorder = function ()
    SlimBorderedFrameTemplate_RedrawBorder(frame)
  end
  frame.redrawBorder()
end
