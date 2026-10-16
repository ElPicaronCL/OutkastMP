addEventHandler("onClientHUDRender", root, function()
    -->> Row: Header <<--
    ov_widget.text.draw({
        id = "progress-header",
        text = "<Progress/>",
        x = 100, y = 100 + 24 + 25 + 32 + 25 + 135 - 55,
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



    -->> Column: 1 <<--
    ov_widget.progress.draw({
        id = "progress#1-1",
        type = "horizontal",
        x = 100, y = 100 + 24 + 25 + 32 + 25 + 135,
        width = 275, height = 12, 
        progress = 0.25,
        background_color = {31, 31, 31},
        foreground_color = {22, 104, 220},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#1-2",
        type = "horizontal",
        x = 100, y = 100 + 24 + 25 + 32 + 25 + 135 + 8 + 25,
        width = 275, height = 12, 
        progress = 0.75,
        background_color = {31, 31, 31},
        foreground_color = {220, 68, 70},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#1-3",
        type = "horizontal",
        x = 100, y = 100 + 24 + 25 + 32 + 25 + 135 + 8 + 25 + 8 + 25,
        width = 275, height = 12, 
        progress = 0.5,
        background_color = {31, 31, 31},
        foreground_color = {73, 170, 25},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#1-4",
        type = "horizontal",
        x = 100, y = 100 + 24 + 25 + 32 + 25 + 135 + 8 + 25 + 8 + 25 + 8 + 25,
        width = 275, height = 12, 
        progress = 0.35,
        background_color = {31, 31, 31},
        foreground_color = {200, 200, 200},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#1-5",
        type = "horizontal",
        x = 100, y = 100 + 24 + 25 + 32 + 25 + 135 + 8 + 25 + 8 + 25 + 8 + 25 + 8 + 25,
        width = 275, height = 12, 
        progress = 0.6,
        background_color = {31, 31, 31},
        foreground_color = {216, 150, 20},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })



    -->> Column: 2 <<--
    ov_widget.progress.draw({
        id = "progress#2-1",
        type = "vertical",
        x = 100 + 300 + 25 + 25 + 25, y = 100 + 24 + 25 + 32 + 25 + 133,
        width = 12, height = 142, 
        progress = 0.25,
        background_color = {31, 31, 31},
        foreground_color = {22, 104, 220},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#2-2",
        type = "vertical",
        x = 100 + 300 + 25 + 25 + 25 + 8 + 25, y = 100 + 24 + 25 + 32 + 25 + 133,
        width = 12, height = 142, 
        progress = 0.75,
        background_color = {31, 31, 31},
        foreground_color = {220, 68, 70},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#2-3",
        type = "vertical",
        x = 100 + 300 + 25 + 25 + 25 + 8 + 25 + 8 + 25, y = 100 + 24 + 25 + 32 + 25 + 133,
        width = 12, height = 142, 
        progress = 0.5,
        background_color = {31, 31, 31},
        foreground_color = {73, 170, 25},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#2-4",
        type = "vertical",
        x = 100 + 300 + 25 + 25 + 25 + 8 + 25 + 8 + 25 + 8 + 25, y = 100 + 24 + 25 + 32 + 25 + 133,
        width = 12, height = 142, 
        progress = 0.35,
        background_color = {31, 31, 31},
        foreground_color = {200, 200, 200},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#2-5",
        type = "vertical",
        x = 100 + 300 + 25 + 25 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 8 + 25, y = 100 + 24 + 25 + 32 + 25 + 133,
        width = 12, height = 142, 
        progress = 0.6,
        background_color = {31, 31, 31},
        foreground_color = {216, 150, 20},
        border_radius = 4,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })



    -->> Column: 3 <<--
    ov_widget.progress.draw({
        id = "progress#3-1",
        type = "circle",
        x = 100 + 300 + 25 + 25 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 12 + 25 + 25 + 25 + 25, y = 100 + 24 + 25 + 32 + 25 + 133 + ((142 - 100)*0.5),
        radius = 50,
        progress = 0.5,
        background_color = {31, 31, 31},
        foreground_color = {22, 104, 220},
        border_width = 12,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#3-2",
        type = "circle",
        x = 100 + 300 + 25 + 25 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 12 + 25 + 25 + 25 + 25 + 150, y = 100 + 24 + 25 + 32 + 25 + 133 + ((142 - 100)*0.5),
        radius = 50,
        progress = 0.75,
        background_color = {31, 31, 31},
        foreground_color = {220, 68, 70},
        border_width = 12,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#3-3",
        type = "circle",
        x = 100 + 300 + 25 + 25 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 12 + 25 + 25 + 25 + 25 + 150 + 150, y = 100 + 24 + 25 + 32 + 25 + 133 + ((142 - 100)*0.5),
        radius = 50,
        progress = 0.5,
        background_color = {31, 31, 31},
        foreground_color = {73, 170, 25},
        border_width = 12,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#3-4",
        type = "circle",
        x = 100 + 300 + 25 + 25 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 12 + 25 + 25 + 25 + 25 + 150 + 150 + 150, y = 100 + 24 + 25 + 32 + 25 + 133 + ((142 - 100)*0.5),
        radius = 50,
        progress = 0.35,
        background_color = {31, 31, 31},
        foreground_color = {200, 200, 200},
        border_width = 12,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })

    ov_widget.progress.draw({
        id = "progress#3-5",
        type = "circle",
        x = 100 + 300 + 25 + 25 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 8 + 25 + 12 + 25 + 25 + 25 + 25 + 150 + 150 + 150 + 150, y = 100 + 24 + 25 + 32 + 25 + 133 + ((142 - 100)*0.5),
        radius = 50,
        progress = 0.6,
        background_color = {31, 31, 31},
        foreground_color = {216, 150, 20},
        border_width = 12,
        transition = {
            progress = {duration = 250, easing = "OutQuad"},
            background_color = {duration = 250, easing = "OutQuad"},
            foreground_color = {duration = 250, easing = "OutQuad"}
        },
        on_hover = function(self)
            self.progress = 1
        end
    })
end)