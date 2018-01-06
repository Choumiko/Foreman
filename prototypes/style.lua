data.raw["gui-style"].default["blueprint_button_style"] =
  {
    type = "button_style",
    parent = "button",
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
    name="settings_sprite",
    filename = "__core__/graphics/favourite-grey.png",
    priority = "extra-high-no-scale",
    width = 128,
    height = 128,
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
    name="add_book_sprite",
    filename = "__Foreman__/graphics/add_book.png",
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
    name="main_button_sprite",
    filename = "__Foreman__/graphics/mainbutton.png",
    priority = "extra-high-no-scale",
    width = 128,
    height = 128,
  },
  {
    type="sprite",
    name="mirror_sprite",
    filename = "__Foreman__/graphics/mirror_icon.png",
    priority = "extra-high-no-scale",
    width = 64,
    height = 64,
  },

})

data.raw["gui-style"].default["blueprint_main_button"] =
  {
    type = "button_style",
    parent = "blueprint_sprite_button",
    width = 33,
    height = 33,
  }

data.raw["gui-style"].default["blueprint_thin_flow"] =
  {
    type = "horizontal_flow_style",
    horizontal_spacing = 0,
    vertical_spacing = 0,
    max_on_row = 0,
    resize_row_to_width = true,
  }

data.raw["gui-style"].default["blueprint_thin_flow_vertical"] =
  {
    type = "vertical_flow_style",
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
    parent="frame",
    top_padding  = 2,
    bottom_padding = 2,
  }

data.raw["gui-style"].default["blueprint_button_flow"] =
  {
    type = "horizontal_flow_style",
    parent="horizontal_flow",
    horizontal_spacing=1,
  }

data.raw["gui-style"].default["blueprint_info_button_flow"] =
  {
    type = "horizontal_flow_style",
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
