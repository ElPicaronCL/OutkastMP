addEventHandler("onClientHUDRender", root, function()
    -->> Row: Header <<--
    ov_widget.text.draw({
        id = "button-header",
        text = "<Button/>",
        x = 100, y = 100 - 55,
        width = 113, height = 50, 
        text_align_x = "left",
        color = {220, 68, 70},
        font_family = assetify.interface.createFont(":ov_components/.test/fonts/Dosis-Bold.ttf", 18),
        font_scale = 1,
        background_color = {22, 104, 220},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {22, 104, 220}
        end
    })



    -->> Row: 1 <<--
    ov_widget.button.draw({
        id = "button#1-1",
        text = "Button#1 - 1",
        x = 100, y = 100,
        width = 113, height = 24, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {22, 104, 220},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {22*0.65, 104*0.65, 220*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-2",
        icon = "search",
        x = 100 + 113 + 25, y = 100,
        width = 24, height = 24, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {22, 104, 220},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {22*0.65, 104*0.65, 220*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-3",
        text = "Button#1 - 3",
        x = 100 + 113 + 25 + 24 + 25, y = 100,
        width = 113, height = 24, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-4",
        icon = "search",
        x = 100 + 113 + 25 + 24 + 25 + 113 + 25, y = 100,
        width = 24, height = 24, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-5",
        text = "Button#1 - 5",
        x = 100 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25, y = 100,
        width = 113, height = 24, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-6",
        icon = "search",
        x = 100 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25, y = 100,
        width = 24, height = 24, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-7",
        text = "Button#1 - 7",
        x = 100 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25, y = 100,
        width = 113, height = 24, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {220, 68, 70},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {220*0.65, 68*0.65, 70*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-8",
        icon = "search",
        x = 100 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 113 + 25 + 24 + 25, y = 100,
        width = 24, height = 24, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {220, 68, 70},
        border_radius = 4,
        border_color = {0, 0, 0},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {220*0.65, 68*0.65, 70*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-9",
        text = "Button#1 - 9",
        x = 100 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25, y = 100,
        width = 113, height = 24, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-10",
        icon = "search",
        x = 100 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 113 + 25 + 24 + 25, y = 100,
        width = 24, height = 24, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-11",
        text = "Button#1 - 11",
        x = 100 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 113 + 25 + 24 + 25 + 24 + 25, y = 100,
        width = 113, height = 24, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#1-12",
        icon = "search",
        x = 100 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 24 + 25 + 113 + 25 + 113 + 25 + 24 + 25 + 24 + 25 + 113 + 25, y = 100,
        width = 24, height = 24, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })



    -->> Row: 2 <<--
    ov_widget.button.draw({
        id = "button#2-1",
        text = "Button#2 - 1",
        x = 100, y = 100 + 24 + 25,
        width = 129, height = 32,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {22, 104, 220},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {22*0.65, 104*0.65, 220*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-2",
        icon = "search",
        x = 100 + 129 + 25, y = 100 + 24 + 25,
        width = 32, height = 32, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {22, 104, 220},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {22*0.65, 104*0.65, 220*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-3",
        text = "Button#2 - 3",
        x = 100 + 129 + 25 + 32 + 25, y = 100 + 24 + 25,
        width = 129, height = 32,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-4",
        icon = "search",
        x = 100 + 129 + 25 + 32 + 25 + 129 + 25, y = 100 + 24 + 25,
        width = 32, height = 32,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-5",
        text = "Button#2 - 5",
        x = 100 + 129 + 25 + 32 + 25 + 129 + 25, y = 100 + 24 + 25,
        width = 129, height = 32,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-6",
        icon = "search",
        x = 100 + 129 + 25 + 32 + 25 + 129 + 25 + 129 + 25, y = 100 + 24 + 25,
        width = 32, height = 32,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-7",
        text = "Button#2 - 7",
        x = 100 + 129 + 25 + 32 + 25 + 129 + 25 + 129 + 25 + 32 + 25, y = 100 + 24 + 25,
        width = 129, height = 32, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {220, 68, 70},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {220*0.65, 68*0.65, 70*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-8",
        icon = "search",
        x = 100 + 129 + 25 + 32 + 25 + 129 + 25 + 129 + 25 + 32 + 25 + 129 + 25, y = 100 + 24 + 25,
        width = 32, height = 32, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {220, 68, 70},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {220*0.65, 68*0.65, 70*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-9",
        text = "Button#2 - 9",
        x = 100 + 129 + 25 + 32 + 25 + 129 + 25 + 129 + 25 + 32 + 25 + 129 + 25 + 32 + 25, y = 100 + 24 + 25,
        width = 129, height = 32, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-10",
        icon = "search",
        x = 100 + 129 + 25 + 32 + 25 + 129 + 25 + 129 + 25 + 32 + 25 + 129 + 25 + 32 + 25 + 129 + 25, y = 100 + 24 + 25,
        width = 32, height = 32, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-11",
        text = "Button#2 - 11",
        x = 100 + 129 + 25 + 32 + 25 + 129 + 25 + 129 + 25 + 32 + 25 + 129 + 25 + 32 + 25 + 129 + 25 + 32 + 25, y = 100 + 24 + 25,
        width = 129, height = 32, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#2-12",
        icon = "search",
        x = 100 + 129 + 25 + 32 + 25 + 129 + 25 + 129 + 25 + 32 + 25 + 129 + 25 + 32 + 25 + 129 + 25 + 32 + 25 + 129 + 25, y = 100 + 24 + 25,
        width = 32, height = 32, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })



    -->> Row: 3 <<--
    ov_widget.button.draw({
        id = "button#3-1",
        text = "Button#3 - 1",
        x = 100, y = 100 + 24 + 25 + 32 + 25,
        width = 143, height = 40,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {22, 104, 220},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {22*0.65, 104*0.65, 220*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-2",
        icon = "search",
        x = 100 + 143 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 40, height = 40,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {22, 104, 220},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {22*0.65, 104*0.65, 220*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-3",
        text = "Button#3 - 3",
        x = 100 + 143 + 25 + 40 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 143, height = 40,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-4",
        icon = "search",
        x = 100 + 143 + 25 + 40 + 25 + 143 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 40, height = 40,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-5",
        text = "Button#3 - 5",
        x = 100 + 143 + 25 + 40 + 25 + 143 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 143, height = 40,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-6",
        icon = "search",
        x = 100 + 143 + 25 + 40 + 25 + 143 + 25 + 143 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 40, height = 40,
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {66, 66, 66},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-7",
        text = "Button#3 - 7",
        x = 100 + 143 + 25 + 40 + 25 + 143 + 25 + 143 + 25 + 40 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 143, height = 40, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {220, 68, 70},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {220*0.65, 68*0.65, 70*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-8",
        icon = "search",
        x = 100 + 143 + 25 + 40 + 25 + 143 + 25 + 143 + 25 + 40 + 25 + 143 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 40, height = 40, 
        color = {255, 255, 255},
        font_family = "default-bold",
        background_color = {220, 68, 70},
        border_radius = 4,
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {255*0.65, 255*0.65, 255*0.65}
            self.background_color = {220*0.65, 68*0.65, 70*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-9",
        text = "Button#3 - 9",
        x = 100 + 143 + 25 + 40 + 25 + 143 + 25 + 143 + 25 + 40 + 25 + 143 + 25 + 40 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 143, height = 40, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-10",
        icon = "search",
        x = 100 + 143 + 25 + 40 + 25 + 143 + 25 + 143 + 25 + 40 + 25 + 143 + 25 + 40 + 25 + 143 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 40, height = 40, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-11",
        text = "Button#3 - 11",
        x = 100 + 143 + 25 + 40 + 25 + 143 + 25 + 143 + 25 + 40 + 25 + 143 + 25 + 40 + 25 + 143 + 25 + 40 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 143, height = 40, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })

    ov_widget.button.draw({
        id = "button#3-12",
        icon = "search",
        x = 100 + 143 + 25 + 40 + 25 + 143 + 25 + 143 + 25 + 40 + 25 + 143 + 25 + 40 + 25 + 143 + 25 + 40 + 25 + 143 + 25, y = 100 + 24 + 25 + 32 + 25,
        width = 40, height = 40, 
        color = {220, 68, 70},
        font_family = "default-bold",
        background_color = {20, 20, 20},
        border_radius = 4,
        border_width = 1,
        border_dash = 3,
        border_color = {220, 68, 70},
        transition = {
            color = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.color = {220*0.65, 68*0.65, 70*0.65}
            self.background_color = {20*0.65, 20*0.65, 20*0.65}
        end
    })
end)