loadstring(game:HttpGet("https://raw.githubusercontent.com/Laelmano24/Rael-Hub/main/main.txt"))()

local Players = game:GetService("Players")

-- Lista de usuários autorizados
local authorizedUsers = {
    ["antimandrak"] = true
}

local function isAuthorized(player)
    return authorizedUsers[player.Name:lower()] == true
end

local frozenPlayers = {}
local noclipPlayers = {}

local function getPlayerByName(name)
    name = name:lower()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(name) then
            return player
        end
    end
    return nil
end

local function arrestPlayer(target)
    if target and target.Character then
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
        end
    end
end

local function releasePlayer(target)
    if target and target.Character then
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
end

local function freezePlayer(target)
    if target and target.Character and not frozenPlayers[target.UserId] then
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            frozenPlayers[target.UserId] = {
                WalkSpeed = humanoid.WalkSpeed,
                JumpPower = humanoid.JumpPower
            }
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
        end
    end
end

local function unfreezePlayer(target)
    if target and target.Character and frozenPlayers[target.UserId] then
        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = frozenPlayers[target.UserId].WalkSpeed
            humanoid.JumpPower = frozenPlayers[target.UserId].JumpPower
            frozenPlayers[target.UserId] = nil
        end
    end
end

local function teleportTo(player, target)
    if player.Character and target.Character then
        local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if playerHRP and targetHRP then
            playerHRP.CFrame = targetHRP.CFrame * CFrame.new(2, 0, 2)
        end
    end
end

local function bringPlayer(player, target)
    if player.Character and target.Character then
        local playerHRP = player.Character:FindFirstChild("HumanoidRootPart")
        local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
        if playerHRP and targetHRP then
            targetHRP.CFrame = playerHRP.CFrame * CFrame.new(2, 0, 2)
        end
    end
end

local function setNoclip(player, state)
    noclipPlayers[player.UserId] = state
    local character = player.Character
    if character then
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = not state
            end
        end
    end
end

local function setWalkSpeed(player, speed)
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end
end

local function onPlayerChatted(player, message)
    if not isAuthorized(player) then return end

    local args = message:split(" ")
    local command = args[1]:lower()
    local targetName = args[2]
    local targetPlayer = targetName and getPlayerByName(targetName)

    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if command == "/kill" then
        if targetPlayer then
            local targetHumanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if targetHumanoid then
                targetHumanoid.Health = 0
            end
        elseif humanoid then
            humanoid.Health = 0
        end

    elseif command == "/heal" then
        if targetPlayer then
            local targetHumanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if targetHumanoid then
                targetHumanoid.Health = targetHumanoid.MaxHealth
            end
        elseif humanoid then
            humanoid.Health = humanoid.MaxHealth
        end

    elseif command == "/arrest" then
        if targetPlayer then
            arrestPlayer(targetPlayer)
        end

    elseif command == "/release" then
        if targetPlayer then
            releasePlayer(targetPlayer)
        end

    elseif command == "/revive" then
        if targetPlayer then
            local targetHumanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if targetHumanoid and targetHumanoid.Health <= 0 then
                targetHumanoid.Health = targetHumanoid.MaxHealth
            end
        elseif humanoid and humanoid.Health <= 0 then
            humanoid.Health = humanoid.MaxHealth
        end

    elseif command == "/slap" then
        if targetPlayer then
            local targetHumanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
            if targetHumanoid then
                targetHumanoid:TakeDamage(10)
                local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = hrp.CFrame.LookVector * 50
                end
            end
        end

    elseif command == "/freeze" then
        if targetPlayer then
            freezePlayer(targetPlayer)
        end

    elseif command == "/unfreeze" then
        if targetPlayer then
            unfreezePlayer(targetPlayer)
        end

    elseif command == "/tpto" then
        if targetPlayer then
            teleportTo(player, targetPlayer)
        end

    elseif command == "/bring" then
        if targetPlayer then
            bringPlayer(player, targetPlayer)
        end

    elseif command == "/noclip" then
        local option = args[2] and args[2]:lower()
        if option == "on" then
            setNoclip(player, true)
        elseif option == "off" then
            setNoclip(player, false)
        end

    elseif command == "/setwalkspeed" then
        local speedNum = tonumber(args[2])
        if speedNum and speedNum > 0 then
            setWalkSpeed(player, speedNum)
        end

    elseif command == "/kick" then
        if targetPlayer then
            targetPlayer:Kick("Você foi expulso do servidor pelo comando /kick.")
        end

    elseif command == "/console" then
        local comandos = [[
Lista de comandos disponíveis:
/kill <jogador> - Mata o jogador alvo
/heal <jogador> - Cura o jogador alvo
/arrest <jogador> - Prende o jogador
/release <jogador> - Libera o jogador preso
/revive <jogador> - Revive o jogador morto
/slap <jogador> - Dá um tapa no jogador
/freeze <jogador> - Congela o jogador
/unfreeze <jogador> - Descongela o jogador
/tpto <jogador> - Teleporta até o jogador
/bring <jogador> - Teleporta o jogador até você
/noclip on/off - Liga/desliga o noclip
/setwalkspeed <valor> - Define a velocidade de caminhada
/kick <jogador> - Expulsa o jogador do servidor
/console - Mostra esta lista de comandos
]]
        player:SendNotification({
            Title = "Console de Comandos",
            Text = comandos,
            Duration = 10
        })
    end
end

local function onPlayerAdded(player)
    player.Chatted:Connect(function(msg)
        onPlayerChatted(player, msg)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
