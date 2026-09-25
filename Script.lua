-- =====================================================
-- mourazx optimizer - versão corrigida
-- =====================================================

local WINDUI_URL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
local STRETCH_BIND_NAME = "MourazxCameraStretch"

local WindUISource = game:HttpGet(WINDUI_URL)
local WindUILoader = loadstring(WindUISource)
assert(WindUILoader, "Não foi possível carregar o WindUI.")
local WindUI = WindUILoader()
assert(WindUI, "O WindUI retornou nil.")

local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local DISCORD_LINK = "https://discord.gg/BgDrtUVtZw"

local function Notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "mourazx optimizer",
            Text = text,
            Duration = duration or 4,
        })
    end)
end

-- Tema vermelho para a chave dos toggles, checkbox e slider.
do
    local darkTheme = WindUI:GetThemes().Dark
    local redTheme = {}

    for key, value in pairs(darkTheme) do
        redTheme[key] = value
    end

    redTheme.Name = "MourazxRed"
    redTheme.Toggle = Color3.fromRGB(220, 45, 55)
    redTheme.Checkbox = Color3.fromRGB(220, 45, 55)
    redTheme.Slider = Color3.fromRGB(220, 45, 55)
    redTheme.Primary = Color3.fromRGB(220, 45, 55)

    WindUI:AddTheme(redTheme)
    WindUI:SetTheme("MourazxRed")
end

Notify("Comunidade Blox Fruits & Otimização:\n" .. DISCORD_LINK, 6)

if type(setclipboard) == "function" then
    pcall(function()
        setclipboard(DISCORD_LINK)
    end)
end

getgenv().StretchEnabled = false
getgenv().StretchIntensity = 0.75

local function StopStretch()
    pcall(function()
        RunService:UnbindFromRenderStep(STRETCH_BIND_NAME)
    end)

    getgenv().StretchConn = nil
end

local function ApplyStretch()
    -- Evita criar vários binds quando o usuário liga/desliga a função.
    StopStretch()

    RunService:BindToRenderStep(
        STRETCH_BIND_NAME,
        Enum.RenderPriority.Camera.Value + 1,
        function()
            local camera = workspace.CurrentCamera

            if not getgenv().StretchEnabled or not camera then
                return
            end

            local intensity = math.clamp(
                tonumber(getgenv().StretchIntensity) or 0.75,
                0.50,
                1.20
            )

            -- O CFrame original é restaurado antes de aplicar a nova intensidade.
            -- Assim o slider não acumula a distorção a cada frame.
            local original = camera.CFrame

            camera.CFrame = original * CFrame.new(
                0, 0, 0,
                1, 0, 0,
                0, intensity, 0,
                0, 0, 1
            )
        end
    )

    getgenv().StretchConn = true
end

local UltraFPSBackup = {}
local UltraFPSApplied = false

local function Backup(object, property)
    UltraFPSBackup[object] = UltraFPSBackup[object] or {}

    if UltraFPSBackup[object][property] == nil then
        local ok, value = pcall(function()
            return object[property]
        end)

        if ok then
            UltraFPSBackup[object][property] = value
        end
    end
end

local function ApplyUltraFPS()
    if UltraFPSApplied then
        return
    end

    UltraFPSApplied = true

    task.defer(function()
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")

        pcall(function()
            Backup(Lighting, "GlobalShadows")
            Lighting.GlobalShadows = false

            Backup(Lighting, "FogEnd")
            Lighting.FogEnd = 9e9

            Backup(Lighting, "FogStart")
            Lighting.FogStart = 0

            Backup(Lighting, "Technology")
            Lighting.Technology = Enum.Technology.Compatibility

            Backup(Lighting, "EnvironmentDiffuseScale")
            Lighting.EnvironmentDiffuseScale = 0

            Backup(Lighting, "EnvironmentSpecularScale")
            Lighting.EnvironmentSpecularScale = 0
        end)

        if Terrain then
            pcall(function()
                Backup(Terrain, "Decoration")
                Terrain.Decoration = false

                Backup(Terrain, "WaterWaveSize")
                Terrain.WaterWaveSize = 0

                Backup(Terrain, "WaterWaveSpeed")
                Terrain.WaterWaveSpeed = 0

                Backup(Terrain, "WaterReflectance")
                Terrain.WaterReflectance = 0
            end)
        end

        local descendants = game:GetDescendants()

        for index, object in ipairs(descendants) do
            pcall(function()
                if object:IsA("BasePart") then
                    Backup(object, "CastShadow")
                    object.CastShadow = false

                    Backup(object, "Material")
                    object.Material = Enum.Material.SmoothPlastic

                    Backup(object, "Reflectance")
                    object.Reflectance = 0
                end

                if object:IsA("MeshPart") then
                    Backup(object, "RenderFidelity")
                    object.RenderFidelity = Enum.RenderFidelity.Performance
                end

                if object:IsA("ParticleEmitter")
                    or object:IsA("Trail")
                    or object:IsA("Beam")
                    or object:IsA("Smoke")
                    or object:IsA("Fire")
                    or object:IsA("Sparkles")
                    or object:IsA("PostEffect") then
                    Backup(object, "Enabled")
                    object.Enabled = false
                elseif object:IsA("Atmosphere") then
                    Backup(object, "Density")
                    object.Density = 0
                    Backup(object, "Haze")
                    object.Haze = 0
                    Backup(object, "Glare")
                    object.Glare = 0
                elseif object:IsA("Clouds") then
                    Backup(object, "Cover")
                    object.Cover = 0
                    Backup(object, "Density")
                    object.Density = 0
                end
            end)

            if index % 150 == 0 then
                task.wait()
            end
        end

        Notify("Ultra FPS ativado: iluminação, fog, sombras e efeitos reduzidos.", 5)
    end)
