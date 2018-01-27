local Modules = script.Parent.Parent.Parent
local Roact = require(Modules.Roact)
local RoactRodux = require(Modules.RoactRodux)

local Constants = require(script.Parent.Parent.Constants)
local TagManager = require(script.Parent.Parent.TagManager)
local Actions = require(script.Parent.Parent.Actions)

local function TextBox(props)
    local inset = props.Inset or 36
    return Roact.createElement("Frame", {
        Size = props.Size,
        Position = props.Position,
        BackgroundTransparency = 1.0,
        LayoutOrder = props.LayoutOrder,
    }, {
        Label = props.Label and Roact.createElement("TextLabel", {
            Text = props.Label,
            Size = UDim2.new(0, inset, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 20,
            Font = Enum.Font.SourceSans,
            TextColor3 = Constants.Black,
            BackgroundTransparency = 1.0,
        }) or nil,
        Input = Roact.createElement("Frame", {
            Size = UDim2.new(1, -inset, 1, 0),
            Position = UDim2.new(0, inset, 0, 0),
            BackgroundColor3 = Constants.White,
            BorderColor3 = Constants.DarkGrey,
        }, {
            TextBox = Roact.createElement("TextBox", {
                Text = "",
                PlaceholderText = props.Text,
                PlaceholderColor3 = Constants.DarkGrey,
                Font = Enum.Font.SourceSans,
                TextSize = 20,
                TextColor3 = Constants.Black,
                Size = UDim2.new(1, -16, 1, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(.5, 0, .5, 0),
                BackgroundTransparency = 1.0,

                [Roact.Ref] = function(rbx)
                    if not rbx then return end
                    local oldText = rbx.Text
                    if rbx and props.Validate then
                        local debounce = false
                        rbx:GetPropertyChangedSignal("Text"):Connect(function()
                            if debounce then return end
                            debounce = true
                            local text = props.Validate(rbx.Text)
                            if text then
                                rbx.Text = text
                                oldText = text
                            else
                                rbx.Text = oldText
                            end
                            debounce = false
                        end)
                    end
                end,
            })
        })
    })
end

local ColorPicker = Roact.Component:extend("ColorPicker")

function ColorPicker:init()
    self.state = {
        color = Constants.RobloxBlue,
    }
end

function ColorPicker:render()
    local props = self.props
    local color = self.state.color
    local hue, sat, val = Color3.toHSV(color)
    local red, grn, blu = color.r, color.g, color.b
    return Roact.createElement("ImageButton", {
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 2,
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Constants.Black,
        AutoButtonColor = false,
        Visible = props.tagName ~= nil,

        [Roact.Event.MouseButton1Click] = function(rbx)
            props.close()
        end,
    }, {
        Container = Roact.createElement("Frame", {
            BackgroundTransparency = 1.0,
            Size = UDim2.new(1, -20, 1, -20),
            AnchorPoint = Vector2.new(.5, 1),
            Position = UDim2.new(.5, 0, 1, -10),
        }, {
            Window = Roact.createElement("ImageButton", {
                Size = UDim2.new(1, 0, 1, 0),
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.new(0.5, 0, 1, 0),
                BackgroundTransparency = 1.0,
                Image = "rbxasset://textures/ui/btn_newWhite.png",
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(10, 10, 10, 10),
                ImageColor3 = Constants.RobloxRed,
            }, {
                UISizeConstraint = Roact.createElement("UISizeConstraint", {
                    MaxSize = Vector2.new(300, 128+30+16+4+32),
                    MinSize = Vector2.new(256+16, 128+30+16+4+32),
                }),
                Title = Roact.createElement("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 0, 0, 4),
                    Text = "Pick a Color",
                    Font = Enum.Font.SourceSansSemibold,
                    TextColor3 = Constants.White,
                    TextSize = 20,
                    BackgroundTransparency = 1.0,
                }),
                Body = Roact.createElement("Frame", {
                    Size = UDim2.new(1, -10, 1, -30),
                    Position = UDim2.new(.5, 0, 1, -5),
                    AnchorPoint = Vector2.new(.5, 1),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Constants.White,
                }, {
                    UIPadding = Roact.createElement("UIPadding", {
                        PaddingTop = UDim.new(0, 10),
                        PaddingBottom = UDim.new(0, 10),
                        PaddingLeft = UDim.new(0, 10),
                        PaddingRight = UDim.new(0, 10),
                    }),
                    Wheel = Roact.createElement("ImageButton", {
                        Size = UDim2.new(0, 128, 0, 128),
                        BorderColor3 = Constants.DarkGrey,
                        Image = 'rbxassetid://1357075261',
                        BackgroundColor3 = Constants.Black,
                        AutoButtonColor = false,
                        ImageTransparency = 1 - val,

                        [Roact.Event.MouseButton1Down] = function(rbx)
                            self:setState({
                                wheelMouseDown = true,
                            })
                        end,

                        [Roact.Event.InputEnded] = function(rbx, input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 and self.state.wheelMouseDown then
                                local x, y = input.Position.X, input.Position.Y
                                local pos = Vector2.new(x, y) - rbx.AbsolutePosition
                                pos = pos / rbx.AbsoluteSize
                                pos = Vector2.new(math.clamp(pos.x, 0, 1), math.clamp(pos.y, 0, 1))
                                self:setState({
                                    color = Color3.fromHSV(pos.x, 1 - pos.y, val),
                                    wheelMouseDown = false,
                                })
                            end
                        end,

                        [Roact.Event.InputChanged] = function(rbx, input)
                            if self.state.wheelMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
                                local pos = Vector2.new(input.Position.X, input.Position.Y) - rbx.AbsolutePosition
                                pos = pos / rbx.AbsoluteSize

                                self:setState({
                                    color = Color3.fromHSV(pos.x, 1 - pos.y, val),
                                })
                            end
                        end,
                    }, {
                        Position = Roact.createElement("ImageLabel", {
                            Size = UDim2.new(0, 3, 0, 3),
                            BorderSizePixel = 0,
                            Position = UDim2.new(hue, -1, 1 - sat, -1),
                            BackgroundColor3 = Constants.DarkGrey,
                        })
                    }),
                    ValueSlider = Roact.createElement("ImageButton", {
                        Size = UDim2.new(0, 128, 0, 20),
                        Position = UDim2.new(0, 128+8, 0, 0),
                        Image = 'rbxassetid://1357203924',
                        AutoButtonColor = false,

                        [Roact.Event.MouseButton1Down] = function(rbx)
                            self:setState({
                                valueMouseDown = true,
                            })
                        end,

                        [Roact.Event.MouseButton1Up] = function(rbx, x, y)
                            if self.state.valueMouseDown then
                                local pos = x - rbx.AbsolutePosition.X
                                pos = pos / rbx.AbsoluteSize.X
                                pos = math.clamp(pos, 0, 1)

                                self:setState({
                                    valueMouseDown = false,
                                    color = Color3.fromHSV(hue, sat, pos),
                                })
                            end
                        end,

                        [Roact.Event.InputChanged] = function(rbx, input)
                            if self.state.valueMouseDown and input.UserInputType == Enum.UserInputType.MouseMovement then
                                local pos = input.Position.X - rbx.AbsolutePosition.X
                                pos = pos / rbx.AbsoluteSize.x

                                self:setState({
                                    color = Color3.fromHSV(hue, sat, pos),
                                })
                            end
                        end,
                    }, {
                        Position = Roact.createElement("Frame", {
                            Size = UDim2.new(0, 1, 1, 0),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Constants.RobloxBlue,
                            Position = UDim2.new(val, 0, 0, 0),
                        })
                    }),
                    Cancel = Roact.createElement("TextButton", {
                        Text = "Cancel",
                        Size = UDim2.new(0, 80, 0, 24),
                        TextSize = 20,
                        Font = Enum.Font.SourceSansBold,
                        BackgroundColor3 = Constants.RobloxRed,
                        BorderColor3 = Constants.RobloxRed:lerp(Constants.Black, .3333),
                        Position = UDim2.new(.25, 0, 1, 0),
                        AnchorPoint = Vector2.new(.5, 1),
                        TextColor3 = Constants.White,

                        [Roact.Event.MouseButton1Click] = function(rbx)
                            props.close()
                        end,
                    }),
                    Submit = Roact.createElement("TextButton", {
                        Text = "Submit",
                        Size = UDim2.new(0, 80, 0, 24),
                        TextSize = 20,
                        Font = Enum.Font.SourceSansBold,
                        BackgroundColor3 = Constants.RobloxRed,
                        BorderColor3 = Constants.RobloxRed:lerp(Constants.Black, .3333),
                        Position = UDim2.new(.75, 0, 1, 0),
                        AnchorPoint = Vector2.new(.5, 1),
                        TextColor3 = Constants.White,

                        [Roact.Event.MouseButton1Click] = function(rbx)
                            TagManager.Get():SetColor(props.tagName, self.state.color)
                            props.close()
                        end,
                    }),
                    PropertiesPanel = Roact.createElement("Frame", {
                        Position = UDim2.new(0, 128+8, 0, 24),
                        Size = UDim2.new(0, 128, 0, 128),
                        BackgroundTransparency = 1.0,
                    }, {
                        UIListLayout = Roact.createElement("UIListLayout", {
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = UDim.new(0, 4),
                        }),
                        Hex = Roact.createElement(TextBox, {
                            Size = UDim2.new(0, 128, 0, 20),
                            Text = string.format(
                                "%02x%02x%02x",
                                red*255, grn*255, blu*255
                            ),
                            Label = "Hex",
                            LayoutOrder = 1,

                            Validate = function(text)
                                local col = text:match("^%#?(%x?%x?%x?%x?%x?%x?)$")
                                if col then
                                    local r, g, b = col:match("^(%x%x)(%x%x)(%x%x)$")
                                    if not r and g and b then
                                        r, g, b = col:match("^(%x)(%x)(%x)$")
                                        if r and g and b then
                                            col = r..r..g..g..b..b
                                        end
                                    end
                                    if r and g and b then
                                        r = tonumber(r, 16)
                                        g = tonumber(g, 16)
                                        b = tonumber(b, 16)
                                        self:setState({
                                            color = Color3.fromRGB(r, g, b),
                                        })
                                    end
                                end
                                return col
                            end,
                        }),
                        Rgb = Roact.createElement(TextBox, {
                            Size = UDim2.new(0, 128, 0, 20),
                            Text = (function()
                                local col = self.state.color
                                local r, g, b = col.r, col.g, col.b
                                return string.format(
                                    "%d, %d, %d",
                                    r*255, g*255, b*255
                                )
                            end)(),
                            LayoutOrder = 2,
                            Label = "RGB",

                            Validate = function(text)
                                local col = text:match("^%d?%d?%d,%s?%d?%d?%d,%s?%d?%d?%d$")
                                if col then
                                    local r, g, b = col:match("^(%d+),%s?(%d+),%s?(%d+)$")
                                    if r and g and b then
                                        r = tonumber(r)
                                        g = tonumber(g)
                                        b = tonumber(b)
                                        self:setState({
                                            Color3.fromRGB(r, g, b),
                                        })
                                    end
                                end
                                return col
                            end,
                        }),
                        Hsv = Roact.createElement(TextBox, {
                            Size = UDim2.new(0, 128, 0, 20),
                            Text = (function()
                                local col = self.state.color
                                local h, s, v = Color3.toHSV(col)
                                return string.format(
                                    "%d, %d, %d",
                                    h*255, s*255, v*255
                                )
                            end)(),
                            Label = "HSV",
                            LayoutOrder = 3,

                        }),
                        Preview = Roact.createElement("Frame", {
                            LayoutOrder = 10,
                            Size = UDim2.new(1, 0, 0, 32),
                            AnchorPoint = Vector2.new(0, 1),
                            BackgroundColor3 = self.state.color,
                            BorderColor3 = Constants.DarkGrey,
                        }),    
                    }),
                })
            })
        }),
    })
end

ColorPicker = RoactRodux.connect(function(store)
    local state = store:getState()

    return {
        close = function()
            store:dispatch(Actions.ToggleColorPicker(nil))
        end,
        tagName = state.ColorPicker,
    }
end)(ColorPicker)

return ColorPicker
