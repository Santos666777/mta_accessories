shop = {};

shop.showing = false;

shop.alpha = 0;
shop.tick = getTickCount();

shop.circle = 0;

shop.scroll = 0;
shop.scroll2 = 0;
shop.scrollTick = getTickCount();

shop.renderDownMax = 0;

shop.renderAnimations = {};

shop.pos = Vector2(middle.x - (866/2), middle.y - 150)

shop.fonts = {
    ["Inter-Bold"] = {
        [8] = dxCreateFont("assets/fonts/Inter-Bold.ttf", 8);
        [11] = dxCreateFont("assets/fonts/Inter-Bold.ttf", 11);
        [13] = dxCreateFont("assets/fonts/Inter-Bold.ttf", 13);
    },
    ["Inter-ExtraBold"] = {
        [13] = dxCreateFont("assets/fonts/Inter-ExtraBold.ttf", 13);
    },
}

function shop.render()
    if shop.showing then
        shop.alpha = interpolateBetween(shop.alpha, 0, 0, 1, 0, 0, (getTickCount()-shop.tick)/800, "Linear")
        shop.pos.x, shop.pos.y = interpolateBetween(shop.pos.x, shop.pos.y, 0, middle.x - 433, middle.y - 245, 0, (getTickCount()-shop.tick)/500, "OutQuad")
        shop.scroll = interpolateBetween(shop.scroll, 0, 0, shop.scroll2, 0, 0, (getTickCount()-shop.scrollTick)/500, "OutQuad")
    else
        shop.alpha = interpolateBetween(shop.alpha, 0, 0, 0, 0, 0, (getTickCount()-shop.tick)/500, "Linear")
        shop.pos.x, shop.pos.y = interpolateBetween(shop.pos.x, shop.pos.y, 0, middle.x - 433, middle.y - 150, 0, (getTickCount()-shop.tick)/800, "InQuad")
        shop.scroll = interpolateBetween(shop.scroll, 0, 0, 0, 0, 0, (getTickCount()-shop.scrollTick)/100, "OutQuad")
    end

    if not shop.showing and shop.alpha <= 0.1 then
        removeEventHandler("onClientRender", root, shop.render)
        destroyElement(shop.renderTarget)
    end

    dxDrawImage(shop.pos.x, shop.pos.y, 866, 489, "assets/images/shop/background.png", 0, 0, 0, tocolor(255, 255, 255, 255 * shop.alpha), false)

    dxDrawText("Acessórios", shop.pos.x + 27, shop.pos.y + 19, 87, 15, tocolor(255, 255, 255, 255 * shop.alpha), 0.7, shop.fonts["Inter-ExtraBold"][13], "center", "center")
    dxDrawRectangle(shop.pos.x + 27, shop.pos.y + 39, 87, 2, tocolor(26, 26, 26, 255 * shop.alpha), false)

    if isElement(shop.renderTarget) then
        dxDrawImage(shop.pos.x + 49, shop.pos.y + 61, 768, 396, shop.renderTarget, 0, 0, 0, tocolor(255, 255, 255, 255 * shop.alpha), false)
        
        local c = 0;
        local r = 0;

        dxSetRenderTarget(shop.renderTarget, true)
        dxSetBlendMode("modulate_add")
            for i, v in ipairs(config.shop["Items"]) do
                local pos = Vector2(195 * c, 136 * r)
                
                if not shop.renderAnimations[v["Name"].." "..v["Image"]] then
                    shop.renderAnimations[v["Name"].." "..v["Image"]] = 0;
                end

                if isMouseInPosition(shop.pos.x + 49 + pos.x, shop.pos.y + 61 + pos.y - shop.scroll, 183, 124) then
                    shop.renderAnimations[v["Name"].." "..v["Image"]] = interpolateBetween(shop.renderAnimations[v["Name"].." "..v["Image"]], 0, 0, 5, 0, 0, (getTickCount()-shop.scrollTick)/100, "Linear")
                else
                    shop.renderAnimations[v["Name"].." "..v["Image"]] = interpolateBetween(shop.renderAnimations[v["Name"].." "..v["Image"]], 0, 0, 0, 0, 0, (getTickCount()-shop.scrollTick)/100, "Linear")
                end

                pos.y = pos.y - shop.renderAnimations[v["Name"].." "..v["Image"]];

                dxDrawImage(pos.x, pos.y - shop.scroll, 183, 124, "assets/images/shop/container.png", 0, 0, 0, tocolor(255, 255, 255, 255 * shop.alpha), false)
                dxDrawText(v["Name"], pos.x, pos.y + 102 - shop.scroll, 183, 22, tocolor(255, 255, 255, 255 * shop.alpha), 0.7, shop.fonts["Inter-Bold"][8], "center", "center")
                dxDrawImage(pos.x, pos.y - shop.scroll, 183, 124, "assets/images/shop/items/"..v["Image"], 0, 0, 0, tocolor(255, 255, 255, 255 * shop.alpha), false)
            
                c = c + 1;
                if c == 4 then
                    r = r + 1;
                    c = 0;
                end
            end
        dxSetBlendMode("blend")
        dxSetRenderTarget()

        shop.renderDownMax = (136 * r)

    end

    if shop.selected then

        local alpha = interpolateBetween(0, 0, 0, 1, 0, 0, (getTickCount()-shop.selectTick)/500, "Linear")
        
        dxDrawImage(shop.pos.x, shop.pos.y, 866, 489, "assets/images/shop/background.png", 0, 0, 0, tocolor(255, 255, 255, 198.9 * alpha), false)
        dxDrawImage(shop.pos.x + 302, shop.pos.y + 59, 249, 186, "assets/images/shop/items/"..shop.selected["Image"], 0, 0, 0, tocolor(255, 255, 255, 255 * alpha), false)
        dxDrawText(shop.selected["Name"], shop.pos.x + 341, shop.pos.y + 223, 183, 22, tocolor(255, 255, 255, 255 * alpha), 0.7, shop.fonts["Inter-Bold"][13], "center", "center")
        dxDrawText("$ "..formatNumber(shop.selected["Price"], " "), shop.pos.x + 341, shop.pos.y + 245, 183, 22, tocolor(255, 255, 255, 255 * alpha), 0.7, shop.fonts["Inter-Bold"][13], "center", "center")

        dxDrawImage(shop.pos.x + 423.5, shop.pos.y + 345.5, 18, 14, "assets/images/shop/buy.png", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha), false)

        dxDrawImageSection(shop.pos.x + 408, shop.pos.y + 327, 50, 50 - shop.circle/100*50, 0, 0, 50, 50 - shop.circle/100*50, "assets/images/shop/circle.png", 0, 0, 0, tocolor(255, 255, 255, 255 * alpha), false)
        
        if shop.circle > 0 then
            dxDrawImageSection(shop.pos.x + 408, shop.pos.y + 327 + 50, 50, -shop.circle/100*50, 0, 0, 50, -shop.circle/100*50, "assets/images/shop/circle.png", 0, 0, 0, tocolor(193, 70, 70, 255 * alpha))   
        end

        if isMouseInPosition(shop.pos.x + 408, shop.pos.y + 327, 50, 50) and getKeyState("mouse1") then
            shop.circle = math.min(100, shop.circle + 2);
        else
            shop.circle = math.max(0, shop.circle - 2);
        end

        if shop.circle == 100 then
            triggerServerEvent("buyAccessory", localPlayer, localPlayer, shop.selected["Index"], shop.selectedindex)
            shop.open();
        end

    end

    shop.scrollTick = getTickCount();

