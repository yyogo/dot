local wezterm = require 'wezterm';

-- The filled in variant of the < symbol
local SOLID_LEFT_DIAGONAL = utf8.char(0xe0ba)

-- The filled in variant of the > symbol
local SOLID_RIGHT_DIAGONAL = utf8.char(0xe0bc)


local format_tab = function(active, hover, title, max_width)
    local edge_background = "#0b0022"
    local edge_foreground = "#1b1032"
    local background = "#1b1032"
    local foreground = "#808080"
  
    if is_active then
      background = "#1b4030"
      foreground = "#d0d0d0"
    elseif hover then
      background = "#3b3052"
      foreground = "#909090"
    end

  return {
    {Background={Color=edge_background}},
    {Foreground={Color=edge_foreground}},
    {Text=SOLID_LEFT_DIAGONAL},
    {Background={Color=background}},
    {Foreground={Color=foreground}},
    {Text=" "..title},
    {Background={Color=edge_background}},
    {Foreground={Color=edge_foreground}},
    {Text=SOLID_RIGHT_DIAGONAL},
  }
end

-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
--     local title = wezterm.truncate_left(tab.active_pane.title, max_width-2)
--     return format_tab(tab.is_active, hover, title, max_width)
-- end)

return {
    --enable_tab_bar = false,
    --hide_tab_bar_if_only_one_tab = true,
    tab_bar_at_bottom = true,
    send_composed_key_when_alt_is_pressed = false,
    adjust_window_size_when_changing_font_size = false,
    use_ime = false,
    
    font = wezterm.font_with_fallback({
        {family="JetBrains Mono", weight="Light"},
        {family="MesloLGS NF"},
    }), 
    freetype_load_target = "Light",
    font_size = 14.5,
    
    keys = {
        {key="LeftArrow", mods="ALT", action=wezterm.action{SendString="\x1bb"}},
        {key="RightArrow", mods="ALT", action=wezterm.action{SendString="\x1bf"}},
        {key="UpArrow", mods="ALT", action=wezterm.action{SendString="\x1b[1;3A"}},
        {key="DownArrow", mods="ALT", action=wezterm.action{SendString="\x1b[1;3B"}},
        
        {key=".", mods="ALT", action=wezterm.action{SendString="\x1b."}},
        {key="b", mods="ALT", action=wezterm.action{SendString="\x1bb"}},
        {key="f", mods="ALT", action=wezterm.action{SendString="\x1bf"}},
        {key="d", mods="ALT", action=wezterm.action{SendString="\x1bd"}},

        {key="1", mods="ALT", action=wezterm.action{SendString="\x1b1"}},
        {key="2", mods="ALT", action=wezterm.action{SendString="\x1b2"}},
        {key="3", mods="ALT", action=wezterm.action{SendString="\x1b3"}},
        {key="4", mods="ALT", action=wezterm.action{SendString="\x1b4"}},
        {key="5", mods="ALT", action=wezterm.action{SendString="\x1b5"}},
        {key="6", mods="ALT", action=wezterm.action{SendString="\x1b6"}},
        {key="7", mods="ALT", action=wezterm.action{SendString="\x1b7"}},
        {key="8", mods="ALT", action=wezterm.action{SendString="\x1b8"}},
        {key="9", mods="ALT", action=wezterm.action{SendString="\x1b9"}},
        {key="0", mods="ALT", action=wezterm.action{SendString="\x1b0"}},

        {key="3", mods="SHIFT|ALT", action=wezterm.action{SendString="\x1b[3"}},
        
        {key="s", mods="SUPER", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
        {key="s", mods="SUPER|SHIFT", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
        {key="\'", mods="SUPER", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
        {key="\\", mods="SUPER", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
        {key="w", mods="SUPER", action=wezterm.action{
            CloseCurrentPane={confirm=true}
        }},
        {key="w", mods="SUPER|SHIFT", action=wezterm.action{
            CloseCurrentTab={confirm=true}
        }},
        {key="w", mods="SUPER|CTRL", action=wezterm.action{
            CloseCurrentPane={confirm=false}
        }},
        {key="x", mods="SUPER", action="ActivateCopyMode"},
        {key="x", mods="SUPER|SHIFT", action="QuickSelect"},
        --{key="x", mods="SUPER|SHIFT", action=wezterm.action{QuickSelectArgs={patterns={
          --"\\w{5,}"
       --},}}},
        {key="z", mods="SUPER", action="TogglePaneZoomState"},
        {key="Enter", mods="SUPER", action="TogglePaneZoomState"},
        
        {key="UpArrow", mods="SUPER", action=wezterm.action{ActivatePaneDirection="Up"}},
        {key="DownArrow", mods="SUPER", action=wezterm.action{ActivatePaneDirection="Down"}},
        {key="LeftArrow", mods="SUPER", action=wezterm.action{ActivatePaneDirection="Left"}},
        {key="RightArrow", mods="SUPER", action=wezterm.action{ActivatePaneDirection="Right"}},

        {key="PageUp", mods="SUPER", action=wezterm.action{ActivateTabRelative=1}},
        {key="PageDown", mods="SUPER", action=wezterm.action{ActivateTabRelative=-1}},
    },
    
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    color_scheme = "ayu",
    
    colors = {
        tab_bar = {
            -- The color of the strip that goes along the top of the window
            background = "#0b0022",
        },
    },
    enable_scroll_bar = true,
    
    inactive_pane_hsb = {
        saturation = 0.8,
        brightness = 0.7,
    },
    scrollback_lines = 10000,

    quick_select_patterns = {
        "[0-9a-f]{7,64}", -- hashes
        "[a-zA-Z0-9\\._-~/]{8,120}", -- paths
        "[\\w+]://[a-zA-Z0-9\\.-_/]+", -- urls
      },
      disable_default_quick_select_patterns = true,
    --unzoom_on_switch_pane = true,


--   tab_bar_style = {
--     new_tab = wezterm.format(format_tab(true, false, "+",3)),
--     new_tab_hover = wezterm.format(format_tab(false, true, "+",3)),
--   }
   skip_close_confirmation_for_processes_named = {"NONE"},
}
