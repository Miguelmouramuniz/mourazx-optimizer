-- =====================================================
-- mourazx optimizer - versão corrigida
-- =====================================================

local WINDUI_URL = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
local STRETCH_BIND_NAME = "MourazxCameraStretch"

local function GetRemoteSource(url)
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)

    if ok and type(source) == "string" and #source > 1000 then
        return source
    end

    local httpRequest = request or http_request or (syn and syn.request)
    if type(httpRequest) == "function" then
        local response = httpRequest({
            Url = url,
            Method = "GET",
        })

        if response and response.Body then
            return response.Body
        end
    end

    error("Delta não conseguiu baixar o WindUI. Verifique o HttpGet/request.")
end

local WindUISource = GetRemoteSource(WINDUI_URL)
local WindUILoader, loadError = loadstring(WindUISource)
if not WindUILoader then
    error("WindUI inválido: " .. tostring(loadError))
end

local WindUI = WindUILoader()
if not WindUI then
    error("WindUI retornou nil após o carregamento.")
end

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
pcall(function()
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
    redTheme.Accent = Color3.fromRGB(12, 12, 15)
    redTheme.Outline = Color3.fromRGB(0, 0, 0)
    redTheme.Button = Color3.fromRGB(150, 25, 35)
    redTheme.ElementBackground = Color3.fromRGB(18, 18, 22)
    redTheme.Background = Color3.fromRGB(7, 7, 10)
    redTheme.PanelBackground = Color3.fromRGB(8, 8, 11)
    redTheme.Icon = Color3.fromRGB(255, 95, 100)

    WindUI:AddTheme(redTheme)
    WindUI:SetTheme("MourazxRed")
end)

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

local CrosshairGui
local CrosshairVisible = false

local function CreateCrosshair()
    if CrosshairGui then
        CrosshairGui.Enabled = true
        return
    end

    CrosshairGui = Instance.new("ScreenGui")
    CrosshairGui.Name = "MourazxCrosshair"
    CrosshairGui.ResetOnSpawn = false
    CrosshairGui.IgnoreGuiInset = true
    CrosshairGui.DisplayOrder = 19
    CrosshairGui.Parent = game:GetService("CoreGui")

    local crosshair = Instance.new("Frame")
    crosshair.Name = "RedCrosshair"
    crosshair.Size = UDim2.fromOffset(42, 42)
    crosshair.Position = UDim2.new(0.5, -21, 0.5, -21)
    crosshair.BackgroundTransparency = 1
    crosshair.Parent = CrosshairGui

    local function Line(name, size, position, color, zIndex)
        local line = Instance.new("Frame")
        line.Name = name
        line.Size = size
        line.Position = position
        line.BackgroundColor3 = color
        line.BorderSizePixel = 0
        line.ZIndex = zIndex
        line.Parent = crosshair
    end

    local red = Color3.fromRGB(235, 45, 55)
    local shadow = Color3.fromRGB(20, 0, 2)
    Line("TopShadow", UDim2.fromOffset(2, 12), UDim2.new(0.5, -1, 0, 1), shadow, 1)
    Line("BottomShadow", UDim2.fromOffset(2, 12), UDim2.new(0.5, -1, 1, -13), shadow, 1)
    Line("LeftShadow", UDim2.fromOffset(12, 2), UDim2.new(0, 1, 0.5, -1), shadow, 1)
    Line("RightShadow", UDim2.fromOffset(12, 2), UDim2.new(1, -13, 0.5, -1), shadow, 1)
    Line("TopTip", UDim2.fromOffset(1, 10), UDim2.new(0.5, 0, 0, 2), red, 2)
    Line("BottomTip", UDim2.fromOffset(1, 10), UDim2.new(0.5, 0, 1, -12), red, 2)
    Line("LeftTip", UDim2.fromOffset(10, 1), UDim2.new(0, 2, 0.5, 0), red, 2)
    Line("RightTip", UDim2.fromOffset(10, 1), UDim2.new(1, -12, 0.5, 0), red, 2)

    local center = Instance.new("Frame")
    center.Name = "StarCenter"
    center.Size = UDim2.fromOffset(5, 5)
    center.Position = UDim2.new(0.5, -2.5, 0.5, -2.5)
    center.BackgroundColor3 = Color3.fromRGB(255, 110, 115)
    center.BorderSizePixel = 0
    center.ZIndex = 3
    center.Parent = crosshair

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = center
end

