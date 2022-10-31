equip = {};

equip.showing = false;

equip.alpha = 0;
equip.tick = getTickCount();

equip.circle = 0;

equip.scroll = 0;
equip.scroll2 = 0;
equip.scrollTick = getTickCount();

equip.renderDownMax = 0;
equip.renderAnimations = {};

equip.pos = Vector2(middle.x - (866/2), middle.y - 150)

equip.fonts = {
    ["Inter-Bold"] = {
        [8] = dxCreateFont("assets/fonts/Inter-Bold.ttf", 8);
        [11] = dxCreateFont("assets/fonts/Inter-Bold.ttf", 11);
        [13] = dxCreateFont("assets/fonts/Inter-Bold.ttf", 13);
    },
    ["Inter-ExtraBold"] = {
        [13] = dxCreateFont("assets/fonts/Inter-ExtraBold.ttf", 13);
    },
}

function equip.render()
    if equip.showing then
        equip.alpha = interpolateBetween(equip.alpha, 0, 0, 1, 0, 0, (getTickCount()-equip.tick)/800, "Linear")
        equip.pos.x, equip.pos.y = interpolateBetween(equip.pos.x, equip.pos.y, 0, middle.x - 433, middle.y - 245, 0, (getTickCount()-equip.tick)/500, "OutQuad")
        equip.scroll = interpolateBetween(equip.scroll, 0, 0, equip.scroll2, 0, 0, (getTickCount()-equip.scrollTick)/500, "OutQuad")
    else
        equip.alpha = interpolateBetween(equip.alpha, 0, 0, 0, 0, 0, (getTickCount()-equip.tick)/500, "Linear")
        equip.pos.x, equip.pos.y = interpolateBetween(equip.pos.x, equip.pos.y, 0, middle.x - 433, middle.y - 150, 0, (getTickCount()-equip.tick)/800, "InQuad")
        equip.scroll = interpolateBetween(equip.scroll, 0, 0, 0, 0, 0, (getTickCount()-equip.scrollTick)/100, "OutQuad")
    end

    if not equip.showing and equip.alpha <= 0.1 then
        removeEventHandler("onClientRender", root, equip.render)
        destroyElement(equip.renderTarget)
    end

    dxDrawImage(equip.pos.x, equip.pos.y, 866, 489, "assets/images/shop/background.png", 0, 0, 0, tocolor(255, 255, 255, 255 * equip.alpha), false)

    dxDrawText("Seus acessórios", equip.pos.x + 27, equip.pos.y + 19, 106, 15, tocolor(255, 255, 255, 255 * equip.alpha), 0.7, equip.fonts["Inter-ExtraBold"][13], "center", "center")
    dxDrawRectangle(equip.pos.x + 27, equip.pos.y + 39, 107, 2, tocolor(26, 26, 26, 255 * equip.alpha), false)

    if equip.accessories and isElement(equip.renderTarget) then
        dxDrawImage(equip.pos.x + 49, equip.pos.y + 61, 768, 396, equip.renderTarget, 0, 0, 0, tocolor(255, 255, 255, 255 * equip.alpha), false)
        
        local c = 0;
        local r = 0;

        dxSetRenderTarget(equip.renderTarget, true)
        dxSetBlendMode("modulate_add")
            for i, v in ipairs(equip.accessories) do
                local pos = Vector2(195 * c, 136 * r)
                
                local accessoryInfos = config.main["Accessories"][v.accessory]
				
				if accessoryInfos then
					if not equip.renderAnimations[accessoryInfos["Name"].." "..accessoryInfos["Image"]] then
						equip.renderAnimations[accessoryInfos["Name"].." "..accessoryInfos["Image"]] = 0;
					end

					if isMouseInPosition(equip.pos.x + 49 + pos.x, equip.pos.y + 61 + pos.y - equip.scroll, 183, 124) then
						equip.renderAnimations[accessoryInfos["Name"].." "..accessoryInfos["Image"]] = interpolateBetween(equip.renderAnimations[accessoryInfos["Name"].." "..accessoryInfos["Image"]], 0, 0, 5, 0, 0, (getTickCount()-equip.scrollTick)/100, "Linear")
					else
						equip.renderAnimations[accessoryInfos["Name"].." "..accessoryInfos["Image"]] = interpolateBetween(equip.renderAnimations[accessoryInfos["Name"].." "..accessoryInfos["Image"]], 0, 0, 0, 0, 0, (getTickCount()-equip.scrollTick)/100, "Linear")
					end

					pos.y = pos.y - equip.renderAnimations[accessoryInfos["Name"].." "..accessoryInfos["Image"]];

					dxDrawImage(pos.x, pos.y - equip.scroll, 183, 124, "assets/images/shop/container.png", 0, 0, 0, tocolor(255, 255, 255, 255 * equip.alpha), false)
					dxDrawText(accessoryInfos["Name"], pos.x, pos.y + 102 - equip.scroll, 183, 22, tocolor(255, 255, 255, 255 * equip.alpha), 0.7, equip.fonts["Inter-Bold"][8], "center", "center")
					dxDrawImage(pos.x, pos.y - equip.scroll, 183, 124, "assets/images/shop/items/"..accessoryInfos["Image"], 0, 0, 0, tocolor(255, 255, 255, 255 * equip.alpha), false)
				
					c = c + 1;
					if c == 4 then
						r = r + 1;
						c = 0;
					end
				end
            end
        dxSetBlendMode("blend")
        dxSetRenderTarget()

        equip.renderDownMax = (136 * r)

    end

    if equip.selected then

        local alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount()-equip.selectTick)/500, "Linear")
        local accessoryInfos = config.main["Accessories"][equip.selected]

        dxDrawImage(equip.pos.x, equip.pos.y, 866, 489, "assets/images/shop/background.png", 0, 0, 0, tocolor(255, 255, 255, 198.9 * alpha), false)
        dxDrawImage(equip.pos.x + 302, equip.pos.y + 59, 249, 186, "assets/images/shop/items/"..accessoryInfos["Image"], 0, 0, 0, tocolor(255, 255, 255, 255 * alpha), false)
        dxDrawText(accessoryInfos["Name"], equip.pos.x + 341, equip.pos.y + 223, 183, 22, tocolor(255, 255, 255, 255 * alpha), 0.7, equip.fonts["Inter-Bold"][13], "center", "center")

        dxDrawImage(equip.pos.x + 425, equip.pos.y + 345, 15, 15, "assets/images/shop/hands.png", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha), false)

        dxDrawImageSection(equip.pos.x + 408, equip.pos.y + 327, 50, 50 - equip.circle/100*50, 0, 0, 50, 50 - equip.circle/100*50, "assets/images/shop/circle.png", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha), false)
        
        if equip.circle > 0 then
            dxDrawImageSection(equip.pos.x + 408, equip.pos.y + 327 + 50, 50, -equip.circle/100*50, 0, 0, 50, -equip.circle/100*50, "assets/images/shop/circle.png", 0, 0, 0, tocolor(193, 70, 70, 255 * alpha))   
        end

        if isMouseInPosition(equip.pos.x + 408, equip.pos.y + 327, 50, 50) and getKeyState("mouse1") then
            equip.circle = math.min(100, equip.circle + 2);
        else
            equip.circle = math.max(0, equip.circle - 2);
        end

        if equip.circle == 100 then
            triggerServerEvent("equipAccessory", localPlayer, localPlayer, equip.selected, nil)
            equip.open();
        end

    end

    equip.scrollTick = getTickCount();

