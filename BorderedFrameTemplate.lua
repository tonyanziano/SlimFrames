
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
    PixelUtil.SetWidth(frame.right, borderSize, minBorderSize)
    PixelUtil.SetHeight(frame.top, borderSize, minBorderSize)
    PixelUtil.SetHeight(frame.bottom, borderSize, minBorderSize)

    -- adjust border colors
    local r, g, b, a = frame.borderColorR, frame.borderColorG, frame.borderColorB, frame.borderColorA
    left:SetColorTexture(r, g, b, a)
    right:SetColorTexture(r, g, b, a)
    top:SetColorTexture(r, g, b, a)
    bottom:SetColorTexture(r, g, b, a)

    -- set border positions relative to frame
    PixelUtil.SetPoint(left, 'TOPRIGHT', frame, 'TOPLEFT', -borderSize, borderSize, minBorderSize)
    PixelUtil.SetPoint(left, 'BOTTOMRIGHT', frame, 'BOTTOMLEFT', -borderSize, -borderSize, minBorderSize)

    PixelUtil.SetPoint(right, 'TOPLEFT', frame, 'TOPRIGHT', borderSize, borderSize, minBorderSize)
    PixelUtil.SetPoint(right, 'BOTTOMLEFT', frame, 'BOTTOMRIGHT', borderSize, -borderSize, minBorderSize)

    PixelUtil.SetPoint(top, 'BOTTOMLEFT', frame, 'TOPLEFT', -borderSize, borderSize, minBorderSize)
    PixelUtil.SetPoint(top, 'BOTTOMRIGHT', frame, 'TOPRIGHT', borderSize, borderSize, minBorderSize)

    PixelUtil.SetPoint(bottom, 'TOPLEFT', frame, 'BOTTOMLEFT', -borderSize, -borderSize, minBorderSize)
    PixelUtil.SetPoint(bottom, 'TOPRIGHT', frame, 'BOTTOMRIGHT', borderSize, -borderSize, minBorderSize)
  end
end

function SlimBorderedFrameTemplate_OnLoad(frame)
  frame.redrawBorder = function ()
    SlimBorderedFrameTemplate_RedrawBorder(frame)
  end
  frame.redrawBorder()
end