local function SetCrosshairVisible(value)
    CrosshairVisible = value
    if value then
        CreateCrosshair()
    elseif CrosshairGui then
        CrosshairGui.Enabled = false
    end
end

local BeginOptimization
local EndOptimization
local YieldWithinBudget
local FlashFlagsActive = false
local FlashFlagsBackup = {}

local function FlashSave(object, property)
    FlashFlagsBackup[object] = FlashFlagsBackup[object] or {}
    if FlashFlagsBackup[object][property] == nil then
        local ok, value = pcall(function()
            return object[property]
        end)
        if ok then
            FlashFlagsBackup[object][property] = value
        end
    end
end

local function ApplyFlashFlags()
    if FlashFlagsActive or not BeginOptimization() then
        return
    end

    task.defer(function()
        local ok, errorMessage = pcall(function()
            local lighting = game:GetService("Lighting")
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            local settings = UserSettings():GetService("UserGameSettings")

            FlashSave(settings, "SavedQualityLevel")
            settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1

            for _, property in ipairs({
                "GlobalShadows", "FogStart", "FogEnd", "Brightness",
                "Ambient", "OutdoorAmbient", "EnvironmentDiffuseScale",
                "EnvironmentSpecularScale",
            }) do
                FlashSave(lighting, property)
            end

            lighting.GlobalShadows = false
            lighting.FogStart = 0
            lighting.FogEnd = 9e9
            lighting.Brightness = 0
            lighting.Ambient = Color3.fromRGB(128, 128, 128)
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            lighting.EnvironmentDiffuseScale = 0
            lighting.EnvironmentSpecularScale = 0

            for _, object in ipairs(lighting:GetDescendants()) do
                if object:IsA("Sky") then
                    for _, property in ipairs({
                        "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf",
                        "SkyboxRt", "SkyboxUp", "CelestialBodiesShown",
                        "StarCount",
                    }) do
                        FlashSave(object, property)
                    end
                    object.SkyboxBk = ""
                    object.SkyboxDn = ""
                    object.SkyboxFt = ""
                    object.SkyboxLf = ""
                    object.SkyboxRt = ""
                    object.SkyboxUp = ""
                    object.CelestialBodiesShown = false
                    object.StarCount = 0
                elseif object:IsA("Atmosphere") then
                    for _, property in ipairs({"Density", "Haze", "Glare"}) do
                        FlashSave(object, property)
                    end
                    object.Density = 0
                    object.Haze = 0
                    object.Glare = 0
                elseif object:IsA("Clouds") then
                    FlashSave(object, "Cover")
                    FlashSave(object, "Density")
                    object.Cover = 0
                    object.Density = 0
                end
            end

            if terrain then
                for _, property in ipairs({
                    "WaterTransparency", "WaterReflectance", "WaterWaveSize",
                    "WaterWaveSpeed", "Decoration",
                }) do
                    FlashSave(terrain, property)
                end
                terrain.WaterTransparency = 1
                terrain.WaterReflectance = 0
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.Decoration = false
            end

            local started = os.clock()
            for _, object in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if object:IsA("BasePart") then
                        FlashSave(object, "Material")
                        FlashSave(object, "MaterialVariant")
                        FlashSave(object, "Reflectance")
                        FlashSave(object, "CastShadow")
                        object.Material = Enum.Material.Plastic
                        object.MaterialVariant = ""
                        object.Reflectance = 0
                        object.CastShadow = false
                    elseif object:IsA("Decal") or object:IsA("Texture") then
                        FlashSave(object, "Transparency")
                        object.Transparency = 1
                    elseif object:IsA("SurfaceAppearance") then
                        for _, property in ipairs({"ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap"}) do
                            FlashSave(object, property)
                            object[property] = ""
                        end
                    elseif object:IsA("ParticleEmitter")
                        or object:IsA("Trail")
                        or object:IsA("Beam")
                        or object:IsA("Smoke")
                        or object:IsA("Fire")
                        or object:IsA("Sparkles")
                        or object:IsA("Highlight") then
                        FlashSave(object, "Enabled")
                        object.Enabled = false
                    end
                end)
                started = YieldWithinBudget(started, 0.00035)
            end
        end)

        FlashFlagsActive = ok
        EndOptimization()
        if ok then
            Notify("Flash Flags Potato Extreme ativado.", 5)
        else
            Notify("Flash Flags interrompido: " .. tostring(errorMessage), 5)
        end
    end)
