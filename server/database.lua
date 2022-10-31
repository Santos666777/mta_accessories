function connectDB(type)
    if type == "sqlite" then
        connection = dbConnect(type, config.main["Database"]["SQLITE Directory"])
        if connection and isElement(connection) then
            dbExec(connection, "CREATE TABLE IF NOT EXISTS accessories(user, accessory, sticker, position, equiped)")
            outputDebugString("Conexão ao banco de dados bem sucedida. ("..getResName()..")", 3, 0, 255, 0)
            return connection
        else
            outputDebugString("Conexão ao banco de dados falhada. ("..getResName()..")", 1, 255, 0, 0)
        end
    elseif type == "mysql" then
        local data = config.main["Database"]["MYSQL Connection"];
        connection = dbConnect(type, "dbname="..data["database"]..";host="..data["host"]..";charset=utf8", data["user"], data["password"])
        if connection and isElement(connection) then
            dbExec(connection, "CREATE TABLE IF NOT EXISTS `accessories` (`user` TEXT(255) NOT NULL, `accessory` TEXT(255) NOT NULL, `sticker` TEXT(255) NOT NULL, `position` TEXT(255) NOT NULL, `equiped` TEXT(255) NOT NULL);")
            outputDebugString("Conexão ao banco de dados bem sucedida. ("..getResName()..")", 3, 0, 255, 0)
            return connection
        else
            outputDebugString("Conexão ao banco de dados falhada. ("..getResName()..")", 1, 255, 0, 0)
        end
    end
end

function getResName()
    return getResourceName(getThisResource())
end