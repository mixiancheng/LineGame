
--规则
module("Rules",package.seeall)
require "Obj"
_mapCellType={normal=1,dead=2,factory=-1}--地图块类型
_mapData={{{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil}},
    {{type=_mapCellType.dead,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil}},
    {{type=_mapCellType.dead,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil}},
    {{type=_mapCellType.dead,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil}},
    {{type=_mapCellType.dead,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil}},
    {{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.dead,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil}},
    {{type=_mapCellType.normal,obj=nil},{type=_mapCellType.dead,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil}},
    {{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil},{type=_mapCellType.normal,obj=nil}},
    {{type=_mapCellType.dead,obj=nil},{type=_mapCellType.factory,obj=nil},{type=_mapCellType.factory,obj=nil},{type=_mapCellType.factory,obj=nil},{type=_mapCellType.factory,obj=nil}}
}
MapCol=5
MapRow=8
objW=72
objH=72
MapPositonX=0
MapPositonY=0
_colorTable={cc.c4f(0,0.5,0.5,1),cc.c4f(0.5,0.5,0,1)}
-- type==1正常 2死节点不可通过 －1 工厂
--_mapData={{{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil}},
--    {{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil}},
--    {{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},},
--    {{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},},
--    {{type=1,obj=nil},{type=2,obj=nil},{type=1,obj=nil},{type=2,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil}},
--    {{type=2,obj=nil},{type=1,obj=nil},{type=2,obj=nil},{type=2,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil}},
--    {{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil}},
--    {{type=1,obj=nil},{type=2,obj=nil},{type=1,obj=nil},{type=2,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil}},
--    {{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil}},
--    {{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil},{type=1,obj=nil}},
--    {{type=-1,obj=nil},{type=-1,obj=nil},{type=-1,obj=nil},{type=-1,obj=nil},{type=-1,obj=nil},{type=-1,obj=nil},{type=-1,obj=nil}}
--    }

--_mapData={{{type=1,obj=nil}}}--1正常地块卡通过 2不可通过
--local _allObjs={}--所有掉落物体集合
local _mapCells={}--所有地图集合
local _pushObjs={}--已选中队列
_mapLayer=nil--地图
_node=nil--可视窗口
---
--
--获得_mapData数据
function get_mapData_cell(_row,_col) --@return typeOrObject
    if _mapData[_row]~=nil then
        return _mapData[_row][_col]
end
end
---
--
--是否可通过单元
function isAliveCel(_temp) --@return typeOrObject
    return (_temp~=nil and _temp.type~=2 and _temp.obj==nil)
end
---
--
--是否死节点
function isDeadCel(_row,_col) --@return typeOrObject
    local _temp=get_mapData_cell(_row,_col)
    if _temp~=nil and _temp.type==2 then return true end 
    return false
end
local _paths={}
function findPath(_row,_col) --@return typeOrObject
--    cclog("_row===>%d,_col=====>%d",_row,_col)
    local _center=get_mapData_cell(_row,_col)
    local _left=get_mapData_cell(_row,_col-1)
    local _right=get_mapData_cell(_row,_col+1)
    local _point=nil
    if isAliveCel(_center) then--深度
        --    cclog("findCenter")
        _point=cc.p(_row,_col)
        return _point
--        findPath(_row-1,_col)
--        table.insert(_paths,_point)
    end
--    cclog("_row===>%d,_col=====>%d",_row,_col)
    if isDeadCel(_row+1,_col-1) and isAliveCel(_left) then --左子点
        --    cclog("findLeft")
        _point=cc.p(_row,_col-1)
        return _point
--        findPath(_row-1,_col-1)
--        table.insert(_paths,_point)
    end
    if isDeadCel(_row+1,_col+1) and isAliveCel(_right) then --右子点
        --    cclog("findRight")
        _point=cc.p(_row,_col+1)
        return _point
--        findPath(_row-1,_col+1)
--        table.insert(_paths,_point)
    end
    return nil
end
function find(_obj) --@return typeOrObject
end
---
--
--爆破一个单元
function bomb(_obj) --@return typeOrObject
    local _table=_mapData[_obj._row][_obj._col]
    _table.obj=nil
    _obj:Bomb()
end
---
--
--爆炸队列
function bombObjs(_objs) --@return typeOrObject
    if _objs==nil then return end
        if #_objs<3 then
            for k,v in ipairs(_objs) do
                v:setSelect(false)
            end
            _pushObjs=nil-->清除队列
            return
        end
    for k,v in ipairs(_objs) do
        bomb(v)
    end
    _pushObjs=nil-->清除队列
