ESX.RegisterServerCallback('w_achivements:GetAchivements', function(source, cb)
    local achivments = {}
    local result = MySQL.query.await('SELECT * FROM user_achievements WHERE identifier = ?', {
        ESX.GetPlayerFromId(source).identifier
       })
       for i=1, #result, 1 do
        table.insert(achivments, {
            id = result[i].achievement_id,
            progress = result[i].progress,
            dateUnlocked = result[i].date_unlocked,
            collected = result[i].collected,
        })
    end
    local playerAchivements = achivments
    cb(playerAchivements)
end)


RegisterNetEvent("w_achivements:UnlockAchivements")
AddEventHandler("w_achivements:UnlockAchivements", function(achievement_id, progress)
    local src = source
    local identifier = ESX.GetPlayerFromId(src).identifier
    local maxProgress = 0
    for _, achievement in ipairs(Config.Achivements) do
        if achievement.id == achievement_id then
            maxProgress = achievement.maxProgress
            break
        end
    end

    MySQL.Async.fetchScalar("SELECT progress FROM user_achievements WHERE identifier = @identifier AND achievement_id = @achievement_id", {
        ['@identifier'] = identifier,
        ['@achievement_id'] = achievement_id
    }, function(currentProgress)
        if currentProgress then
            local newProgress = currentProgress + progress
            MySQL.Sync.execute("UPDATE user_achievements SET progress = @progress WHERE identifier = @identifier AND achievement_id = @achievement_id", {
                ['@identifier'] = identifier,
                ['@achievement_id'] = achievement_id,
                ['@progress'] = newProgress
            })

            if newProgress >= maxProgress then
                TriggerClientEvent("w_achivements:UnlockAchivement", src, achievement_id)
            end
        else
            MySQL.Sync.execute("INSERT INTO user_achievements (identifier, achievement_id, progress, date_unlocked, collected) VALUES (@identifier, @achievement_id, @progress, @date_unlocked, @collected)", {
                ['@identifier'] = identifier,
                ['@achievement_id'] = achievement_id,
                ['@progress'] = progress,
                ['@date_unlocked'] = os.date("%Y-%m-%d %H:%M:%S"),
                ['@collected'] = false
            })
            if progress >= maxProgress then
                TriggerClientEvent("w_achivements:UnlockAchivement", src, achievement_id)
            end
        end
    end)
end)



RegisterNetEvent("w_achivements:ClaimReward")
AddEventHandler("w_achivements:ClaimReward", function(achievement_id)
    local xPlayer = ESX.GetPlayerFromId(source)
    for _, achievement in ipairs(Config.Achivements) do
        if achievement.id == achievement_id then
            xPlayer.addMoney(achievement.reward)
            MySQL.Sync.execute('UPDATE user_achievements SET collected = 1 WHERE identifier = @identifier AND achievement_id = @achievement_id', {
                ['@identifier'] = xPlayer.identifier,
                ['@achievement_id'] = achievement_id
            })
            return 
        end
    end
end)