end

local function RestoreFlashFlags()
    if not FlashFlagsActive or not BeginOptimization() then
        return
    end

    task.defer(function()
        local started = os.clock()
        for object, properties in pairs(FlashFlagsBackup) do
            for property, value in pairs(properties) do
                pcall(function()
                    object[property] = value
                end)
            end
            started = YieldWithinBudget(started, 0.00035)
        end
        FlashFlagsBackup = {}
        FlashFlagsActive = false
        EndOptimization()
        Notify("Flash Flags restaurado.", 5)
    end)
end

local OptimizationRunning = false

BeginOptimization = function()
    if OptimizationRunning then
        Notify("Uma otimização já está em andamento.", 3)
        return false
    end

    OptimizationRunning = true
    return true
end

EndOptimization = function()
    OptimizationRunning = false
end

YieldWithinBudget = function(started, budget)
    if os.clock() - started >= (budget or 0.002) then
        RunService.Heartbeat:Wait()
        return os.clock()
    end

    return started
end

local PotatoBackup = {}
local PotatoActive = false
local PotatoQualityBackup

local function PotatoSave(object, property)
    PotatoBackup[object] = PotatoBackup[object] or {}

    if PotatoBackup[object][property] == nil then
        local ok, value = pcall(function()
            return object[property]
        end)

        if ok then
            PotatoBackup[object][property] = value
        end
    end
end

