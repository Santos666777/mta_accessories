config = {};

config.main = {
    ["Main"] = {
        ["Key equip"] = "F2",
        ["Distance"] = 0.7,
        ["Add pos"] = 0.0025,
        ["Add pos rot"] = 1,
        ["Line widht"] = 1.25,
    },
    ["Money"] = {
        ["Type"] = "game", -- game / elementData
        ["Element Data"] = "money",
    },
    ["Database"] = {
        ["Connection Type"] = "sqlite", -- sqlite / mysql
        ["SQLITE Directory"] = "assets/database.db",
        ["MYSQL Connection"] = {
            host = "127.0.0.1",
            user = "root",
            password = "",
            database = "",
        }
    },
    ["Messages"] = {
        ["Server"] = function(player, message, type)
            outputChatBox(message, player)
        end
    },
    ["Accessories"] = {
        ["assaultbag"] = {
            ["Name"] = "Bolsa de assalto",
            ["Image"] = "assaultbag.png",
            ["Model"] = 3462,
            ["DFF and TXD"] = {txd = "assaultbag.txd", dff = "assaultbag.dff"},
            ["Bone"] = 3,
            ["Default Attach"] = {x = -0.24250001, y = 0.0175, z = -0.082499988, rx = 77, ry = 6, rz = 83},
        },
    },
}