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

data.raw["gui-style"].default["blueprint_delete_button"] =
  {
    type = "button_style",
    parent = "button_style",
    width = 32,
    height = 32,
    font = "auto-trash-small-font",
    sprite = {
      filename = "__core__/graphics/remove-icon.png",
      priority = "extra-high-no-scale",
      width = 64,
      height = 64,
      scale = 0.5,
    },
  }

data.raw["gui-style"].default["foreman_rename_button"] =
  {
    type = "button_style",
    parent = "blueprint_button_style",
    width = 32,
    height = 32,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    font = "auto-trash-small-font",
    sprite = {
      filename = "__core__/graphics/rename-small.png",
      priority = "extra-high-no-scale",
      width = 16,
      height = 16,
      scale = 2,
    },
  }

data.raw["gui-style"].default["blueprint_thin_flow"] =
  {
    type = "flow_style",
    horizontal_spacing = 0,
    vertical_spacing = 0,
    max_on_row = 0,
    resize_row_to_width = true,
  }

data.raw["gui-style"].default["blueprint_scroll_style"] =
  {
    type = "scroll_pane_style",
    vertical_scroll_bar_spacing = 5,
    horizontal_scroll_bar_spacing = 5,
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

data.raw["gui-style"].default["blueprint_settings_button"] =
  {
    type = "button_style",
    parent = "button_style",
    width = 33,
    height = 33,
    default_graphical_set =
    {
      type = "monolith",
      monolith_image =
      {
        filename = "__core__/graphics/side-menu-icons.png",
        priority = "extra-high-no-scale",
        width = 64,
        height = 64,
        x = 0,
      },
      stretch_monolith_image_to_size = false
    },

    hovered_graphical_set =
    {
      type = "monolith",
      monolith_image =
      {
        filename = "__core__/graphics/side-menu-icons.png",
        priority = "extra-high-no-scale",
        width = 64,
        height = 64,
        x = 64,
      },
      stretch_monolith_image_to_size = false
    },

    clicked_graphical_set =
    {
      type = "monolith",
      monolith_image =
      {
        filename = "__core__/graphics/side-menu-icons.png",
        priority = "extra-high-no-scale",
        width = 64,
        height = 64,
        x = 64,
      },
      stretch_monolith_image_to_size = false
    },
    left_click_sound =
    {
      {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
      }
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