local function ApplyPotatoGraphics()
    if PotatoActive or not BeginOptimization() then
        return
    end

    task.defer(function()
        local ok, errorMessage = pcall(function()
            pcall(function()
                local settings = UserSettings():GetService("UserGameSettings")
                PotatoQualityBackup = settings.SavedQualityLevel
                settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
            end)

            local lighting = game:GetService("Lighting")
            -- Iluminação chapada: remove contraste, reflexos e sombras sem
            -- deixar o mapa completamente preto.
            for _, property in ipairs({
                "Brightness", "Ambient", "OutdoorAmbient",
                "ColorShift_Bottom", "ColorShift_Top",
                "EnvironmentDiffuseScale", "EnvironmentSpecularScale",
                "ExposureCompensation",
            }) do
                PotatoSave(lighting, property)
            end

            lighting.GlobalShadows = false
            lighting.Brightness = 0
            lighting.Ambient = Color3.fromRGB(128, 128, 128)
            lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
            lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
            lighting.EnvironmentDiffuseScale = 0
            lighting.EnvironmentSpecularScale = 0
            lighting.ExposureCompensation = 0
            lighting.FogStart = 0
            lighting.FogEnd = 9e9
            -- Não troca Lighting.Technology aqui: essa mudança pode
            -- recompilar shaders e causar uma queda brusca temporária.

            -- Blox Fruits: reduz o custo do céu sem destruir o objeto Sky.
            -- As propriedades são salvas para o botão de restauração.
            for _, object in ipairs(lighting:GetChildren()) do
                if object:IsA("Sky") then
                    for _, property in ipairs({
                        "SkyboxBk", "SkyboxDn", "SkyboxFt",
                        "SkyboxLf", "SkyboxRt", "SkyboxUp",
                        "CelestialBodiesShown", "StarCount",
                        "SunAngularSize", "MoonAngularSize",
                    }) do
                        PotatoSave(object, property)
                    end

                    pcall(function()
                        object.SkyboxBk = ""
                        object.SkyboxDn = ""
                        object.SkyboxFt = ""
                        object.SkyboxLf = ""
                        object.SkyboxRt = ""
                        object.SkyboxUp = ""
                        object.CelestialBodiesShown = false
                        object.StarCount = 0
                        object.SunAngularSize = 0
                        object.MoonAngularSize = 0
                    end)
                end
            end

            -- Reduz o custo visual do oceano/água do Terrain.
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                pcall(function()
                    for _, property in ipairs({
                        "WaterTransparency", "WaterReflectance",
                        "WaterWaveSize", "WaterWaveSpeed", "Decoration",
                    }) do
                        PotatoSave(terrain, property)
                    end

                    terrain.WaterTransparency = 1
                    terrain.WaterReflectance = 0
                    terrain.WaterWaveSize = 0
                    terrain.WaterWaveSpeed = 0
                    terrain.Decoration = false
                end)
            end

            local started = os.clock()

            -- O Potato processa somente o mapa e a iluminação. Uma fila
            -- incremental evita o pico causado por GetDescendants().
            local pending = workspace:GetChildren()
            for _, object in ipairs(lighting:GetChildren()) do
                table.insert(pending, object)
            end

            local cursor = 1
            while cursor <= #pending do
                local object = pending[cursor]
                cursor += 1

                for _, child in ipairs(object:GetChildren()) do
                    table.insert(pending, child)
                end
                pcall(function()
                    if object:IsA("BasePart") then
                        PotatoSave(object, "Material")
                        PotatoSave(object, "MaterialVariant")
                        PotatoSave(object, "Reflectance")
                        PotatoSave(object, "CastShadow")
                        object.Material = Enum.Material.SmoothPlastic
                        object.MaterialVariant = ""
                        object.Reflectance = 0
                        object.CastShadow = false

                    elseif object:IsA("Decal") or object:IsA("Texture") then
                        PotatoSave(object, "Transparency")
                        object.Transparency = 1
                    elseif object:IsA("ParticleEmitter")
                        or object:IsA("Trail")
                        or object:IsA("Beam")
                        or object:IsA("Smoke")
                        or object:IsA("Fire")
                        or object:IsA("Sparkles")
                        or object:IsA("Highlight")
                        or object:IsA("PostEffect") then
                        PotatoSave(object, "Enabled")
                        object.Enabled = false
                    elseif object:IsA("PointLight")
                        or object:IsA("SpotLight")
                        or object:IsA("SurfaceLight") then
                        PotatoSave(object, "Enabled")
                        object.Enabled = false
                    elseif object:IsA("SurfaceAppearance") then
                        -- Remove relevo/metalness/roughness das superfícies.
                        for _, property in ipairs({
                            "ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap",
                        }) do
                            PotatoSave(object, property)
                            pcall(function()
                                object[property] = ""
                            end)
                        end
                    elseif object:IsA("Atmosphere") then
                        PotatoSave(object, "Density")
                        PotatoSave(object, "Haze")
                        PotatoSave(object, "Glare")
                        object.Density = 0
                        object.Haze = 0
                        object.Glare = 0
                    elseif object:IsA("Clouds") then
                        PotatoSave(object, "Cover")
                        PotatoSave(object, "Density")
                        object.Cover = 0
                        object.Density = 0
                    end
                end)

                -- Menos trabalho por frame evita travadas enquanto os VFX
                -- de frutas e espadas são desligados.
                started = YieldWithinBudget(started, 0.00035)
            end

            -- Um teto de 60 evita o executor oscilar agressivamente entre
            -- valores altos e baixos. Não aumenta o FPS se o aparelho não
            -- conseguir renderizar 60 quadros.
            if type(setfpscap) == "function" then
                pcall(function()
                    setfpscap(60)
                end)
            end
        end)

        PotatoActive = ok
        EndOptimization()

        if ok then
            Notify("Potato Graphics ativado gradualmente.", 5)
        else
            Notify("Potato Graphics interrompido: " .. tostring(errorMessage), 5)
        end
    end)
