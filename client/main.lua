screen = Vector2(guiGetScreenSize());
middle = Vector2(screen.x / 2, screen.y / 2);

editor = {};
editor.types = {
    ["move"] = {["x"] = true, ["y"] = true, ["z"] = true},
    ["rotate"] = {["rx"] = true, ["ry"] = true, ["rz"] = true},
};

myShader_raw_data = [[
	texture tex;
	technique replace {
		pass P0 {
			Texture[0] = tex;
		}
	}
]]

function startEditAccessory(object, name, positions)
    if editor.active then
        return
    end
    local object_infos = getObjectInfo(getElementModel(object), "objectid");
    if object_infos then
        editor.active = true;
        editor.movetype = "move";
        editor.object = object;
        editor.objectname = name;
        editor.objmovepreview = createObject(1239, 0, 0, 0)
        editor.bone = object_infos["Bone"];
        editor.positions = positions or object_infos["Default Attach"];
        
        exports.pAttach:attach(editor.objmovepreview, localPlayer, editor.bone, 0, 0, 0)
        exports.pAttach:setPositionOffset(editor.objmovepreview, editor.positions["x"], editor.positions["y"], editor.positions["z"])

        editor.lines = {};

        setObjectScale(editor.objmovepreview, 0)
        setElementCollisionsEnabled(editor.objmovepreview, false)

        for i, v in ipairs({"x", "y", "z"}) do
        
            local line = createObject(1239, 0, 0, 0)
            local color = tocolor(255, 255, 255)
            setObjectScale(line, 0)
            setElementCollisionsEnabled(line, false)
            if v == "x" then
                attachElements(line, editor.objmovepreview, 0, 0, config.main["Main"]["Distance"])
                color = tocolor(50, 210, 50)
            elseif v == "y" then
                attachElements(line, editor.objmovepreview, 0, config.main["Main"]["Distance"], 0)
                color = tocolor(50, 50, 210)
            elseif v == "z" then
                attachElements(line, editor.objmovepreview, config.main["Main"]["Distance"], 0, 0)
                color = tocolor(210, 50, 50)
            end

            editor.lines[v] = {};
            editor.lines[v]["object"] = line;
            editor.lines[v]["color"] = color;

        end

        addEventHandler("onClientRender", root, renderDX)
        addEventHandler("onClientPreRender", root, renderLines)
        addEventHandler("onClientPreRender", root, renderIcons)
        addEventHandler("onClientCursorMove", root, moveCursorObject)
        addEventHandler("onClientClick", root, clickMoveObject)
    end
end
addEvent("startEditAccessory", true)
addEventHandler("startEditAccessory", root, startEditAccessory)

function stopEditAccessory()
    removeEventHandler("onClientRender", root, renderDX)
    removeEventHandler("onClientPreRender", root, renderLines)
    removeEventHandler("onClientPreRender", root, renderIcons)
    removeEventHandler("onClientCursorMove", root, moveCursorObject)
    removeEventHandler("onClientClick", root, clickMoveObject)
    for i, v in ipairs(editor.lines) do
        destroyElement(v)
    end
    destroyElement(editor.objmovepreview)
    triggerServerEvent("editAccessory", localPlayer, localPlayer, editor.object, editor.positions)
    editor.active = false;
end

function removeAccessory()
    removeEventHandler("onClientRender", root, renderDX)
    removeEventHandler("onClientPreRender", root, renderLines)
    removeEventHandler("onClientPreRender", root, renderIcons)
    removeEventHandler("onClientCursorMove", root, moveCursorObject)
    removeEventHandler("onClientClick", root, clickMoveObject)
    for i, v in ipairs(editor.lines) do
        destroyElement(v)
    end
    destroyElement(editor.objmovepreview)
    triggerServerEvent("removeAccessory", localPlayer, localPlayer, editor.object, editor.objectname)
    editor.active = false;
end

function renderDX()
    dxDrawImage(middle.x - 106, 33, 211, 39, "assets/images/border.png", 0, 0, 0, tocolor(57, 57, 57), false)

    dxDrawImage(middle.x - 67, 44, 17, 16, "assets/images/move.png", 0, 0, 0, tocolor(255, 255, 255), false)
    dxDrawImage(middle.x - 31, 46, 23, 14, "assets/images/rotate.png", 0, 0, 0, tocolor(255, 255, 255), false)
    dxDrawImage(middle.x + 11, 44, 17, 16, "assets/images/remove.png", 0, 0, 0, tocolor(255, 255, 255), false)
    dxDrawImage(middle.x + 47, 44, 17, 16, "assets/images/ready.png", 0, 0, 0, tocolor(255, 255, 255), false)
