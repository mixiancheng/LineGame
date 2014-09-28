require "Obj"
require "Rules"
local MyMapLayer = class("MyMapLayer")
MyMapLayer.__index = MyMapLayer
function MyMapLayer.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, MyMapLayer)
    return target
end
function MyMapLayer:initBackLayer() --@return typeOrObject
require "MapCellNode"
    local _data=Rules._mapData
    for k,v in ipairs(_data) do
    	for i,j in ipairs(v) do
    		local _col=i
    		local _row=k
            local _obj=creatMapCellNode(j.type,_col,_row)
            Rules._node:addChild(_obj)
            if j.type~=2 then
            math.randomseed(os.time()*_col*_row)
            local _type=math.random(1,4)
            local dropObj=creatObj(_type,_col,_row)
                j["obj"]=dropObj
                Rules._node:addChild(dropObj)
            end 
    	end
    end
end
function MyMapLayer:creatObj(_type,_col,_row) --@return typeOrObject
    local x=_col*Rules.objW
    local y=_row*Rules.objH
    local temp=LineObjCreat(LintObjType[_type],_col,_row)
    temp:setPosition(x,y)
    _node:addChild(temp)
    return  temp
end
function MyMapLayer:creatObjs() --@return typeOrObject
    require "LineObj"
    for i=0, Rules.MapRow-1 do
        for j=0, Rules.MapCol-1 do
            local _row=i
            local _col=j
            math.randomseed(os.time()*i*j)
            local _type=math.random(1,4)
            self:creatObj(_type,_col,_row)
        end
    end
end
function MyMapLayer:drawLine() --@return typeOrObject
    local row=Rules.MapRow
    local col=Rules.MapCol
    local w=Rules.objW
    local h=Rules.objH
    local glNode  = gl.glNodeCreate()
    glNode:setAnchorPoint(cc.p(0,0))
    local function primitivesDraw(transform, transformUpdated)
        kmGLPushMatrix()
        kmGLLoadMatrix(transform)
        for i=0, row do
            local x1=0
            local y1=i*h
            local x2=col*w
            local y2=i*h
            cc.DrawPrimitives.drawLine(cc.p(x1,y1), cc.p(x2,y2) )
           
        end
        for i=0, row do
            local x1=i*w
            local y1=0
            local x2=i*w
            local y2=row*h
            cc.DrawPrimitives.drawLine(cc.p(x1,y1), cc.p(x2,y2) )
        end
        gl.lineWidth( 1.0 )
        cc.DrawPrimitives.drawColor4B(255,0,0,255)
        kmGLPopMatrix()
    end
    glNode:registerScriptDrawHandler(primitivesDraw)
    self:addChild(glNode)
end
function MyMapLayer:init()
--    self:drawLine()
--    Rules._mapLayer=self
end
function MyMapLayer.create()
    require "Rules"
    cclog("----->function MyMapLayer.create()")
    local layer = MyMapLayer.extend(cc.Layer:create())
    return layer
end
function CreatMapLayer() --@return typeOrObject
    cclog("function CreatMap------Layer()")
    Rules._mapLayer=MyMapLayer.create()
    Rules._mapLayer:registerScriptHandler(function(tag)
        if "enter" == tag then
            Rules._mapLayer:onEnter()
        elseif "exit" == tag then
        end
    end)
--    mapLayer:creatObjs()
    local x=Rules.objW
    local y=Rules.objH
    local w=Rules.objW+Rules.objW*Rules.MapCol
    local h=Rules.objH+Rules.objH*Rules.MapRow
    local clickNode=cc.DrawNode:create();
    local points={cc.p(x,y), cc.p(w, x), cc.p(w, h), cc.p(x, h)}
    clickNode:drawPolygon(points, table.getn(points), cc.c4f(1,0,0,0.5), 4, cc.c4f(0,0,1,1))
    Rules._node=
        cc.ClippingNode:create(clickNode);
    Rules._mapLayer:AddTouch()
    Rules._mapLayer:initBackLayer()
    Rules._mapLayer:addChild(Rules._node)
    return Rules._mapLayer
end
function MyMapLayer:onEnter()
    cclog("function MyMapLayer:onEnter()")
end
function MyMapLayer:AddTouch() --@return typeOrObject
    require "Rules"
    local  listenner = cc.EventListenerTouchOneByOne:create()
    --    listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
        Rules.MyTouch(touch)
        return true
    end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
        Rules.MyTouch(touch)
    end,cc.Handler.EVENT_TOUCH_MOVED )
    listenner:registerScriptHandler(function(touch, event)
        Rules.OnTouchEnd(touch)
    end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end