end

local function RestorePotatoGraphics()
    if not PotatoActive or not BeginOptimization() then
        return
    end

    task.defer(function()
        local started = os.clock()

        for object, properties in pairs(PotatoBackup) do
            for property, value in pairs(properties) do
                pcall(function()
                    object[property] = value
                end)
                started = YieldWithinBudget(started)
            end
        end

        if PotatoQualityBackup then
            pcall(function()
                local settings = UserSettings():GetService("UserGameSettings")
                settings.SavedQualityLevel = PotatoQualityBackup
            end)
            PotatoQualityBackup = nil
        end

        PotatoBackup = {}
        PotatoActive = false
        EndOptimization()
        Notify("Potato Graphics restaurado.", 4)
    end)
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
    frame.Size = UDim2.fromOffset(130, 34)
    frame.Position = UDim2.new(1, -108, 0, 18)
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Active = false
    frame.Parent = FPSGui

    FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.fromScale(1, 1)
    FPSLabel.BackgroundTransparency = 1
    -- Arcade é a fonte pixelada mais próxima do estilo Minecraft disponível
    -- nativamente no Roblox, sem depender de asset externo.
    FPSLabel.Font = Enum.Font.Arcade
    FPSLabel.TextSize = 21
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
    FPSLabel.TextYAlignment = Enum.TextYAlignment.Center
    FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FPSLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    FPSLabel.TextStrokeTransparency = 0
    FPSLabel.Text = "FPS  --"
    FPSLabel.Parent = frame

    local frames = 0
    local elapsed = 0

    FPSRenderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        frames += 1
        elapsed += deltaTime
    end)

    FPSUpdateConnection = RunService.Heartbeat:Connect(function()
        if elapsed >= 0.25 and FPSLabel then
            local fps = math.floor((frames / elapsed) + 0.5)

            FPSLabel.Text = "FPS  " .. tostring(fps)
            FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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

local CharacterVisualBackup = {}
local CharacterVisualsHidden = false

local function SaveCharacterProperty(object, property)
    CharacterVisualBackup[object] = CharacterVisualBackup[object] or {}

    if CharacterVisualBackup[object][property] == nil then
        local ok, value = pcall(function()
            return object[property]
        end)

        if ok then
            CharacterVisualBackup[object][property] = value
        end
    end
end

local function SetCharacterVisualsHidden(hidden)
    if hidden == CharacterVisualsHidden then
        return
    end

    if not BeginOptimization() then
        return
    end

    task.defer(function()
        local ok, errorMessage = pcall(function()
            if hidden then
                for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                    local character = player.Character
                    if character then
                        for _, object in ipairs(character:GetDescendants()) do
                            if object:IsA("BasePart")
                                and object:FindFirstAncestorWhichIsA("Accessory") then
                                SaveCharacterProperty(object, "LocalTransparencyModifier")
                                object.LocalTransparencyModifier = 1
                            elseif object:IsA("Shirt") then
                                SaveCharacterProperty(object, "Template")
                                object.Template = ""
                            elseif object:IsA("Pants") then
                                SaveCharacterProperty(object, "PantsTemplate")
                                object.PantsTemplate = ""
                            elseif object:IsA("ShirtGraphic") then
                                SaveCharacterProperty(object, "Graphic")
                                object.Graphic = ""
                            end
                        end
                    end
                end
            else
                for object, properties in pairs(CharacterVisualBackup) do
                    for property, value in pairs(properties) do
                        pcall(function()
                            object[property] = value
                        end)
                    end
                end

                CharacterVisualBackup = {}
            end
        end)

        if ok then
            CharacterVisualsHidden = hidden
            Notify(hidden and "Acessórios e roupas ocultados." or "Acessórios e roupas restaurados.", 4)
        else
            Notify("Alteração visual interrompida: " .. tostring(errorMessage), 5)
        end

        EndOptimization()
    end)
end

local Window = WindUI:CreateWindow({
    Title = "mourazx optimizer",
    Author = ":by @mourazx_",
    Folder = "MourazxOptimizer",
    Size = UDim2.fromOffset(500, 340),
    Transparent = false,
    Theme = "MourazxRed",
    Draggable = true,
    OpenButton = {
        Color = ColorSequence.new(
            Color3.fromRGB(0, 0, 0),
            Color3.fromRGB(0, 0, 0)
        ),
        StrokeThickness = 2,
        CornerRadius = UDim.new(1, 0),
        Draggable = true,
    },
})

local MainTab = Window:Tab({
    Title = "Screen",
    Icon = "monitor",
})

local OptiTab = Window:Tab({
    Title = "Optimization",
    Icon = "zap",
})

local EffectsTab = Window:Tab({
    Title = "PVP Effects",
    Icon = "sparkles",
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

EffectsTab:Section({
    Title = "Character Visual Effects",
})

EffectsTab:Toggle({
    Title = "Red Crosshair",
    Desc = "Mostra somente a mira vermelha central",
    Value = false,
    Callback = function(value)
        SetCrosshairVisible(value)
    end,
})

EffectsTab:Section({
    Title = "Flash Flags • Potato Extreme",
})

EffectsTab:Toggle({
    Title = "Enable Flash Flags Potato",
    Desc = "Qualidade mínima, céu cinza, fog zero, texturas leves e VFX desligados",
    Value = false,
    Callback = function(value)
        if value then
            ApplyFlashFlags()
        else
            RestoreFlashFlags()
        end
    end,
})

EffectsTab:Button({
    Title = "Restore Flash Flags",
    Desc = "Restaura as configurações visuais salvas",
    Callback = function()
        RestoreFlashFlags()
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

OptiTab:Toggle({
    Title = "Hide Accessories & Clothes",
    Desc = "Oculta acessórios e roupas dos personagens sem destruir objetos",
    Value = false,
    Callback = function(value)
        SetCharacterVisualsHidden(value)
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
    Title = "Apply Potato Graphics",
    Desc = "Gráficos leves com materiais plásticos e efeitos reduzidos",
    Callback = function()
        ApplyPotatoGraphics()
    end,
})

OptiTab:Button({
    Title = "Restore Potato Textures",
    Desc = "Restaura texturas e qualidade gráfica do Potato",
    Callback = function()
        RestorePotatoGraphics()
    end,
})




OptiTab:Button({
    Title = "Apply Native FPS Boost",
    Desc = "Remove partículas, sombras e texturas pesadas",
    Callback = function()
        if not BeginOptimization() then
            return
        end

        Notify("Otimizando gráficos e texturas...", 3)

        task.defer(function()
            local ok, errorMessage = pcall(function()
                local Lighting = game:GetService("Lighting")
                local started = os.clock()

                Lighting.GlobalShadows = false
                Lighting.FogStart = 0
                Lighting.FogEnd = 9e9
                Lighting.Technology = Enum.Technology.Compatibility

                -- Remove fontes de neblina que não dependem apenas de FogEnd.
                for _, effect in ipairs(Lighting:GetDescendants()) do
                    if effect:IsA("Atmosphere") then
                        effect.Density = 0
                        effect.Haze = 0
                        effect.Glare = 0
                    elseif effect:IsA("Clouds") then
                        effect.Cover = 0
                        effect.Density = 0
                    end
                end

                -- Alguns executores oferecem setfpscap; em outros, esta etapa
                -- é ignorada e o Anti-Lag segue funcionando normalmente.
                if type(setfpscap) == "function" then
                    pcall(function()
                        setfpscap(90)
                    end)
                end

                for _, object in ipairs(game:GetDescendants()) do
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

                    started = YieldWithinBudget(started)
                end
            end)

            EndOptimization()

            if ok then
                Notify("Jogo otimizado gradualmente com sucesso!", 5)
            else
                Notify("Otimização interrompida: " .. tostring(errorMessage), 5)
            end
        end)
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
