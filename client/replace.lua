addEventHandler("onClientResourceStart", resourceRoot, function()

    for i, v in pairs(config.main["Accessories"]) do
    
        if v["DFF and TXD"] then

            local txd = engineLoadTXD("assets/models/"..v["DFF and TXD"]["txd"])
            local dff = engineLoadDFF("assets/models/"..v["DFF and TXD"]["dff"])
        
            engineImportTXD(txd, v["Model"])
            engineReplaceModel(dff, v["Model"])

        end

    end

end)