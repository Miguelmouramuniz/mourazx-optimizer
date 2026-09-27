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

local BeginOptimization
local EndOptimization
local YieldWithinBudget
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
    if os.clock() - started >= (budget or 0.0015) then
        RunService.Heartbeat:Wait()
        return os.clock()
    end
    return started
end

local AntiLagActive = false
local AntiLagBackup = {}
local AntiLagCreatedObjects = {}
local SaturationEffect

local function AntiLagSave(object, property)
    AntiLagBackup[object] = AntiLagBackup[object] or {}
    if AntiLagBackup[object][property] == nil then
        local ok, value = pcall(function()
            return object[property]
        end)
        if ok then
            AntiLagBackup[object][property] = value
        end
    end
end

local function IsPlayerCharacterObject(object)
    local current = object
    for _ = 1, 8 do
        if not current then
            break
        end
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            return true
        end
        current = current.Parent
    end
    return false
end

local function ApplyOptimizedAntiLag()
    if AntiLagActive or not BeginOptimization() then
        return
    end

    task.defer(function()
        local ok, errorMessage = pcall(function()
            local lighting = game:GetService("Lighting")
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            local settings = UserSettings():GetService("UserGameSettings")

            -- Equivalente local de Low Rendering / qualidade mínima.
            AntiLagSave(settings, "SavedQualityLevel")
            settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1

            AntiLagSave(lighting, "GlobalShadows")
            AntiLagSave(lighting, "FogStart")
            AntiLagSave(lighting, "FogEnd")
            for _, property in ipairs({
                "Ambient", "OutdoorAmbient", "ColorShift_Top",
                "ColorShift_Bottom", "EnvironmentDiffuseScale",
                "EnvironmentSpecularScale",
            }) do
                AntiLagSave(lighting, property)
            end
            lighting.GlobalShadows = false
            lighting.FogStart = 0
            lighting.FogEnd = 9e9
            lighting.Ambient = Color3.fromRGB(145, 145, 145)
            lighting.OutdoorAmbient = Color3.fromRGB(145, 145, 145)
            lighting.ColorShift_Top = Color3.fromRGB(80, 80, 80)
            lighting.ColorShift_Bottom = Color3.fromRGB(80, 80, 80)
            lighting.EnvironmentDiffuseScale = 0
            lighting.EnvironmentSpecularScale = 0

            pcall(function()
                AntiLagSave(lighting, "Technology")
                lighting.Technology = Enum.Technology.Compatibility
            end)

            if terrain then
                for _, property in ipairs({
                    "WaterTransparency", "WaterReflectance",
                    "WaterWaveSize", "WaterWaveSpeed",
                }) do
                    AntiLagSave(terrain, property)
                end
                terrain.WaterTransparency = 1
                terrain.WaterReflectance = 0
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
            end

            for _, sky in ipairs(lighting:GetDescendants()) do
                if sky:IsA("Sky") then
                    for _, property in ipairs({
                        "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf",
                        "SkyboxRt", "SkyboxUp", "CelestialBodiesShown", "StarCount",
                    }) do
                        AntiLagSave(sky, property)
                    end
                    pcall(function() sky.SkyboxBk = "" end)
                    pcall(function() sky.SkyboxDn = "" end)
                    pcall(function() sky.SkyboxFt = "" end)
                    pcall(function() sky.SkyboxLf = "" end)
                    pcall(function() sky.SkyboxRt = "" end)
                    pcall(function() sky.SkyboxUp = "" end)
                    pcall(function() sky.CelestialBodiesShown = false end)
                    pcall(function() sky.StarCount = 0 end)
                end
            end

            -- Skybox sem imagens não aceita uma cor sólida. Para produzir um
            -- céu realmente cinza, usa-se uma Atmosphere neutra e sem haze.
            local grayAtmosphere = lighting:FindFirstChild("MourazxGraySky")
            if not grayAtmosphere then
                grayAtmosphere = Instance.new("Atmosphere")
                grayAtmosphere.Name = "MourazxGraySky"
                grayAtmosphere.Parent = lighting
                table.insert(AntiLagCreatedObjects, grayAtmosphere)
            end
            for _, property in ipairs({"Color", "Decay", "Density", "Haze", "Glare"}) do
                AntiLagSave(grayAtmosphere, property)
            end
            grayAtmosphere.Color = Color3.fromRGB(145, 145, 145)
            grayAtmosphere.Decay = Color3.fromRGB(110, 110, 110)
            -- Density zero remove a neblina; a cor neutra fica no Lighting.
            grayAtmosphere.Density = 0
            grayAtmosphere.Haze = 0
            grayAtmosphere.Glare = 0
            for _, effect in ipairs(lighting:GetDescendants()) do
                if effect:IsA("Atmosphere") and effect ~= grayAtmosphere then
                    AntiLagSave(effect, "Density")
                    AntiLagSave(effect, "Haze")
                    AntiLagSave(effect, "Glare")
                    effect.Density = 0
                    effect.Haze = 0
                    effect.Glare = 0
                end
            end

            if type(setfpscap) == "function" then
                pcall(function()
                    setfpscap(60)
                end)
            end

            local started = os.clock()
            for _, object in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if object:IsA("BasePart") then
                        -- Low Quality Parts / Low Detail Meshes.
                        AntiLagSave(object, "Material")
                        AntiLagSave(object, "Reflectance")
                        AntiLagSave(object, "CastShadow")
                        object.Material = Enum.Material.Plastic
                        object.Reflectance = 0
                        object.CastShadow = false

                        if object:IsA("MeshPart") then
                            AntiLagSave(object, "RenderFidelity")
                            object.RenderFidelity = Enum.RenderFidelity.Performance
                            AntiLagSave(object, "TextureID")
                            object.TextureID = ""
                        end
                    elseif object:IsA("SpecialMesh") then
                        AntiLagSave(object, "MeshType")
                        object.MeshType = Enum.MeshType.FileMesh
                    elseif object:IsA("Decal") or object:IsA("Texture") then
                        -- Images.Invisible = true; Destroy permanece false.
                        AntiLagSave(object, "Transparency")
                        object.Transparency = 1
                    elseif object:IsA("ParticleEmitter")
                        or object:IsA("Trail")
                        or object:IsA("Beam")
                        or object:IsA("Smoke")
                        or object:IsA("Fire")
                        or object:IsA("Sparkles")
                        or object:IsA("Highlight") then
                        -- No Particles.
                        AntiLagSave(object, "Enabled")
                        object.Enabled = false
                    elseif object:IsA("PostEffect") and object ~= SaturationEffect then
                        -- No Camera Effects.
                        AntiLagSave(object, "Enabled")
                        object.Enabled = false
                    elseif object:IsA("Explosion") then
                        -- No Explosions.
                        AntiLagSave(object, "Visible")
                        object.Visible = false
                    elseif object:IsA("SurfaceAppearance") then
                        for _, property in ipairs({
                            "ColorMap", "MetalnessMap", "NormalMap", "RoughnessMap",
                        }) do
                            AntiLagSave(object, property)
                            object[property] = ""
                        end
                    elseif object:IsA("PointLight")
                        or object:IsA("SpotLight")
                        or object:IsA("SurfaceLight") then
                        AntiLagSave(object, "Enabled")
                        object.Enabled = false
                    end
                end)

                -- Micro-lotes para evitar queda brusca durante a aplicação.
                started = YieldWithinBudget(started, 0.00045)
            end
        end)

        AntiLagActive = ok
        EndOptimization()
        if ok then
            Notify("Anti-Lag otimizado aplicado em microetapas.", 5)
        else
            Notify("Anti-Lag interrompido: " .. tostring(errorMessage), 5)
        end
    end)
