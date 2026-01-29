local os = require("os")
local wezterm = require("wezterm")
local appearance = require("lua/appearance")

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.window_close_confirmation = "NeverPrompt"

-- [[
--
-- 1. CaskaydiaCove Nerd Font Mono
-- 2. FantasqueSansM Nerd Font Mono
--
-- ]]
config.font = wezterm.font("Maple Mono")
config.font_size = 14.0

-- tabs
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true

config.window_background_opacity = 0.9
config.macos_window_background_blur = 30
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.enable_scroll_bar = true
config.window_padding = {
    left = 16,
    right = 0,
    top = 8,
    bottom = 8,
}

config.window_frame = {
    -- The font used in the tab bar.
    -- Roboto Bold is the default; this font is bundled
    -- with wezterm.
    -- Whatever font is selected here, it will have the
    -- main font setting appended to it to pick up any
    -- fallback fonts you may have used there.
    font = wezterm.font({ family = "Roboto", weight = "Bold" }),
    -- The size of the font in the tab bar.
    -- Default to 10.0 on Windows but 12.0 on other systems
    font_size = 14.0,
    -- The overall background color of the tab bar when
    -- the window is focused
    -- active_titlebar_bg = "#333333",
    -- The overall background color of the tab bar when
    -- the window is not focused
    -- inactive_titlebar_bg = "#333333",
}

wezterm.on("update-status", function(window)
    -- Grab the utf8 character for the "powerline" left facing
    -- solid arrow.
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    -- Grab the current window's configuration, and from it the
    -- palette (this is the combination of your chosen colour scheme
    -- including any overrides).
    local color_scheme = window:effective_config().resolved_palette
    local bg = color_scheme.background
    local fg = color_scheme.foreground

    window:set_right_status(wezterm.format({
        -- First, we draw the arrow...
        { Background = { Color = "none" } },
        { Foreground = { Color = bg } },
        { Text = SOLID_LEFT_ARROW },
        -- Then we draw our text
        { Background = { Color = bg } },
        { Foreground = { Color = fg } },
        { Text = "💻 wenpeng.lei → " .. wezterm.hostname() .. "  " },
    }))
end)

if appearance.is_dark() then
    config.colors = require("lua/cyberdream")
else
    config.colors = require("lua/cyberdream")
end

config.ssh_domains = {}

-- and finally, return the configuration to wezterm
return config