end

function equip.open()
    equip.showing = not equip.showing;
    equip.selected = nil;
    equip.tick = getTickCount();
    equip.scrollTick = getTickCount();
    equip.circle = 0;
    showCursor(equip.showing)
    triggerServerEvent("returnPlayerAccessories", localPlayer, localPlayer)
    if equip.showing and not isEventHandlerAdded("onClientRender", root, equip.render) then
        addEventHandler("onClientRender", root, equip.render)
        equip.renderTarget = dxCreateRenderTarget(768, 396, true)
    end
end
addEvent("openAccessoriesEquip", true)
addEventHandler("openAccessoriesEquip", root, equip.open)

addEventHandler("onClientClick", root, function(button, state)
    if equip.showing then
        if button == "left" and state == "down" then
            if not equip.selected then

                local c = 0;
                local r = 0;

                for i, v in ipairs(equip.accessories) do
                    local pos = Vector2(195 * c, 136 * r)
                    
                    if isMouseInPosition(equip.pos.x + 49 + pos.x, equip.pos.y + 61 + pos.y - equip.scroll, 183, 124) then
                        equip.selected = v["accessory"];
                        equip.selectTick = getTickCount();
                    end

                    c = c + 1;
                    if c == 4 then
                        r = r + 1;
                        c = 0;
                    end
                end

            end
        end
    end
end)

bindKey("backspace", "down", function()
    if equip.showing then
        if not equip.selected then
            equip.open();
        else
            equip.selected = nil;
        end
    end
end)

addEventHandler("onClientKey", root, function(key, press)
    if equip.showing then
    
        if key == "mouse_wheel_down" then
            equip.scroll2 = math.min(equip.scroll2 + 15, equip.renderDownMax);
        elseif key == "mouse_wheel_up" then
            equip.scroll2 = math.max(0, equip.scroll2 - 15);
        elseif key == "space" then
            equip.scroll2 = 0;
        end


    end

    if not press and string.lower(key) == string.lower(config.main["Main"]["Key equip"]) then
        equip.open();
    end

end)

addEvent("returnPlayerAccessories", true)
addEventHandler("returnPlayerAccessories", root, function(accs)
    equip.accessories = accs;
end)