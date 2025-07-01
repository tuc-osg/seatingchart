Seat = {
   id = nil,
   row = 0,
   col = 0,
   x = 0,
   y = 0,
   rot = 0,
   kind = nil,
   label=""
}
function Seat:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end
AllSeats={}
SEATREMOVED  = 0
SEATEMPTY    = 1
SEATASSIGNED = 2


function initRec(rows, cols)
   local cid = 0
   AllSeats["size"]=0
   AllSeats["rows"]=rows
   AllSeats["cols"]=cols
   for r = 1, rows do
      for c = 1, cols do
	 cid = cid+1
	 AllSeats[cid] = Seat.new({id=cid, row=r, col=c, x=c-1-cols/2, y=r-1.0, rot=0, kind=SEATEMPTY, label="x"})
	 -- if cid % 21 == 0 then
	 --   tex.sprint("\\typeout{***** Try to remove *****",AllSeats[cid].kind,"}")
	 ---   AllSeats[cid].kind = SEATASSIGND
	 -- end
	 AllSeats["size"]=AllSeats["size"]+1
      end
   end
end
function seatIds()
   for ndx, v in ipairs(AllSeats) do
      tex.sprint(tostring(ndx),",")
   end
end
function findSeatAt(y,x)
   for ndx,s in ipairs(AllSeats) do
      if s.col ~= nil and s.kind ~= SEATREMOVED then
	 if s.col == x and s.row == y then
	    return ndx
	 end
      end
   end
   return nil
end	 
function assignSeat(ndx,l)
   if ndx ~= nil and AllSeats[ndx].kind == SEATEMPTY then
      AllSeats[ndx].kind = SEATASSIGNED
      AllSeats[ndx].label=l
   end
end
function assignSeatAt(y,x,l)
   assignSeat(findSeatAt(y,x),l)
end
function removeSeat(ndx)
   tex.sprint("\\typeout{call remove seat ",ndx,"}")
   if ndx ~= nil then
      AllSeats[ndx].kind = SEATREMOVED
      tex.sprint("\\typeout{remove seat ",ndx," at ",AllSeats[ndx].x,",",AllSeats[ndx].y,"}")
   end
end
function removeSeatAt(y,x)
   removeSeat(findSeatAt(y,x))
end
function seatempty(s) 
   local width = 100/AllSeats["cols"]
   tex.sprint("\\node[rectangle,empty seat, minimum width=",0.9/AllSeats["cols"],"\\linewidth] at (",s.x*width,",",s.y,") {};")
   tex.sprint("\\node[empty label, minimum width=",0.9/AllSeats["cols"],"\\linewidth] at (",s.x*width,",",s.y,") {",s.id,"};")
end
function seatassigned(s) 
   local width = 100/AllSeats["cols"]
   tex.sprint("\\node[rectangle,assigned seat, minimum width=",0.9/AllSeats["cols"],"\\linewidth] at (",s.x*width,",",s.y,") {};")
   tex.sprint("\\node[assigned label,minimum width=",0.9/AllSeats["cols"],"\\linewidth] at (",s.x*width,",",s.y,") {",s.label,"};")
end

function seatremoved(s) 
   -- local width = 100/AllSeats["cols"]
   -- tex.sprint("\\node[rectangle,draw=red, minimum width =",0.95/AllSeats["cols"],"\\linewidth,font=\\tiny] at (",s.x*width,",",s.y,") {};")
end

function drawSeats()
 local  case_tbl =
    {
       [SEATREMOVED] = seatremoved,
       [SEATEMPTY] = seatempty,
       [SEATASSIGNED] = seatassigned,
    }
   AllSeats[5].kind = SEATASSIGNED
   for _ ,s in  ipairs(AllSeats) do
      if s.kind ~= nil then
	 func = case_tbl[s.kind]
	 if func ~= nil then
	    func(s)
	 end
      end
   end
end
 