end
---
--
--获得objs索引
function getIndexInTable(_table,_obj) --@return typeOrObject
    for k,v in ipairs(_table) do
        if v:isEqual(_obj) then return k end
end
return -1
end
---
--
--判断是否相邻
function isAdjoin(_obj1,_obj2) --@return typeOrObject
    local _pa=_obj1:getMapPoint()
    local _pb=_obj2:getMapPoint()
    local _len=cc.pGetDistance(_pa,_pb)
    --    cclog("len=====%d",_len)
    if _len<=1.5 then
        --    cclog("------------>")
        return true
    end
    return false
end
---
--
--x y 获得物体
---
function getObjByPoint(x,y) --@return typeOrObject
    --    cclog("x==%d,y==%d",x,y)
    for k,v in ipairs(_mapData) do
        for i,j in ipairs(v) do
            if j.obj~=nil then
            if j.obj:containsTouchLocation(x,y) then
--                cclog("<---->x==%d,y==%d",j.obj._col,j.obj._row)
                return j.obj end
                end
        end
end
end
---
--
--是否已经存在于删除队列
function checkPushList(_obj) --@return typeOrObject
    for k,v in ipairs(_pushObjs) do
        if (v:isEqual(_obj)==true) then return true end
end
return false
end
---
--
--添加删除队列
function PushList(_obj) --@return typeOrObject
    if _pushObjs==nil or #_pushObjs<1 then
        _pushObjs={}
        table.insert(_pushObjs,_obj)
        _obj:setSelect(true)-->debug
        return
end
if _obj._type~=_pushObjs[#_pushObjs]._type then return end -->类型不同
if checkPushList(_obj)==true then-->已经存在于队列
    --    cclog("----->")
    local _last=_pushObjs[#_pushObjs]
    if _last:isEqual(_obj) then return end -->处于队尾
    local _index=getIndexInTable(_pushObjs,_obj)-->位置索引
    while _index~=#_pushObjs do
        _pushObjs[#_pushObjs]:setSelect(false)-->debug
        table.remove(_pushObjs,#_pushObjs)
    end
    return
end
-------------------不属于队列--------------------------
local _last=_pushObjs[#_pushObjs]
local _bool=isAdjoin(_last,_obj)
if _bool then
    table.insert(_pushObjs,_obj)
    _obj:setSelect(true)-->debug
end -->与队尾相邻
end
---
--
--处理触摸事件
function MyTouch(_touch) --@return typeOrObject
    if isMoveOver()~=true then 
--        cclog("function OnTouchEnd-->(touch)")
    return end
    local  x=_touch:getLocation().x
    local  y=_touch:getLocation().y
    --        cclog("-->xx==%d,yy==%d",x,y)
    local _obj=getObjByPoint(x,y)--触摸物体
    if _obj==nil then return true end
    PushList(_obj)-->添加删除队列
end
function dropAction() --@return typeOrObject

end
function moveObj(_obj) --@return typeOrObject
if _obj:isNormal() then
	local _col=_obj._col
	local _row=_obj._row
	local  newPoint=findPath(_row-1,_col)
	if newPoint~=nil then
	local oldCel=get_mapData_cell(_row,_col)
        local newCel=get_mapData_cell(newPoint.x,newPoint.y)
        newCel.obj=_obj
        oldCel.obj=nil
--        cclog("------>")
	_obj:MovePoint(newPoint.x,newPoint.y)
	end
	end
end
function isMoveOver() --@return typeOrObject
    for k,v in ipairs(_mapData) do
        for i,j in ipairs(v) do
            local _data=get_mapData_cell(k,i)
            if _data~=nil then 
            if _data.obj==ObjState.droping then return false end 
            if _data.type~=2 and _data.obj==nil then 
            return false 
            end 
            end 
        end
end
return true
end
---
--
--添加队列完成
function OnTouchEnd(touch) --@return typeOrObject
 if _pushObjs==nil or #_pushObjs<1  then return end 
if isMoveOver()~=true then return end
--cclog("-->")
    bombObjs(_pushObjs)
        for k,v in ipairs(_mapData) do
            for i,j in ipairs(v) do
                local _data=get_mapData_cell(k,i)
                if _data.obj~=nil  then
                    _data.obj._state= ObjState.normal
                end
            end
        end
end