end

function renderIcons()
    for i, line in pairs(editor.lines) do
        local x, y, z = getElementPosition(line["object"])
        local x, y = getScreenFromWorldPosition(x, y, z)
        if x and y then 
            dxDrawImage(x - 13, y - 13, 25, 25, "assets/images/circle.png", 0, 0, 0, tocolor(57, 57, 57), false)
            dxDrawImage(x - 8, y - 7, 14, 14, "assets/images/"..editor.movetype..".png", 0, 0, 0, selected_move == i and tocolor(207, 199, 64) or tocolor(255, 255, 255))
        end
    end
    if selected_move and not isCursorShowing() then
        selected_move = nil;
    end
end

function renderLines()
    --[[for i, line in pairs(editor.lines) do
        local x, y, z = getElementPosition(line["object"])
        local ox, oy, oz = getElementPosition(editor.objmovepreview)
        dxDrawLine3D(x, y, z, ox, oy, oz, line["color"], 1.5)
    end]]--
    for i, line in pairs(editor.lines) do
        local x, y, z = getElementPosition(line["object"])
        local ox, oy, oz = getElementPosition(editor.objmovepreview)
        
        local x, y = getScreenFromWorldPosition(x, y, z)
        local ox, oy = getScreenFromWorldPosition(ox, oy, oz)
        if x and y and ox and oy then
            dxDrawLine(x, y, ox, oy, line["color"], config.main["Main"]["Line widht"])
        end
    end
end

function moveCursorObject(_, _, x, y, worldX, worldY, worldZ)
    if isCursorShowing() then
        if editor.types[editor.movetype][selected_move] then

            if not editor.cursor then
                editor.cursor = {x, y, worldX, worldY, worldZ};
            end

            local cur_x, cur_y, cursor_wx, cursor_wy, cursor_wz = unpack(editor.cursor)

            localisation = {
                X = {cursor_wx, worldX},
                Y = {cursor_wy, worldY},
                Z = {cursor_wz, worldZ}
            }

            if string.find(selected_move, "x") then
                CACHE_CHECK, CURR_CHECK = unpack(localisation.X);
            elseif string.find(selected_move, "y") then
                CACHE_CHECK, CURR_CHECK = unpack(localisation.Y);
            elseif string.find(selected_move, "z") then
                CACHE_CHECK, CURR_CHECK = unpack(localisation.Z);
            else
                return
            end

            if CURR_CHECK < CACHE_CHECK then
                editor.positions[selected_move] = editor.positions[selected_move] - (string.find(selected_move, "r") and config.main["Main"]["Add pos rot"] or config.main["Main"]["Add pos"]);
            elseif CURR_CHECK > CACHE_CHECK then
                editor.positions[selected_move] = editor.positions[selected_move] + (string.find(selected_move, "r") and config.main["Main"]["Add pos rot"] or config.main["Main"]["Add pos"]);
            end

            exports.pAttach:setPositionOffset(editor.objmovepreview, editor.positions["x"], editor.positions["y"], editor.positions["z"])

            exports.pAttach:setPositionOffset(editor.object, editor.positions["x"], editor.positions["y"], editor.positions["z"])
            exports.pAttach:setRotationOffset(editor.object, editor.positions["rx"], editor.positions["ry"], editor.positions["rz"])

            setCursorPosition(cur_x, cur_y)

        end
    end
end

function clickMoveObject(button, state)
    if button == "left" and state == "down" then
        for i, line in pairs(editor.lines) do
            i = editor.movetype == "move" and i or "r"..i
            local x, y, z = getElementPosition(line["object"])
            local x, y = getScreenFromWorldPosition(x, y, z)
            if x and y then
                if isMouseInPosition(x - 12.5, y - 12.5, 25, 25) then
                    for i2, v2 in pairs(editor.types[editor.movetype]) do 
                        if i == i2 then
                            selected_move = i2;
                        end
                    end
                    return
                end
            end
        end
        if isMouseInPosition(middle.x + 47, 44, 17, 16) then
            stopEditAccessory()
        elseif isMouseInPosition(middle.x + 11, 44, 17, 16) then
            removeAccessory()
        elseif isMouseInPosition(middle.x - 67, 44, 17, 16) then
            editor.movetype = "move";
        elseif isMouseInPosition(middle.x - 31, 46, 23, 14) then
            editor.movetype = "rotate";
        end
    elseif button == "left" and state == "up" then
        selected_move = nil;
        editor.cursor = nil;
    end
end

outputChatBox("Sistema de acessórios desenvolvido por Sousa#0001")