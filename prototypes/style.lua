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

data.raw["gui-style"].default["blueprint_sprite_button"] =
  {
    type = "button_style",
    parent = "blueprint_button_style",
    width = 32,
    height = 32,
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    left_click_sound =
    {
      {
        filename = "__core__/sound/gui-click.ogg",
        volume = 1
      }
    }
  }

data:extend({
  {
    type="sprite",
    name="rename_sprite",
    filename = "__core__/graphics/rename-small.png",
    priority = "extra-high-no-scale",
    width = 16,
    height = 16,
  },
  {
    type="sprite",
    name="delete_sprite",
    filename = "__core__/graphics/remove-icon.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
  },
  {
    type="sprite",
    name="settings_sprite",
    filename = "__core__/graphics/side-menu-icons.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
    x = 0,
  },
  {
    type="sprite",
    name="add_sprite",
    filename = "__core__/graphics/add-icon.png",
    priority = "extra-high-no-scale",
    width = 32,
    height = 32,
  },
  {
    type="sprite",
    name="load_sprite",
    filename = "__Foreman__/graphics/load_icon.png",
    priority = "extra-high-no-scale",
    width = 32,
    height = 32,
  },
  {
    type="sprite",
    name="load_book_sprite",
    filename = "__Foreman__/graphics/load_book.png",
    priority = "extra-high-no-scale",
    width = 32,
    height = 32,
  },
  {
    type="sprite",
    name="save_sprite",
    filename = "__Foreman__/graphics/save_icon.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
  },

})

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

data.raw["gui-style"].default["blueprint_label_style"] =
  {
    type = "label_style",
    font = "default",
    font_color = {r=1, g=1, b=1},
    top_padding = 7,
    bottom_padding = 0,
  }