end

local function RestoreOptimizedAntiLag()
    if not AntiLagActive or not BeginOptimization() then
        return
    end

    task.defer(function()
        local started = os.clock()
        for object, properties in pairs(AntiLagBackup) do
            for property, value in pairs(properties) do
                pcall(function()
                    object[property] = value
                end)
                started = YieldWithinBudget(started, 0.00045)
            end
        end
        for _, object in ipairs(AntiLagCreatedObjects) do
            pcall(function()
                object:Destroy()
            end)
        end
        AntiLagCreatedObjects = {}
        AntiLagBackup = {}
        AntiLagActive = false
        EndOptimization()
        Notify("Anti-Lag restaurado.", 5)
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

local NativeVFXKeywords = {
    "vfx", "effect", "aura", "haki", "slash", "skill", "ability",
    "fruit", "sword", "weapon", "blade", "attack", "explosion",
    "impact", "flame", "magma", "ice", "light", "dark", "quake",
    "dragon", "dough", "leopard", "portal", "buddha", "electric",
}

local function IsNativeVFXPart(object)
    local current = object
    for _ = 1, 4 do
        if not current then
            break
        end

        local name = string.lower(current.Name)
        for _, keyword in ipairs(NativeVFXKeywords) do
            if string.find(name, keyword, 1, true) then
                return true
            end
        end
        current = current.Parent
    end
    return false
end

local SaturationValue = 0

local function SetWorldSaturation(value)
    SaturationValue = math.clamp(tonumber(value) or 0, -100, 100)
    local lighting = game:GetService("Lighting")

    if math.abs(SaturationValue) < 1 then
        if SaturationEffect then
            SaturationEffect.Enabled = false
        end
        return
    end

    if not SaturationEffect then
        SaturationEffect = Instance.new("ColorCorrectionEffect")
        SaturationEffect.Name = "MourazxSaturationControl"
        SaturationEffect.Parent = lighting
    end

    SaturationEffect.Saturation = SaturationValue / 100
    SaturationEffect.Brightness = 0
    SaturationEffect.Contrast = 0
    SaturationEffect.TintColor = Color3.fromRGB(255, 255, 255)
    SaturationEffect.Enabled = true
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

MainTab:Section({
    Title = "Color Control",
})

MainTab:Slider({
    Title = "Game Saturation",
    Desc = "0 mantém as cores normais; use valores negativos para dessaturar",
    Value = {
        Min = -100,
        Max = 100,
        Default = 0,
    },
    Step = 1,
    Callback = function(value)
        SetWorldSaturation(value)
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
    Title = "Apply Optimized Anti-Lag",
    Desc = "Microetapas: partículas, câmera, roupas, água, sombras, meshes e renderização",
    Callback = function()
        ApplyOptimizedAntiLag()
    end,
})

OptiTab:Button({
    Title = "Restore Anti-Lag",
    Desc = "Restaura as propriedades visuais alteradas pelo Anti-Lag",
    Callback = function()
        RestoreOptimizedAntiLag()
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
