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
SEATREMOVED  = 1
SEATEMPTY    = 2
SEATASSIGNED = 3
AISLE        = 4

function initRec(rows, cols)
   local cid = 0
   AllSeats["size"]=0
   AllSeats["rows"]=rows
   AllSeats["cols"]=cols
   for r = 1, rows do
      for c = 1, cols do
	 cid = cid+1
	 AllSeats[cid] = Seat.new({id=cid, row=r, col=c, x=c-(cols+1)/2, y=r-1.0, rot=0, kind=SEATEMPTY, label=tostring(cid)})
	 -- if cid % 21 == 0 then
	 --   tex.sprint("\\typeout{***** Try to remove *****",AllSeats[cid].kind,"}")
	 ---   AllSeats[cid].kind = SEATASSIGNED
	 -- end
	 AllSeats["size"]=AllSeats["size"]+1
      end
   end
end
function seatDim(w,h)
   AllSeats["seatwidth"] = w
   AllSeats["seatheight"] = h
end

function seatIds()
   for ndx, v in ipairs(AllSeats) do
      tex.sprint(tostring(ndx),",")
   end
end
function findSeatAt(y,x)
   if y<0 then
      y = AllSeats["rows"] + y + 1
   end
   if x<0 then
      x = AllSeats["cols"] + x + 1
   end
   local ndx = (y-1)* AllSeats["cols"] + x
   if AllSeats[ndx].kind ~= SEATREMOVED then
   return ndx
   else
      return nil
   end
   --for ndx,s in ipairs(AllSeats) do SEATREMOVED then
   --   if s.col ~= nil and s.kind ~= SEATREMOVED then
   --	 if s.col == x and s.row == y then
   --	    return ndx
   --	 end
   --   end
   --end
   --return nil
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
   if ndx ~= nil then
      AllSeats[ndx].kind = SEATREMOVED
      --tex.sprint("\\typeout{remove seat ",ndx," at ",AllSeats[ndx].col,",",AllSeats[ndx].row,"}")
   end
end
function removeSeatAt(y,x)
   removeSeat(findSeatAt(y,x))
end
function seatempty(s) 
   local width = AllSeats["seatwidth"]
   local height = AllSeats["seatheight"]
   tex.sprint("\\node[rectangle,empty seat, minimum width=",width,", minimum height=",height,"] at (",s.x,",",s.y,") {Xy};")
   tex.sprint("\\node[empty label, minimum width=",width,"] at (",s.x,",",s.y,") {\\tucsassignedlabelformat{",s.label,"}};")
end
function seatassigned(s) 
   local width = AllSeats["seatwidth"]
   local height = AllSeats["seatheight"]
   tex.sprint("\\node[rectangle,assigned seat, minimum width=",width,", minimum height=",height,"] at (",s.x,",",s.y,") {Xy};")
   tex.sprint("\\node[assigned label,minimum width=",width,"] at (",s.x,",",s.y,") {\\tucsassignedlabelformat{",s.label,"}};")
end

function seatremoved(s) 
   -- local width = 100/AllSeats["cols"]
   -- tex.sprint("\\node[rectangle,draw=red, minimum width =",0.95/AllSeats["cols"],"\\linewidth,font=\\tiny] at (",s.x*width,",",s.y,") {};")
end

function drawSeats()
 local  case_tbl =
    {
       [SEATREMOVED]  = seatremoved,
       [AISLE]        = seatremoved,
       [SEATEMPTY]    = seatempty,
       [SEATASSIGNED] = seatassigned,
    }
   for _ ,s in  ipairs(AllSeats) do
      if s.kind ~= nil then
	 func = case_tbl[s.kind]
	 if func ~= nil then
	    func(s)
	 end
      end
   end
end
 
