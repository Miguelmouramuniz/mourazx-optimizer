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
    crosshair.Size = UDim2.fromOffset(24, 24)
    crosshair.Position = UDim2.new(0.5, -12, 0.5, -12)
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
    Line("TopShadow", UDim2.fromOffset(2, 8), UDim2.new(0.5, -1, 0, 1), shadow, 1)
    Line("BottomShadow", UDim2.fromOffset(2, 8), UDim2.new(0.5, -1, 1, -9), shadow, 1)
    Line("LeftShadow", UDim2.fromOffset(8, 2), UDim2.new(0, 1, 0.5, -1), shadow, 1)
    Line("RightShadow", UDim2.fromOffset(8, 2), UDim2.new(1, -9, 0.5, -1), shadow, 1)
    Line("TopTip", UDim2.fromOffset(1, 7), UDim2.new(0.5, 0, 0, 2), red, 2)
    Line("BottomTip", UDim2.fromOffset(1, 7), UDim2.new(0.5, 0, 1, -9), red, 2)
    Line("LeftTip", UDim2.fromOffset(7, 1), UDim2.new(0, 2, 0.5, 0), red, 2)
    Line("RightTip", UDim2.fromOffset(7, 1), UDim2.new(1, -9, 0.5, 0), red, 2)

    local center = Instance.new("Frame")
    center.Name = "StarCenter"
    center.Size = UDim2.fromOffset(3, 3)
    center.Position = UDim2.new(0.5, -1.5, 0.5, -1.5)
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
                Lighting.Ambient = Color3.fromRGB(128, 128, 128)
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
                Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
                Lighting.EnvironmentDiffuseScale = 0
                Lighting.EnvironmentSpecularScale = 0
                -- Não forçar Technology: a troca pode recompilar shaders e
                -- causar um pico de travamento durante a aplicação.

                -- Sky minimalista/cinza: sem texturas, estrelas ou corpos
                -- celestes; o renderer usa o fundo neutro do cliente.
                for _, sky in ipairs(Lighting:GetChildren()) do
                    if sky:IsA("Sky") then
                        sky.SkyboxBk = ""
                        sky.SkyboxDn = ""
                        sky.SkyboxFt = ""
                        sky.SkyboxLf = ""
                        sky.SkyboxRt = ""
                        sky.SkyboxUp = ""
                        sky.CelestialBodiesShown = false
                        sky.StarCount = 0
                    end
                end

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
                        setfpscap(60)
                    end)
                end

                for _, object in ipairs(workspace:GetDescendants()) do
                    pcall(function()
                        if object:IsA("BasePart") then
                            object.Material = Enum.Material.Plastic
                            object.MaterialVariant = ""
                            object.Reflectance = 0
                            object.CastShadow = false
                            if object:IsA("MeshPart") then
                                object.TextureID = ""
                            end
                            if IsNativeVFXPart(object) then
                                object.LocalTransparencyModifier = 1
                            end
                        elseif object:IsA("SpecialMesh") then
                            object.TextureId = ""
                        elseif object:IsA("ParticleEmitter")
                            or object:IsA("Trail")
                            or object:IsA("Beam")
                            or object:IsA("Smoke")
                            or object:IsA("Fire")
                            or object:IsA("Sparkles")
                            or object:IsA("Highlight") then
                            object.Enabled = false
                        elseif object:IsA("Decal") or object:IsA("Texture") then
                            object.Transparency = 1
                        elseif object:IsA("SurfaceAppearance") then
                            object.ColorMap = ""
                            object.MetalnessMap = ""
                            object.NormalMap = ""
                            object.RoughnessMap = ""
                        elseif object:IsA("PointLight")
                            or object:IsA("SpotLight")
                            or object:IsA("SurfaceLight") then
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
