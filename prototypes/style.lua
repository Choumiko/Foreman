data.raw["gui-style"].default["blueprint_thin_flow"] =
  {
    type = "flow_style",
    horizontal_spacing = 0,
    vertical_spacing = 0,
    max_on_row = 0,
    resize_row_to_width = true,
  }
data.raw["gui-style"].default["blueprint_thin_frame"] =
  {
    type = "frame_style",
    parent="frame_style",
    top_padding  = 2,
    bottom_padding = 2,
  }

data.raw["gui-style"].default["blueprint_main_frame"] =
  {
    type = "frame_style",
    parent="frame_style",
    top_padding  = 0,
    bottom_padding = 0,
  }

data.raw["gui-style"].default["blueprint_button_flow"] =
  {
    type = "flow_style",
    parent="flow_style",
    horizontal_spacing=1,
  }

data.raw["gui-style"].default["blueprint_info_button_flow"] =
  {
    type = "flow_style",
    parent="blueprint_button_flow",
    top_padding  = 4,
  }

data.raw["gui-style"].default["blueprint_button_style"] =
  {
    type = "button_style",
    parent = "button_style",
    top_padding = 1,
    right_padding = 5,
    bottom_padding = 1,
    left_padding = 5,
    left_click_sound =
    {
      {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
      }
    }
  }

data.raw["gui-style"].default["blueprint_disabled_button"] =
  {
    type = "button_style",
    parent = "blueprint_button_style",

    default_font_color={r=0.34, g=0.34, b=0.34},

    hovered_font_color={r=0.34, g=0.34, b=0.38},
    hovered_graphical_set =
    {
      type = "composition",
      filename = "__core__/graphics/gui.png",
      corner_size = {3, 3},
      position = {0, 0}
    },

    clicked_font_color={r=0.34, g=0.34, b=0.38},
    clicked_graphical_set =
    {
      type = "composition",
      filename = "__core__/graphics/gui.png",
      corner_size = {3, 3},
      position = {0, 0}
    },
  }


data.raw["gui-style"].default["blueprint_selected_button"] =
  {
    type = "button_style",
    parent = "blueprint_button_style",

    default_font_color={r=0, g=0, b=0},
    default_graphical_set =
    {
      type = "composition",
      filename = "__core__/graphics/gui.png",
      corner_size = {3, 3},
      position = {0, 8}
    },

    hovered_font_color={r=1, g=1, b=1},
    hovered_graphical_set =
    {
      type = "composition",
      filename = "__core__/graphics/gui.png",
      corner_size = {3, 3},
      position = {0, 16}
    },

    clicked_font_color={r=0, g=0, b=0},
    clicked_graphical_set =
    {
      type = "composition",
      filename = "__core__/graphics/gui.png",
      corner_size = {3, 3},
      position = {0, 0}
    },
  }

data.raw["gui-style"].default["blueprint_label_style"] =
  {
    type = "label_style",
    font = "default",
    font_color = {r=1, g=1, b=1},
    top_padding = 7,
    bottom_padding = 0,
  }

data.raw["gui-style"].default["blueprint_checkbox_style"] =
  {
    type = "checkbox_style",
    parent = "checkbox_style",
    top_padding = 3,
    right_padding = 10,
    bottom_padding = 3,
    left_padding = 3,
  }