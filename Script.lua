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

local OptimizationRunning = false

local function BeginOptimization()
    if OptimizationRunning then
        Notify("Uma otimização já está em andamento.", 3)
        return false
    end

    OptimizationRunning = true
    return true
end

local function EndOptimization()
    OptimizationRunning = false
end

local function YieldWithinBudget(started)
    if os.clock() - started >= 0.002 then
        RunService.Heartbeat:Wait()
        return os.clock()
    end

    return started
end

local CombatFXBackup = {}
local CombatFXActive = false

local function IsCombatEffect(object)
    local names = {}
    local current = object

    -- Verifica o efeito e alguns ancestrais para encontrar VFX nomeados
    -- como haki, aura, skill ou ataque sem tocar na interface do jogador.
    for _ = 1, 4 do
        if not current then
            break
        end

        table.insert(names, string.lower(current.Name))
        current = current.Parent
    end

    local combinedName = table.concat(names, " ")
    local keywords = {
        "haki", "buso", "armament", "aura", "combat", "attack",
        "skill", "ability", "vfx", "effect", "hit", "slash",
        "explosion", "impact", "damage", "sword", "fighting",
    }

    for _, keyword in ipairs(keywords) do
        if string.find(combinedName, keyword, 1, true) then
            return true
        end
    end

    return false
end

local function CleanCombatEffects()
    if CombatFXActive or not BeginOptimization() then
        return
    end

    task.defer(function()
        local ok, errorMessage = pcall(function()
            local started = os.clock()

            for _, object in ipairs(workspace:GetDescendants()) do
                local supported = object:IsA("ParticleEmitter")
                    or object:IsA("Trail")
                    or object:IsA("Beam")
                    or object:IsA("Smoke")
                    or object:IsA("Fire")
                    or object:IsA("Sparkles")
                    or object:IsA("Highlight")

                if supported and IsCombatEffect(object) then
                    pcall(function()
                        CombatFXBackup[object] = object.Enabled
                        object.Enabled = false
                    end)
                end

                started = YieldWithinBudget(started)
            end
        end)

        CombatFXActive = ok
        EndOptimization()

        if ok then
            Notify("Efeitos de combate e Buso Haki reduzidos.", 5)
        else
            Notify("Limpeza PvP interrompida: " .. tostring(errorMessage), 5)
        end
    end)
end

local function RestoreCombatEffects()
    if not CombatFXActive or not BeginOptimization() then
        return
    end

    task.defer(function()
        local started = os.clock()

        for object, enabled in pairs(CombatFXBackup) do
            pcall(function()
                object.Enabled = enabled
            end)
            started = YieldWithinBudget(started)
        end

        CombatFXBackup = {}
        CombatFXActive = false
        EndOptimization()
        Notify("Efeitos de combate restaurados.", 4)
    end)
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
            lighting.Technology = Enum.Technology.Compatibility

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

            -- O Potato reúne o Anti-Lag normal e aplica uma camada extra nas
            -- texturas. Tudo é feito em microetapas para evitar congelamento.
            for _, object in ipairs(game:GetDescendants()) do
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
                        or object:IsA("Smoke")
                        or object:IsA("Fire")
                        or object:IsA("Sparkles")
                        or object:IsA("PostEffect") then
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
                        object.Density = 0
                        object.Haze = 0
                        object.Glare = 0
                    elseif object:IsA("Clouds") then
                        object.Cover = 0
                        object.Density = 0
                    end
                end)

                started = YieldWithinBudget(started)
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
    Title = "Apply Potato Graphics",
    Desc = "Anti-Lag mais forte com texturas 2D reduzidas",
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
    Title = "Apply Low CPU Mode",
    Desc = "Iluminação, relevos, materiais e efeitos no mínimo",
    Callback = function()
        ApplyPotatoGraphics()
    end,
})

OptiTab:Button({
    Title = "Restore Low CPU Mode",
    Desc = "Restaura materiais, texturas e efeitos anteriores",
    Callback = function()
        RestorePotatoGraphics()
    end,
})

OptiTab:Button({
    Title = "Clean PvP Combat Effects",
    Desc = "Desativa partículas de combate, aura e Buso Haki",
    Callback = function()
        CleanCombatEffects()
    end,
})

OptiTab:Button({
    Title = "Restore PvP Effects",
    Desc = "Restaura os efeitos de combate desativados",
    Callback = function()
        RestoreCombatEffects()
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
