require "Config"
Obj=class("Obj",function () --@return typeOrObject
	return cc.Node:create()
end)
Obj.__index=Obj
Obj._col=0--列
Obj._row=0--行
Obj._type=0--类型
Obj._avt=nil--形象
Obj._select=false--是否被选中
Obj._paths={}
Obj._state=-1
Obj._isfactory=false
ObjState={normal=0,droping=1,dead=-3}
ObjType={"one","two","three","four"}
function Obj:isNormal() --@return typeOrObject
	if self._state==ObjState.normal then
		return true
	end
	return false
end
function Obj:movePath(debugPath) --@return typeOrObject
    for k,v in ipairs(debugPath) do
		local _col=v.x
		local _row=v.y
--		cclog("path_col==%d,row==%d",_col,_row)
        local _x=_col*Rules.objW
        local _y=_row*Rules.objH
        self:setPosition(_x,_y)
	end
end
function Obj:MovePoint(_row,_col) --@return typeOrObject
    function moveOver(sender) --@return typeOrObject
        self._col=_col
        self._row=_row
        local  newPoint=Rules.findPath(self._row-1,self._col)
        if newPoint==nil then self._state=ObjState.normal else
            local oldCel=Rules.get_mapData_cell(self._row,self._col)
            local newCel=Rules.get_mapData_cell(newPoint.x,newPoint.y)
            newCel.obj=self
            oldCel.obj=nil
            self:MovePoint(newPoint.x,newPoint.y)
        end
    end
    local _x=_col*Rules.objW
    local _y=_row*Rules.objH
    self._state=ObjState.droping
--	self._col=_col
--	self._row=_row
	local _moveAction=cc.MoveTo:create(0.025,cc.p(_x,_y))
    local _action = cc.Sequence:create(_moveAction,cc.CallFunc:create(moveOver))
    self:runAction(_action)
--    self._state=ObjState.normal
end
---
--爆炸
--
function Obj:Bomb() --@return typeOrObject
    self._state=ObjState.dead
    self:setVisible(false)
    self:removeFromParent(true)-->删除形象
end
function Obj:getMapPoint() --@return typeOrObject
	return cc.p(self._col,self._row)
end
function Obj:isEqual(_obj) --@return typeOrObject
	if self._col==_obj._col and self._row==_obj._row and self._type==_obj._type then return true end
	return false
end
function Obj:setSelect(var) --@return typeOrObject
--cclog("----------->")
    if var then self._avt:setScale(0.5,0.5) return end 
    self._avt:setScale(0.8,0.8)
	self._select=var
end
function Obj:containsTouchLocation(x,y) --@return typeOrObject
    local position = cc.p(self:getPosition())
    local  s = self:getContentSize()
--    cclog("x==%d,y==%d",x,y)
--    cclog("x==%d,y==%d,w===%d,h===%d",position.x,position.y,s.width,s.height)
    local touchRect = cc.rect(position.x, position.y, s.width-20, s.height-20)
    local b = cc.rectContainsPoint(touchRect, cc.p(x,y))
--    if b==true then cclog("--------->contain") end 
    return b
end
---
--
--初始化数据
function Obj:initData(_type,_col,_row) --@return typeOrObject
	self._type=_type
	self._col=_col
	self._row=_row
    self:setContentSize(Rules.objW,Rules.objH)
    local str=string.format("%s.png",ObjType[_type])
--    cclog(str)
    self._avt=cc.Sprite:create(str)
    self:addChild(self._avt)
    self._avt:setScale(0.8,0.8)
    self._avt:setAnchorPoint(0.5,0.5)
    self._avt:setPosition(Rules.objW/2,Rules.objH/2)
    local _x=_col*Rules.objW
    local _y=_row*Rules.objH
    self:setPosition(_x,_y)
    self._state=-1
    ---
    --
    --
    function MyUpdata(parameters) --@return typeOrObject
    if self._state==Obj.dead then return end 
        if self._state==ObjState.normal then--
            local _tempcol=self._col
            local _temprow=self._row-1
            local  newPoint=Rules.findPath(_temprow,_tempcol)
            if newPoint~=nil then
                self._state=ObjState.droping
                local oldCel=Rules.get_mapData_cell(self._row,self._col)
                local newCel=Rules.get_mapData_cell(newPoint.x,newPoint.y)
                newCel.obj=self
                oldCel.obj=nil
                self:MovePoint(newPoint.x,newPoint.y)
            end
        return 
        end
    end
    local scheduler =cc.Director:getInstance():getScheduler()
    scheduler:scheduleScriptFunc(MyUpdata,0.025, false)
end
---
--
--创建对象
function creatObj(_type,_col,_row) --@return typeOrObject
	local _temp=Obj.new()
	_temp:initData(_type,_col,_row)
	return _temp   
end