end

local function RestoreUltraFPS()
    for object, properties in pairs(UltraFPSBackup) do
        for property, value in pairs(properties) do
            pcall(function()
                object[property] = value
            end)
        end
    end

    UltraFPSBackup = {}
    UltraFPSApplied = false
    Notify("Configurações visuais restauradas.", 4)
end

local FPSGui
local FPSLabel
local FPSRenderConnection
local FPSUpdateConnection
local FPSInputChangedConnection
local FPSDragging = false
local FPSDragStart
local FPSStartPosition

local function DestroyFPSCounter()
    if FPSRenderConnection then
        FPSRenderConnection:Disconnect()
        FPSRenderConnection = nil
    end

    if FPSUpdateConnection then
        FPSUpdateConnection:Disconnect()
        FPSUpdateConnection = nil
    end

    if FPSInputChangedConnection then
        FPSInputChangedConnection:Disconnect()
        FPSInputChangedConnection = nil
    end

    if FPSGui then
        FPSGui:Destroy()
        FPSGui = nil
        FPSLabel = nil
    end
end

local function CreateFPSCounter()
    DestroyFPSCounter()

    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    FPSGui = Instance.new("ScreenGui")
    FPSGui.Name = "MourazxFPSCounter"
    FPSGui.ResetOnSpawn = false
    FPSGui.IgnoreGuiInset = true
    FPSGui.DisplayOrder = 999999
    FPSGui.Parent = parent

    local frame = Instance.new("Frame")
    frame.Name = "FPSFrame"
    frame.Size = UDim2.fromOffset(145, 42)
    frame.Position = UDim2.new(0, 18, 0, 120)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    frame.BackgroundTransparency = 0.12
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = FPSGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(220, 45, 55)
    stroke.Thickness = 1
    stroke.Transparency = 0.15
    stroke.Parent = frame

    FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.fromScale(1, 1)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Font = Enum.Font.GothamBold
    FPSLabel.TextSize = 15
    FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FPSLabel.Text = "FPS: --"
    FPSLabel.Parent = frame

    -- Arraste por mouse ou toque, sem bloquear os demais controles do jogo.
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            FPSDragging = true
            FPSDragStart = input.Position
            FPSStartPosition = frame.Position
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            FPSDragging = false
        end
    end)

    local UserInputService = game:GetService("UserInputService")
    FPSInputChangedConnection = UserInputService.InputChanged:Connect(function(input)
        if not FPSDragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - FPSDragStart
            frame.Position = UDim2.new(
                FPSStartPosition.X.Scale,
                FPSStartPosition.X.Offset + delta.X,
                FPSStartPosition.Y.Scale,
                FPSStartPosition.Y.Offset + delta.Y
            )
        end
    end)

    local frames = 0
    local elapsed = 0

    FPSRenderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        frames += 1
        elapsed += deltaTime
    end)

    FPSUpdateConnection = RunService.Heartbeat:Connect(function()
        if elapsed >= 0.25 and FPSLabel then
            local fps = math.floor((frames / elapsed) + 0.5)
            local color = fps >= 40
                and Color3.fromRGB(80, 220, 120)
                or fps >= 25
                and Color3.fromRGB(255, 190, 70)
                or Color3.fromRGB(255, 80, 80)

            FPSLabel.Text = "FPS: " .. tostring(fps)
            FPSLabel.TextColor3 = color
            frames = 0
            elapsed = 0
        end
    end)
