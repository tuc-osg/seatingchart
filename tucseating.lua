Seat = {
   id = nil,
   row = 0,
   col = 0,
   x = 0,
   y = 0,
   rot = 0,
   kind = nil
}
function Seat:new(o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end
AllSeats={}
function InitRec(rows, cols)
   local cid = 0
   for r = 1, rows do
      for c = 1, cols do
	 cid = cid+1
	 AllSeats[cid] = Seat.new({id=cid, row=r, col=c, x=row-1.0, y=col-1.0, rot=0, kind=0})
      end
   end
end
function seatnum()
   tex.sprint(table.maxn(AllSeats))
end
function seat(n)
   tex.sprint("\\node[rectangle, minimum size=5pt] at (",AllSeats[n].x,",",AllSeats[n].y)
end
   
