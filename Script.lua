-- =====================================================
--  mourazx optimizer - Rayfield Custom Red Edition
--  Created by @mourazx_
-- =====================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "mourazx optimizer",
    LoadingTitle = "mourazx optimizer",
    LoadingSubtitle = "by @mourazx_",
    Theme = "Red",
    ConfigurationSaving = {
        Enabled = false
    },
    CustomTheme = {
        TextColor = Color3.fromRGB(240, 240, 240),
        Background = Color3.fromRGB(25, 25, 25),
        Topbar = Color3.fromRGB(35, 35, 35),
        Shadow = Color3.fromRGB(15, 15, 15),
        NotificationBackground = Color3.fromRGB(20, 20, 20),
        NotificationActionsBackground = Color3.fromRGB(255, 30, 30),
        TabBackground = Color3.fromRGB(40, 40, 40),
        TabTextColor = Color3.fromRGB(230, 230, 230),
        SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
        ElementBackground = Color3.fromRGB(35, 35, 35),
        ElementBackgroundHover = Color3.fromRGB(45, 45, 45),
        SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
        ElementTitle = Color3.fromRGB(255, 255, 255),
        SecondaryElementTitle = Color3.fromRGB(200, 200, 200),
        
        -- Chaves de destaque totalmente vermelhas
        Accent = Color3.fromRGB(255, 30, 30),
        Outline = Color3.fromRGB(255, 30, 30)
    }
})

-- Abas sem emojis
local MainTab = Window:CreateTab("Main", nil)
local OptiTab = Window:CreateTab("Optimization", nil)

-- =====================================================
--  MAIN TAB (STRETCHED SCREEN)
-- =====================================================

MainTab:CreateSection("Stretch Settings")

MainTab:CreateToggle({
    Name = "Enable Stretched Screen",
    CurrentValue = true,
    Callback = function(Value)
        getgenv().StretchEnabled = Value
        if Value then ApplyStretch() else
            if getgenv().StretchConn then getgenv().StretchConn:Disconnect() end
        end
    end,
})

MainTab:CreateSlider({
    Name = "Stretch Intensity",
    Range = {0.5, 1.2},
    Increment = 0.01,
    CurrentValue = 0.75,
    Callback = function(Value)
        getgenv().StretchIntensity = Value
        if getgenv().StretchEnabled then ApplyStretch() end
    end,
})

MainTab:CreateSection("Performance Options")

MainTab:CreateToggle({
    Name = "Disable Particles",
    Callback = function(Value)
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") then
                v.Enabled = not Value
            end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Disable Shadows",
    Callback = function(Value)
        game:GetService("Lighting").GlobalShadows = not Value
    end,
})

MainTab:CreateToggle({
    Name = "Low Texture Quality",
    Callback = function(Value)
        settings().Rendering.QualityLevel = Value and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
    end,
})

MainTab:CreateToggle({
    Name = "Remove Textures (Plastic Only)",
    Callback = function(Value)
        pcall(function()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
                    obj.Transparency = Value and 1 or 0
                    obj.Visible = not Value
                elseif obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
                    if Value then
                        obj.Material = Enum.Material.Plastic
                    end
                end
            end

            for _, plr in pairs(game.Players:GetPlayers()) do
                if plr.Character then
                    for _, obj in pairs(plr.Character:GetDescendants()) do
                        if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SurfaceAppearance") then
                            obj.Transparency = Value and 1 or 0
                            obj.Visible = not Value
                        elseif obj:IsA("BasePart") or obj:IsA("MeshPart") then
                            if Value then
                                obj.Material = Enum.Material.Plastic
                            end
                        end
                    end
                end
            end
        end)
    end,
})

-- =====================================================
--  OPTIMIZATION TAB
-- =====================================================

OptiTab:CreateSection("Moura Anti-Lag Engine")

OptiTab:CreateButton({
    Name = "Apply FPS Boost Native (Anti-Freeze)",
    Callback = function()
        Rayfield:Notify({
            Title = "mourazx optimizer",
            Content = "Otimizando o jogo de forma suave...",
            Duration = 3,
        })

        task.defer(function()
            local Lighting = game:GetService("Lighting")
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Technology = Enum.Technology.Compatibility

            local descendants = game:GetDescendants()
            for i, v in ipairs(descendants) do
                pcall(function()
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v:Destroy()
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    elseif v:IsA("PostEffect") then
                        v.Enabled = false
                    end
                end)

                if i % 150 == 0 then
                    task.wait()
                end
            end

            Rayfield:Notify({
                Title = "mourazx optimizer",
                Content = "Jogo otimizado com sucesso! Criado por @mourazx_",
                Duration = 5,
            })
        end)
    end,
})

-- =====================================================
--  LOGIC & OVERRIDES (FORÇA VERMELHO E BOTAO MINIMIZAR)
-- =====================================================

local stretchConnection = nil
function ApplyStretch()
    if stretchConnection then stretchConnection:Disconnect() end
    stretchConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().StretchEnabled and workspace.CurrentCamera then
            local cam = workspace.CurrentCamera
            cam.CFrame = cam.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().StretchIntensity or 0.75, 0, 0, 0, 1)
        end
    end)
end

getgenv().StretchEnabled = true
getgenv().StretchIntensity = 0.75
ApplyStretch()

-- Força a troca de cores azuis do Rayfield para Vermelho e altera o botão de Minimizar
task.spawn(function()
    task.wait(1)
    pcall(function()
        local gui = game:GetService("CoreGui"):FindFirstChild("Rayfield") or game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Rayfield")
        if gui then
            -- 1. Varredura para substituir o azul pelo vermelho
            for _, v in pairs(gui:GetDescendants()) do
                if v:IsA("Frame") or v:IsA("TextButton") or v:IsA("ImageLabel") then
                    local color = v.BackgroundColor3
                    if color.B > color.R and color.B > 0.3 then
                        v.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
                    end
                end
                if v:IsA("UIStroke") then
                    local strokeColor = v.Color
                    if strokeColor.B > strokeColor.R and strokeColor.B > 0.3 then
                        v.Color = Color3.fromRGB(255, 30, 30)
                    end
                end
            end

            -- 2. Alterar ação do botão Minimizar para fechar/destruir o menu diretamente
            for _, btn in pairs(gui:GetDescendants()) do
                if btn:IsA("ImageButton") or btn:IsA("TextButton") then
                    if btn.Name:lower():match("minimize") or btn.Name:lower():match("hide") then
                        btn.MouseButton1Click:Connect(function()
                            gui:Destroy()
                        end)
                    end
                end
            end
        end
    end)
end)

Rayfield:Notify({
    Title = "mourazx optimizer",
    Content = "Criado por @mourazx_",
    Duration = 6,
})

print("mourazx optimizer Loaded")