end

local function CleanClientMemory()
    local before = collectgarbage("count")

    -- Libera objetos Lua sem remover partes do mapa ou texturas do jogo.
    collectgarbage("collect")
    task.wait()
    collectgarbage("collect")

    local after = collectgarbage("count")
    local released = math.max(0, before - after)
    Notify(string.format("Limpeza concluída: %.1f KB de memória Lua liberados.", released), 5)
end

local Window = WindUI:CreateWindow({
    Title = "mourazx optimizer",
    Author = ":by @mourazx_",
    Folder = "MourazxOptimizer",
    Size = UDim2.fromOffset(500, 340),
    Transparent = false,
    Theme = "MourazxRed",
    Draggable = true,
})

local MainTab = Window:Tab({
    Title = "Screen",
    Icon = "monitor",
})

local OptiTab = Window:Tab({
    Title = "Optimization",
    Icon = "zap",
})

-- =====================================================
-- ABA SCREEN
-- =====================================================
MainTab:Section({
    Title = "Stretched Screen Settings",
})

MainTab:Toggle({
    Title = "Enable Stretched Screen",
    Desc = "Ativa a resolução de tela esticada",
    Value = false,
    Callback = function(value)
        getgenv().StretchEnabled = value

        if value then
            ApplyStretch()
        else
            StopStretch()
        end
    end,
})

MainTab:Slider({
    Title = "Stretch Intensity",
    Desc = "Ajusta a intensidade da tela esticada",
    Value = {
        Min = 50,
        Max = 120,
        Default = 75,
    },
    Step = 1,
    Callback = function(value)
        getgenv().StretchIntensity = tonumber(value) / 100
    end,
})

-- =====================================================
-- ABA OPTIMIZATION
-- =====================================================
OptiTab:Section({
    Title = "Moura Anti-Lag Engine",
})

OptiTab:Toggle({
    Title = "Dynamic FPS Counter",
    Desc = "Mostra FPS em tempo real; arraste o painel pela tela",
    Value = false,
    Callback = function(value)
        if value then
            CreateFPSCounter()
        else
            DestroyFPSCounter()
        end
    end,
})

OptiTab:Button({
    Title = "Clean Client Lua Memory",
    Desc = "Executa coleta segura de memória sem apagar o mapa",
    Callback = function()
        task.defer(CleanClientMemory)
    end,
})

OptiTab:Button({
    Title = "Apply Native FPS Boost",
    Desc = "Remove partículas, sombras e texturas pesadas",
    Callback = function()
        Notify("Otimizando gráficos e texturas...", 3)

        task.defer(function()
            local Lighting = game:GetService("Lighting")
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Technology = Enum.Technology.Compatibility

            for index, object in ipairs(game:GetDescendants()) do
                pcall(function()
                    if object:IsA("BasePart") then
                        object.Material = Enum.Material.SmoothPlastic
                        object.Reflectance = 0
                    elseif object:IsA("ParticleEmitter")
                        or object:IsA("Trail")
                        or object:IsA("Smoke")
                        or object:IsA("Fire")
                        or object:IsA("Sparkles") then
                        object.Enabled = false
                    elseif object:IsA("PostEffect") then
                        object.Enabled = false
                    end
                end)

                if index % 150 == 0 then
                    task.wait()
                end
            end

            Notify("Jogo otimizado com sucesso!\n:by @mourazx_", 5)
        end)
    end,
})

OptiTab:Button({
    Title = "Apply Ultra FPS Boost",
    Desc = "Modo agressivo: remove fog, sombras, nuvens, água e efeitos",
    Callback = function()
        ApplyUltraFPS()
    end,
})

OptiTab:Button({
    Title = "Restore Visual Settings",
    Desc = "Desfaz somente as alterações do Ultra FPS",
    Callback = function()
        RestoreUltraFPS()
    end,
})

OptiTab:Button({
    Title = "Copy Discord Link",
    Desc = "Copia o convite da comunidade",
    Callback = function()
        if type(setclipboard) == "function" then
            local copied = pcall(function()
                setclipboard(DISCORD_LINK)
            end)

            if copied then
                Notify("Link do Discord copiado!", 4)
            else
                Notify("Não foi possível copiar o link.", 4)
            end
        else
            Notify("Clipboard não suportado neste executor.", 4)
        end
    end,
})

-- Garante que a janela abra diretamente na aba Screen.
task.defer(function()
    -- Nesta versão do WindUI, Window:SelectTab espera o índice da aba,
    -- enquanto a própria aba já expõe o método correto: :Select().
    MainTab:Select()
end)
