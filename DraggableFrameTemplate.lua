function DraggableFrameTemplate_OnLoad(self)
  print('calling draggable frame template onload')
  self:RegisterForDrag("LeftButton")
end

function DraggableFrameTemplate_OnDragStart(self)
  self:SetMovable(true)
  self:StartMoving()
end

function DraggableFrameTemplate_OnDragStop(self)
  self:StopMovingOrSizing()
end
