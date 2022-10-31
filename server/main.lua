objects = {};
cooldown = {};

addEventHandler("onResourceStart", resourceRoot, function()
    connection = connectDB(config.main["Database"]["Connection Type"])

    for i, v in ipairs(config.shop["Markers"]) do
        local marker = createMarker(Vector3(v), "cylinder", v["size"], v["color"][1], v["color"][2], v["color"][3], v["alpha"])

        addEventHandler("onMarkerHit", marker, function(element)
            if isElement(element) and getElementType(element) == "player" and not isPedInVehicle(element) then
                triggerClientEvent(element, "openAccessoriesShop", element)
            end
        end)
    
    end

    local pAttachRES = getResourceFromName("pAttach");

    if pAttachRES then
        if getResourceState(pAttachRES) == "loaded" then
            startResource(pAttachRES)
        end
    end
end)

function createPlayerAccessory(player, name, positions, tex)
    local object_infos = getObjectInfo(name, "name");
    if object_infos then
        local obj = createObject(object_infos["Model"], 0, 0, 0)
		local positions = fromJSON(positions)
        exports.pAttach:attach(obj, player, object_infos["Bone"], positions["x"], positions["y"], positions["z"], positions["rx"], positions["ry"], positions["rz"])
        if not objects[player] then
            objects[player] = {};
        end
        objects[player][name] = obj;
    end
end

function editPlayerAccessory(player, obj, name)
    local details = exports.pAttach:getDetails(obj);
    triggerClientEvent(player, "startEditAccessory", player, obj, name, {x = details[4], y = details[5], z = details[6], rx = details[7], ry = details[8], rz = details[9]})
end

function editAccessory(player, obj, positions)
    local object_infos = getObjectInfo(getElementModel(obj), "objectid");
    exports.pAttach:setPositionOffset(obj, positions["x"], positions["y"], positions["z"])
    exports.pAttach:setRotationOffset(obj, positions["rx"], positions["ry"], positions["rz"])
	dbExec(connection, "UPDATE accessories SET position = ? WHERE user = ? AND accessory = ?", toJSON(positions), getAccountName(getPlayerAccount(player)), object_infos["index"])
end
addEvent("editAccessory", true)
addEventHandler("editAccessory", root, editAccessory)

function removeAccessory(player, object, name)
    if isElement(object) and isElement(objects[player][name]) then
        destroyElement(object)
        objects[player][name] = nil;
        dbExec(connection, "UPDATE accessories SET equiped = ? WHERE user = ? AND accessory = ?", false, getAccountName(getPlayerAccount(player)), name)
    end
end
addEvent("removeAccessory", true)
addEventHandler("removeAccessory", root, removeAccessory)

addCommandHandler("acessorio", function(player, _, accessory, sticker)
    if not objects[player] then
        objects[player] = {};
    end
    local query = dbPoll(dbQuery(connection, "SELECT * FROM accessories WHERE user = ? AND accessory = ?", getAccountName(getPlayerAccount(player)), accessory), -1)
    if not objects[player][accessory] then
        createPlayerAccessory(player, accessory, query[1]["position"], sticker)
    else
        editPlayerAccessory(player, objects[player][accessory], accessory)
    end
end)

function buyAccessory(player, accessory, accessory_index)
    if isElement(player) then
        if not isGuestAccount(getPlayerAccount(player)) then
            local itemInfos = config.shop["Items"][accessory_index];
            local query = dbPoll(dbQuery(connection, "SELECT * FROM accessories WHERE user = ? AND accessory = ? AND sticker = ?", getAccountName(getPlayerAccount(player)), accessory, accessory_index), -1)
            if #query == 0 then
                if getPlayerMoney(player) >= itemInfos["Price"] then
                    dbExec(connection, "INSERT INTO accessories (user, accessory, sticker, position, equiped) VALUES (?, ?, ?, ?, ?)", getAccountName(getPlayerAccount(player)), accessory, accessory_index, toJSON(config.main["Accessories"][accessory]["Default Attach"]), false)
                    messagePlayer(player, "Você comprou "..itemInfos["Name"]..".", "success")
                    takePlayerMoney(player, itemInfos["Price"])
                else
                    messagePlayer(player, "Dinheiro insuficiente", "error")
                end
            else
                messagePlayer(player, "Você já possui este acessório", "error")
            end
        else
            messagePlayer(player, "Você precisa estar logado", "error")
        end
    end