end

function shop.open()
    shop.showing = not shop.showing;
    shop.selected = nil;
    shop.tick = getTickCount();
    shop.scrollTick = getTickCount();
    shop.circle = 0;
    showCursor(shop.showing)
    if shop.showing and not isEventHandlerAdded("onClientRender", root, shop.render) then
        addEventHandler("onClientRender", root, shop.render)
        shop.renderTarget = dxCreateRenderTarget(768, 396, true)
    end
end
addEvent("openAccessoriesShop", true)
addEventHandler("openAccessoriesShop", root, shop.open)

addEventHandler("onClientClick", root, function(button, state)
    if shop.showing then
        if button == "left" and state == "down" then
            if not shop.selected then

                local c = 0;
                local r = 0;

                for i, v in ipairs(config.shop["Items"]) do
                    local pos = Vector2(195 * c, 136 * r)
                    
                    if isMouseInPosition(shop.pos.x + 49 + pos.x, shop.pos.y + 61 + pos.y - shop.scroll, 183, 124) then
                        shop.selected = v;
                        shop.selectedindex = i;
                        shop.selectTick = getTickCount();
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
    if shop.showing then
        if not shop.selected then
            shop.open();
        else
            shop.selected = nil;
            shop.selectedindex = nil;
        end
    end
end)

addEventHandler("onClientKey", root, function(key)
    if shop.showing then
    
        if key == "mouse_wheel_down" then
            shop.scroll2 = math.min(shop.scroll2 + 15, shop.renderDownMax);
        elseif key == "mouse_wheel_up" then
            shop.scroll2 = math.max(0, shop.scroll2 - 15);
        elseif key == "space" then
            shop.scroll2 = 0;
        end

    end
end)