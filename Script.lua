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
local HttpService = game:GetService("HttpService")

local DISCORD_LINK = "https://discord.gg/BgDrtUVtZw"
local FastFlagText = "{}"

local function Notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "mourazx optimizer",
            Text = text,
            Duration = duration or 4,
        })
    end)
end

local MiniStatusGui
local MiniStatusLabel

local function SetMiniStatus(text, visible)
    pcall(function()
        if not MiniStatusGui then
            local parent = (gethui and gethui()) or game:GetService("CoreGui")
            MiniStatusGui = Instance.new("ScreenGui")
            MiniStatusGui.Name = "MourazxMiniStatus"
            MiniStatusGui.ResetOnSpawn = false
            MiniStatusGui.IgnoreGuiInset = true
            MiniStatusGui.DisplayOrder = 999998
            MiniStatusGui.Parent = parent

            local frame = Instance.new("Frame")
            frame.Name = "Status"
            frame.Size = UDim2.fromOffset(190, 28)
            frame.Position = UDim2.fromOffset(12, 12)
            frame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
            frame.BackgroundTransparency = 0.12
            frame.BorderSizePixel = 0
            frame.Parent = MiniStatusGui

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(220, 45, 55)
            stroke.Thickness = 1
            stroke.Parent = frame

            MiniStatusLabel = Instance.new("TextLabel")
            MiniStatusLabel.BackgroundTransparency = 1
            MiniStatusLabel.Size = UDim2.fromScale(1, 1)
            MiniStatusLabel.Font = Enum.Font.GothamSemibold
            MiniStatusLabel.TextSize = 12
            MiniStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            MiniStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
            MiniStatusLabel.Parent = frame
        end

        MiniStatusLabel.Text = text or ""
        MiniStatusGui.Enabled = visible ~= false
    end)
end

local function ClearMiniStatus()
    pcall(function()
        if MiniStatusGui then
            MiniStatusGui.Enabled = false
        end
    end)
end

local function ExecuteFastFlags()
    local ok, flags = pcall(function()
        return HttpService:JSONDecode(FastFlagText)
    end)

    if not ok or type(flags) ~= "table" then
        Notify("Fast Flag inválida: cole um JSON válido.", 5)
        return
    end

    if type(setfflag) ~= "function" then
        Notify("Este executor não oferece setfflag. As flags não foram aplicadas.", 6)
        return
    end

    local applied = 0
    local failed = 0
    local skipped = 0
    for name, value in pairs(flags) do
        if type(name) == "string"
            and (type(value) == "string" or type(value) == "number" or type(value) == "boolean") then
            local valueText = value
            if type(value) == "boolean" then
                valueText = value and "True" or "False"
            else
                valueText = tostring(value)
            end

            if pcall(function()
                setfflag(name, valueText)
            end) then
                applied += 1
            else
                failed += 1
            end
        else
            skipped += 1
        end
    end

    Notify(string.format("Fast Flags: %d aplicadas, %d rejeitadas, %d ignoradas. Reinicie o jogo se necessário.", applied, failed, skipped), 7)
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
    SetMiniStatus("Tela esticada: desativando...", true)
    pcall(function()
        RunService:UnbindFromRenderStep(STRETCH_BIND_NAME)
    end)

    getgenv().StretchConn = nil
    ClearMiniStatus()
end

local function ApplyStretch()
    SetMiniStatus("Tela esticada: ativando...", true)
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
    ClearMiniStatus()
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

local function YieldWithinBudget(started, budget)
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

    SetMiniStatus("Potato: otimizando...", true)
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

            -- Alguns ataques são desenhados no PlayerGui. Incluímos apenas
            -- essa árvore para desligar seus VFX, sem tocar nas animações.
            pcall(function()
                local player = game:GetService("Players").LocalPlayer
                local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
                if playerGui then
                    for _, object in ipairs(playerGui:GetChildren()) do
                        table.insert(pending, object)
                    end
                end
            end)

            local cursor = 1
            local lastStatus = os.clock()
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

                if os.clock() - lastStatus >= 0.5 then
                    SetMiniStatus("Potato: otimizando...", true)
                    lastStatus = os.clock()
                end
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
            ClearMiniStatus()
            Notify("Potato Graphics ativado gradualmente.", 5)
        else
            ClearMiniStatus()
            Notify("Potato Graphics interrompido: " .. tostring(errorMessage), 5)
        end
    end)
end

local function RestorePotatoGraphics()
    if not PotatoActive or not BeginOptimization() then
        return
    end

    SetMiniStatus("Potato: restaurando...", true)
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
        ClearMiniStatus()
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
    SetMiniStatus("Memória Lua: limpando...", true)
    local before = collectgarbage("count")

    -- Libera objetos Lua sem remover partes do mapa ou texturas do jogo.
    collectgarbage("collect")
    task.wait()
    collectgarbage("collect")

    local after = collectgarbage("count")
    local released = math.max(0, before - after)
    ClearMiniStatus()
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

local FastFlagsTab = Window:Tab({
    Title = "Fast Flags",
    Icon = "code",
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

        SetMiniStatus("Native FPS: otimizando...", true)
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
            ClearMiniStatus()

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

-- =====================================================
-- ABA FAST FLAGS
-- =====================================================
FastFlagsTab:Section({
    Title = "Fast Flag JSON Executor",
})

FastFlagsTab:Paragraph({
    Title = "Execução de Fast Flags",
    Desc = "Tenta todas as entradas simples do JSON; a compatibilidade depende do executor e da versão do cliente.",
})

FastFlagsTab:Input({
    Title = "Fast Flag JSON",
    Desc = "Cole aqui o conteúdo do arquivo .json",
    Value = FastFlagText,
    Placeholder = '{"FFlagDisablePostFx":"True"}',
    Text = "",
    Callback = function(value)
        FastFlagText = tostring(value or "{}")
    end,
})

FastFlagsTab:Button({
    Title = "Execute Fast Flag",
    Desc = "Valida o JSON e tenta aplicar todas as flags escalares",
    Callback = function()
        SetMiniStatus("Fast Flags: aplicando...", true)
        task.defer(function()
            ExecuteFastFlags()
            ClearMiniStatus()
        end)
    end,
})

-- Garante que a janela abra diretamente na aba Screen.
task.defer(function()
    -- Nesta versão do WindUI, Window:SelectTab espera o índice da aba,
    -- enquanto a própria aba já expõe o método correto: :Select().
    MainTab:Select()
end)