end
addEvent("buyAccessory", true)
addEventHandler("buyAccessory", root, buyAccessory)

function equipAccessory(player, accessory, sticker)
    if not objects[player] then
        objects[player] = {};
    end
    if not objects[player][accessory] then
        local query = dbPoll(dbQuery(connection, "SELECT * FROM accessories WHERE user = ? AND accessory = ?", getAccountName(getPlayerAccount(player)), accessory), -1)
        createPlayerAccessory(player, accessory, query[1]["position"], sticker)
        dbExec(connection, "UPDATE accessories SET equiped = ? WHERE user = ? AND accessory = ?", true, getAccountName(getPlayerAccount(player)), accessory)
    else
        editPlayerAccessory(player, objects[player][accessory], accessory)
    end
end
addEvent("equipAccessory", true)
addEventHandler("equipAccessory", root, equipAccessory)

addEvent("returnPlayerAccessories", true)
addEventHandler("returnPlayerAccessories", root, function(player)
    if not isTimer(cooldown[player]) then
        local result = dbPoll(dbQuery(connection, "SELECT * FROM accessories WHERE user = ?", getAccountName(getPlayerAccount(player))), -1)
        if #result > 0 then
            triggerClientEvent(player, "returnPlayerAccessories", player, result)
        else
            triggerClientEvent(player, "returnPlayerAccessories", player, nil)
            messagePlayer(player, "Você não possui accessorios", "error")
        end
        cooldown[player] = setTimer(function()end, 5000, 1)
    end
end)

addEventHandler("onPlayerLogin", root, function(_, acc)
    if not isGuestAccount(acc) then
        local result = dbPoll(dbQuery(connection, "SELECT * FROM accessories WHERE user = ?", getAccountName(acc)), -1)
        for i, v in ipairs(result) do
            if tostring(v["equiped"]) == "1" then
                equipAccessory(source, v["accessory"])
            end
        end
    end
end)

addEventHandler("onPlayerLogout", root, function()
    if objects[source] then
        for i, v in pairs(objects[source]) do
            destroyElement(v)
            objects[source][i] = nil;
        end
    end
end)

function setPlayerAccessory(player, accessory)
    if isElement(player) then
        if not isGuestAccount(getPlayerAccount(player)) then
            local query = dbPoll(dbQuery(connection, "SELECT * FROM accessories WHERE user = ? AND accessory = ?", getAccountName(getPlayerAccount(player)), accessory), -1)
            if #query == 0 then
                dbExec(connection, "INSERT INTO accessories (user, accessory, position, equiped) VALUES (?, ?, ?, ?)", getAccountName(getPlayerAccount(player)), accessory, toJSON(config.main["Accessories"][accessory]["Default Attach"]), false)
                return true
            end
        end
    end
    return false
end

function removePlayerAccessory(player, accessory)
    if isElement(player) then
        if not isGuestAccount(getPlayerAccount(player)) then
            local query = dbPoll(dbQuery(connection, "SELECT * FROM accessories WHERE user = ? AND accessory = ?", getAccountName(getPlayerAccount(player)), accessory), -1)
            if #query > 0 then
                dbExec(connection, "DELETE FROM accessories WHERE user = ? AND accessory = ?", getAccountName(getPlayerAccount(player)), accessory)
                if objects[player] and objects[player][accessory] then
                    destroyElement(objects[player][accessory])
                    objects[player][accessory] = nil;
                end
                return true
            else
                iprint(query)
            end
        else
            iprint("guest")
        end
    end
    return false
end

function getPlayerAccessories(player)
    if isElement(player) then
        local acc = getPlayerAccount(player);
        if not isGuestAccount(acc) then
            local query = dbPoll(dbQuery(connection, "SELECT * FROM user = ?", getAccountName(acc)), -1)
            if #query > 0 then
                return query;
            end
        end
    end
    return {}
end

function messagePlayer(player, message, type)
    config.main["Messages"]["Server"](player, message, type)
end