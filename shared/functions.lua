function getObjectInfo(val, type)
    if type == "objectid" then
        for i, v in pairs(config.main["Accessories"]) do
            if tonumber(v["Model"]) == tonumber(val) then
				local a = v
				a["index"] = i;
                return a
            end
        end
    elseif type == "name" then
        return config.main["Accessories"][val]
    end 
    return false
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end

function formatNumber(number, sep)
	assert(type(tonumber(number))=="number", "Bad argument @'formatNumber' [Expected number at argument 1 got "..type(number).."]")
	assert(not sep or type(sep)=="string", "Bad argument @'formatNumber' [Expected string at argument 2 got "..type(sep).."]")
	return tostring(number):reverse():gsub("%d%d%d","%1%"..(sep and #sep>0 and sep or ".")):reverse()
end

_getPlayerMoney = getPlayerMoney;
_takePlayerMoney = takePlayerMoney;

function getPlayerMoney(player)
    if config.main["Money"]["Type"] == "game" then
        return _getPlayerMoney(player);
    elseif config.main["Money"]["Type"] == "elementData" then
        return getElementData(player, config.main["Money"]["Element Data"]) or 0;
    end
end

function takePlayerMoney(player, amount)
    if config.main["Money"]["Type"] == "game" then
        return _takePlayerMoney(player, amount);
    elseif config.main["Money"]["Type"] == "elementData" then
        local money = getPlayerMoney(player) or 0;
        return setElementData(player, config.main["Money"]["Element Data"], money - amount);
    end
end