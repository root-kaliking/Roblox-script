print("云中心脚本正在初始化...")

repeat
    task.wait()
until game:IsLoaded()
print("游戏加载完成！")

-- 基础库加载
local function SafeLoad(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    if not success then
        warn("加载失败: " .. url .. " - " .. result)
        return nil
    end
    return result
end

-- 玩家列表管理
local AllPlayers = {game.Players.LocalPlayer.Name}

local function refreshPlayerList()
    AllPlayers = {game.Players.LocalPlayer.Name}
    for _, player in ipairs(game.Players:GetPlayers()) do
        if not table.find(AllPlayers, player.Name) then
            table.insert(AllPlayers, player.Name)
        end
    end
end

refreshPlayerList()

-- 基础功能
local CloudCenter = {}

-- 传送功能
function CloudCenter.TeleportToPlayer(plrName)
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Name == plrName then
            local localPlayer = game.Players.LocalPlayer
            if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    localPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                    print("已传送到 " .. plrName)
                    return true
                end
            end
        end
    end
    return false
end

-- 玩家属性修改
function CloudCenter.ModifyPlayerProperties(options)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        
        if options.WalkSpeed then
            humanoid.WalkSpeed = options.WalkSpeed
        end
        
        if options.JumpPower then
            humanoid.JumpPower = options.JumpPower
        end
        
        if options.Health then
            humanoid.Health = options.Health
        end
        
        if options.Gravity then
            game.Workspace.Gravity = options.Gravity
        end
        
        if options.FieldOfView then
            game.Workspace.CurrentCamera.FieldOfView = options.FieldOfView
        end
        
        if options.CameraZoom then
            player.CameraMaxZoomDistance = options.CameraZoom
        end
        
        return true
    end
    return false
end

-- 防AFK
function CloudCenter.EnableAntiAFK()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
    print("防AFK已启用")
end

-- 游戏工具
CloudCenter.GameTools = {}

function CloudCenter.GameTools.Suicide()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = 0
        return true
    end
    return false
end

function CloudCenter.GameTools.ResetCharacter()
    local player = game.Players.LocalPlayer
    player.Character:BreakJoints()
    return true
end

function CloudCenter.GameTools.RejoinGame()
    game:GetService("TeleportService"):TeleportToPlaceInstance(
        game.PlaceId,
        game.JobId,
        game:GetService("Players").LocalPlayer
    )
    return true
end

-- ESP系统（基础版）
CloudCenter.ESP = {
    Enabled = false,
    Connections = {},
    Drawings = {}
}

function CloudCenter.ESP.Toggle(state)
    CloudCenter.ESP.Enabled = state
    if state then
        CloudCenter.ESP.Start()
    else
        CloudCenter.ESP.Stop()
    end
end

function CloudCenter.ESP.Start()
    -- 这里可以添加ESP绘制逻辑
    print("ESP功能已启用（基础版）")
end

function CloudCenter.ESP.Stop()
    -- 清理ESP资源
    for _, conn in pairs(CloudCenter.ESP.Connections) do
        conn:Disconnect()
    end
    CloudCenter.ESP.Connections = {}
    print("ESP功能已禁用")
end

-- 图形设置
CloudCenter.Graphics = {}

function CloudCenter.Graphics.SetRTXMode()
    local lighting = game.Lighting
    
    -- 清理现有效果
    for _, v in pairs(lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            v:Destroy()
        end
    end
    
    -- 创建新效果
    local bloom = Instance.new("BloomEffect")
    bloom.Parent = lighting
    bloom.Intensity = 0.1
    bloom.Size = 24
    bloom.Threshold = 0.95
    
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Parent = lighting
    colorCorrection.Contrast = 0.15
    colorCorrection.Brightness = 0.1
    colorCorrection.Saturation = 0.25
    colorCorrection.TintColor = Color3.fromRGB(255, 240, 230)
    
    -- 光照设置
    lighting.Brightness = 3
    lighting.GlobalShadows = true
    lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    
    print("RTX图形模式已启用")
end

function CloudCenter.Graphics.SetLowGraphics()
    _G.Settings = {
        Players = {
            ["Ignore Me"] = true,
            ["Ignore Others"] = true
        },
        Meshes = {
            LowDetail = true
        },
        Images = {
            Invisible = true,
            LowDetail = true
        },
        ["No Particles"] = true,
        ["No Camera Effects"] = true,
        ["No Shadows"] = true,
        ["Low Rendering"] = true
    }
    
    -- 这里可以调用FPS优化脚本
    print("低图形模式已设置")
end

-- 脚本管理器
CloudCenter.ScriptManager = {
    InstalledScripts = {}
}

function CloudCenter.ScriptManager.LoadScript(scriptName, scriptUrl)
    print("正在加载脚本: " .. scriptName)
    local success, errorMsg = pcall(function()
        loadstring(game:HttpGet(scriptUrl, true))()
    end)
    
    if success then
        CloudCenter.ScriptManager.InstalledScripts[scriptName] = scriptUrl
        print("脚本加载成功: " .. scriptName)
        return true
    else
        warn("脚本加载失败: " .. scriptName .. " - " .. errorMsg)
        return false, errorMsg
    end
end

-- 游戏特定支持
CloudCenter.GameSupport = {
    ["Prison Life"] = {
        Teleports = {
            ["Guard Room"] = CFrame.new(847.726, 98.96, 2267.387),
            ["Prison Yard"] = CFrame.new(760.603, 96.97, 2475.405),
            ["Criminal Spawn"] = CFrame.new(-937.589, 93.099, 2063.032)
        },
        ChangeTeam = function(team)
            workspace.Remote.TeamEvent:FireServer(team)
        end
    },
    
    ["Natural Disaster Survival"] = {
        Teleports = {
            ["Spawn Tower"] = CFrame.new(-280, 170, 341),
            ["Map Center"] = CFrame.new(-115.828, 65.486, 18.846),
            ["Game Island"] = CFrame.new(-83.5, 38.5, -27.5)
        },
        PredictDisaster = function()
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("SurvivalTag") then
                return player.Character.SurvivalTag.Value
            end
            return "Unknown"
        end
    },
    
    ["Speed Run"] = {
        Teleports = {
            ["City"] = Vector3.new(-559.2, 0, 417.4),
            ["Snow City"] = Vector3.new(-858.358, 0.5, 2170.35),
            ["Lava City"] = Vector3.new(1707.25, 0.55, 4331.05)
        }
    },
    
    ["Muscle Legends"] = {
        Teleports = {
            ["Spawn"] = CFrame.new(7, 3, 108),
            ["Frost Gym"] = CFrame.new(-2543, 13, -410),
            ["Mythic Gym"] = CFrame.new(2177, 13, 1070),
            ["Legends Gym"] = CFrame.new(4676, 997, -3915)
        }
    }
}

-- 获取当前游戏支持
function CloudCenter.GetCurrentGameSupport()
    local placeId = game.PlaceId
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    
    for supportedGame, supportData in pairs(CloudCenter.GameSupport) do
        if string.find(gameName, supportedGame) then
            return supportedGame, supportData
        end
    end
    
    return nil, nil
end

-- 初始化函数
function CloudCenter.Initialize()
    print("=== 云中心脚本 v2.1 ===")
    print("游戏ID: " .. game.GameId)
    print("玩家: " .. game.Players.LocalPlayer.Name)
    print("执行器: " .. (identifyexecutor and identifyexecutor() or "Unknown"))
    
    -- 自动启用防AFK
    CloudCenter.EnableAntiAFK()
    
    -- 检测当前游戏支持
    local gameName, supportData = CloudCenter.GetCurrentGameSupport()
    if gameName then
        print("检测到游戏支持: " .. gameName)
    else
        print("当前游戏无特定支持，使用通用功能")
    end
    
    print("云中心脚本初始化完成！")
    print("作者: 小云 QQ: 168777105")
    print("QQ群: 526684389")
end

-- UI界面函数（简化的文本界面）
function CloudCenter.ShowSimpleUI()
    print("\n=== 云中心控制台 ===")
    print("1. 玩家属性修改")
    print("2. 传送功能")
    print("3. 图形设置")
    print("4. 游戏工具")
    print("5. ESP功能")
    print("6. 刷新玩家列表")
    print("7. 查看游戏支持")
    print("8. 退出")
    
    -- 这里可以添加更复杂的GUI实现
    -- 原代码使用了复杂的UI库，这里简化处理
end

-- 导出全局接口
_G.CloudCenter = CloudCenter

-- 自动初始化
task.spawn(function()
    CloudCenter.Initialize()
    
    -- 5秒后显示简单UI
    task.wait(5)
    CloudCenter.ShowSimpleUI()
end)

-- 返回模块
return CloudCenter
