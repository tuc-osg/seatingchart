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
SPECIAL      = 5

function initRec(rows, cols)
   local cid = 0
   AllSeats["size"]=0
   AllSeats["rows"]=rows
   AllSeats["cols"]=cols
   for r = 1, rows do
      for c = 1, cols do
	 cid = cid+1
	 AllSeats[cid] = Seat.new({id=cid, row=r, col=c, x=c-(cols+1)/2, y=r-1.0, rot=0, kind=SEATEMPTY, label=tostring(cid)})
	 AllSeats["size"]=AllSeats["size"]+1
      end
   end
end

function seatDim(w,h)
   AllSeats["seatwidth"] = w
   AllSeats["seatheight"] = h
end
--[[
function seatIds()
   for ndx, v in ipairs(AllSeats) do
      tex.sprint(tostring(ndx),",")
   end
end
--]]
function findSeatAt(y,x)
   if y<0 then
      y = AllSeats["rows"] + y + 1
   end
   if x<0 then
      x = AllSeats["cols"] + x + 1
   end
   local ndx = (y-1)* AllSeats["cols"] + x
   return ndx
end

function assignSeat(ndx,l,a)
   a = a or SEATASSIGNED
   if ndx ~= nil and AllSeats[ndx].kind == SEATEMPTY then
      AllSeats[ndx].kind = a
      if l ~= nil then
	 AllSeats[ndx].label=l
      end
      return true
   else
      return false
   end
end
function assignSeatAt(y,x,l,a)
   assignSeat(findSeatAt(y,x),l,a)
end
function removeSeatAt(y,x)
   assignSeat(findSeatAt(y,x),nil,SEATREMOVED)
end
function removeAisle(c,from,to)
   for r = from, to do
      assignSeatAt(r,c,nil,AISLE)
   end
end
-- Seating
function getLabel(r,c)
   return "X"
end
function seatingSchemeInRows(rs,pat,policy)
   local numseats =  AllSeats["cols"]
   local numrows =  AllSeats["rows"]
   if rs["all"] ~= nil then
      local frow = policy["first row"]
      local rstep = policy["row sep"]
      local rres  = policy["row restart"]
      rs={}
      for r = 1, numrows do
	 if (r-frow) % rstep == 0 then
	    table.move({r}, 1, 1, #rs + 1, rs)
	 end
	 if (r-frow) == rres-1 then
	    frow = frow + rres
	 end
      end
   end
   if string.len(pat) < numseats then
      pat = string.rep(pat,math.ceil(numseats/string.len(pat)))
   end
   for _,r in ipairs(rs) do
      tex.sprint("\\typeout{**** seatingSchemeInRow called r=",r,"}")
      local step = 1
      local pndx = 1
      local seat = 1
      if policy["rtol"] then
	 step = -1
	 pndx = -1
	 seat = numseats
      end
      tex.sprint("\\typeout{ Seatscheme is ",pat,"}")
      while ((seat >= 1) and (seat<= numseats)) do
	 local curkind = AllSeats[findSeatAt(r,seat)].kind
	 tex.sprint("\\typeout{ Try seat ",seat,"(kind=",curkind,") with 'pat[",pndx,"]=",string.upper(string.sub(pat,pndx,pndx)),"'}")
	 if string.upper(string.sub(pat,pndx,pndx)) == 'X' and (curkind == SEATEMPTY) then
	    tex.sprint("\\typeout{*** Ask for assignment, seat.kind=",AllSeats[findSeatAt(r,seat)].kind,"}")
	    assignSeatAt(r,seat,getLabel(r,seat),SEATASSIGNED)
	    pndx = pndx + step
	 elseif curkind == SEATEMPTY then
	    pndx = pndx + step
	 elseif curkind == SEATREMOVED and  policy["ignore removed seats"]==false then 
	    pndx = pndx + step
	 elseif curkind == AISLE then
	    if policy["aisle restarts"] then
	       pndx = step
	    else
	       pndx = pndx + policy["aisle counts"]*step
	    end
	 end
	 seat = seat + step
      end
   end
end
	
-- Drawing
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
 
