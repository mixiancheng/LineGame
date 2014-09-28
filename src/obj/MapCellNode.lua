require "Rules"
radSeed=0
MapCellNode=class("MapCellNode",function() --@return typeOrObject
	return cc.Node:create()
end)
MapCellNode.__index=MapCellNode
MapCellNode._col=0
MapCellNode._row=0
MapCellNode._type=0
MapCellNode._child=1
function MapCellNode:initData(_type,_col,_row) --@return typeOrObject
	self._type=_type
	self._col=_col
	self._row=_row
	self._child=nil
	self._radNum=1
    self:setContentSize(Rules.objW,Rules.objH)
    local _x=_col*Rules.objW
    local _y=_row*Rules.objH
--    cclog("map_x===%d,y===%d",_x,_y)
    self:setPosition(_x,_y)
    if _type~=-1 then 
    local draw=cc.DrawNode:create()
    points = { cc.p(0,0),cc.p(0,Rules.objH),cc.p(Rules.objW,Rules.objH),cc.p(Rules.objW,0)}
    local _color=Rules._colorTable
    local Index=_type
    if self._type==-1 then Index=1 end 
    draw:drawPolygon(points, table.getn(points), _color[Index], 1, cc.c4f(0,0,1,1))
    self:addChild(draw)
    end
    function MyUpdata(parameters) --@return typeOrObject
        if self._type==-1 then
            local _mapCle=Rules.get_mapData_cell(self._row,self._col)
            if _mapCle.obj==nil then
            local str=tostring(os.time()):reverse():sub(1, 6)
                radSeed=radSeed+12345
            if radSeed>10000000 then radSeed=0 end 
                math.randomseed(radSeed+str)
                local radType=math.random(1,4)
                local newObj= creatObj(radType,self._col,self._row)
            newObj._state=ObjState.normal
            _mapCle.obj=newObj
                Rules._node:addChild(newObj)
            end
    end
    end
    local scheduler =cc.Director:getInstance():getScheduler()
    scheduler:scheduleScriptFunc(MyUpdata,0, false)
end
function creatMapCellNode(_type,_col,_row) --@return typeOrObject
	local _temp=MapCellNode.new()
	_temp:initData(_type,_col,_row)
    return _temp
end