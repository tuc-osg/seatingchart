Seat = {
   id = nil,
   row = 0,
   col = 0,
   x = 0,
   y = 0,
   rrow = 0,
   rcol = 0,
   rotate = 0,
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

function initSeating(rows, cols, shape)
   local cid = 0
   AllSeats.size=0
   AllSeats.rows=rows
   AllSeats.cols=cols
   tex.sprint("\\typeout{*** initSeating CALLED, ndx: }")
   if shape == "rect" then
      for r = 1, rows do
	 for c = 1, cols do
	    cid = cid+1
	    AllSeats[cid] = Seat.new({id=cid, row=r, col=c, x=c-(cols+1)/2, y=r-1.0, rrow=0, rcol=0, rotate=0, kind=SEATEMPTY, label=tostring(cid)})
	    AllSeats.size=AllSeats.size+1
	 end
      end
   elseif shape ==  "arc" then
      local arc=120
      local d=8
      local rot
      local x
      local y
      local phi
      for r = 1, rows do
	 for c = 1, cols do
	    cid = cid+1
	    phi=(c-(cols+1)/2)/(2*r+(cols/2))*arc*math.pi/180
	    x = (d+r)*math.sin(phi)
	    y= (d+r)*math.cos(phi)-d/2
	    rot=-phi/math.pi*180
	    AllSeats[cid] = Seat.new({id=cid, row=r, col=c,
				      rotate=rot,
				      x=x,
				      y=y,
				      rrow=0, rcol=0, kind=SEATEMPTY, label=tostring(cid)})
	    AllSeats.size=AllSeats.size+1
	 end
      end
   end
   
end

function initArc(rows, cols)
end

function seatDim(w,h)
   AllSeats.seatwidth = w
   AllSeats.seatheight = h
end

function findSeatAt(y,x)
   if y<0 then
      y = AllSeats.rows + y + 1
   end
   if x<0 then
      x = AllSeats.cols + x + 1
   end
   if x>AllSeats.cols or y > AllSeats.rows then
      tex.sprint("\\PackageError{\\packagename}{Index out of bound}{Check the used coordinates.}")
   end
   local ndx = (y-1)* AllSeats.cols + x
   return ndx
end

function assignSeat(ndx,d)
   local kind = d.kind or SEATASSIGNED
   local runningrow = d.rr or 0
   local runnigseat = d.rc or 0
   -- tex.sprint("\\typeout{*** AllSeats[ndx] ",AllSeats,"[",ndx,"]}")
   -- tex.sprint("\\typeout{ kind=",kind,", text='",d.label,"', rr=",runningrow,", rs=",runnigseat,"}")
   if ndx ~= nil and AllSeats[ndx].kind == SEATEMPTY then
      AllSeats[ndx].kind = kind
      AllSeats[ndx].label=d.label or AllSeats[ndx].label
      AllSeats[ndx].rrow=runningrow
      AllSeats[ndx].rcol=runnigseat
      return true
   else
      return false
   end
end
function assignSeatAt(y,x,d)
   assignSeat(findSeatAt(y,x),d)
end
function removeSeatAt(y,x)
   assignSeat(findSeatAt(y,x),{kind=SEATREMOVED})
end
function removeAisle(c,from,to)
   for r = from, to do
      assignSeatAt(r,c,{kind=AISLE})
   end
end
-- Seating
--function getLabel(r,c,rr,cc)
   -- tex.sprint("\\typeout{ row:",r,"(",rr,"), seat:",c,"(",cc,")}")
  -- return 'X'
   -- tex.sprint("\\arabic{r}-alph{cc}")
-- end
function seatingSchemeInRows(pat,policy)
   local numseats =  AllSeats.cols
   local numrows =  AllSeats.rows
   local frow = policy["first row"]
   local lrow = policy["last row"]
   local rstep = policy["row sep"]
   local rres  = policy["row restart"]
   local runningrow = 1
   rs={}
   for r = frow, lrow do
      if (r-frow) % rstep == 0 then
	 table.move({{[1]=r,[2]=runningrow}}, 1, 1, #rs + 1, rs)
	 runningrow=runningrow+1
      end
      if (r-frow) == rres-1 then
	 frow = frow + rres
      end
   end
   -- tex.sprint("\\typeout{**** pattern=",pat,", numseats=",numseats,"}")
   if string.len(pat) < numseats then
      pat = string.rep(pat,math.ceil(numseats/string.len(pat)))
   end
   for _,row in pairs(rs) do
      local r=row[1]
      local rr=row[2]
      -- tex.sprint("\\typeout{**** seatingSchemeInRow called r=",r,"}")
      local step = 1
      local pndx = 1
      local seat = 1
      if policy["rtol"] then
	 step = -1
	 pndx = -1
	 seat = numseats
      end
      local runningseat=1
      -- tex.sprint("\\typeout{ Seatscheme is ",pat,"}")
      while ((seat >= 1) and (seat<= numseats)) do
	 local curkind = AllSeats[findSeatAt(r,seat)].kind
	 -- tex.sprint("\\typeout{ Try seat ",seat,"(kind=",curkind,") with 'pat[",pndx,"]=",string.upper(string.sub(pat,pndx,pndx)),"'}")
	 if string.upper(string.sub(pat,pndx,pndx)) == 'X' and (curkind == SEATEMPTY) then
	 --   tex.sprint("\\typeout{*** Ask for assignment, rr=",rr,", rc=",runningseat,"}")
	    assignSeatAt(r,seat,{ kind=SEATASSIGNED, rr=rr, rc=runningseat})
	    runningseat=runningseat+1
	    pndx = pndx + step
	 elseif curkind == SEATEMPTY then
	    pndx = pndx + step
	 elseif curkind == SEATREMOVED and  policy["ignore removed seats"]==false then 
	    pndx = pndx + step
	    runningseat=runningseat+1
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
   local width = AllSeats.seatwidth
   local height = AllSeats.seatheight
   tex.sprint("\\node[rectangle,empty seat, minimum width=",width,", minimum height=",height,",rotate=",s.rotate,"] at (",s.x,",",s.y,") {};")
   tex.sprint("\\node[empty label, minimum width=",width,",rotate=",s.rotate,"] at (",s.x,",",s.y,")"..
	      "{\\tucemptylabelformat{",s.row,"}{",s.col,"}{",s.rrow,"}{",s.rcol,"}{",s.label,"}};")
end

function seatassigned(s) 
   local width = AllSeats.seatwidth
   local height = AllSeats.seatheight
   tex.sprint("\\node[rectangle,assigned seat, minimum width=",width,", minimum height=",height,",rotate=",s.rotate,"] at (",s.x,",",s.y,") {Xy};")
   tex.sprint("\\node[assigned label,minimum width=",width,",rotate=",s.rotate,"] at (",s.x,",",s.y,")"..
   	      "{\\tucsassignedlabelformat{",s.row,"}{",s.col,"}{",s.rrow,"}{",s.rcol,"}{",s.label,"}};")
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
	 -- tex.sprint("\\typeout{ *** kind=",s.kind,", x=",s.col,", y=",s.row,"}")
	 func = case_tbl[s.kind]
	 if func ~= nil then
	    func(s)
	 end
      end
   end
end
 
