local wezterm = require("wezterm")
local action = wezterm.action

-- 加载模块
local appearance = require("lua/appearance")
local dev_utils = require("lua/dev-utils")

-- 配置构建器
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- ============================================
-- 基础设置
-- ============================================

-- 字体设置
config.font = wezterm.font("Maple Mono NF CN")
config.font_size = 14.0
config.line_height = 1.2

-- 窗口设置
config.window_close_confirmation = "NeverPrompt"
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.enable_scroll_bar = true

-- 窗口内边距
config.window_padding = {
    left = 8,
    right = 8,
    top = 8,
    bottom = 8,
}

-- Tab 设置
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = false
config.tab_max_width = 32

-- 光标设置
config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 800

-- 滚动设置
config.scrollback_lines = 100000

-- 性能优化
config.max_fps = 120
config.animation_fps = 60

-- ============================================
-- 主题设置
-- ============================================

-- 根据系统主题自动切换
if appearance.is_dark() then
    config.colors = require("lua/cyberdream")
else
    config.colors = require("lua/cyberdream-light")
end

-- 窗口边框颜色
config.window_frame = {
    font = wezterm.font({ family = "Maple Mono NF CN", weight = "Bold" }),
    font_size = 12.0,
    active_titlebar_bg = "#16181a",
    inactive_titlebar_bg = "#1a1d1f",
}

-- ============================================
-- 快捷键配置（开发专用）
-- ============================================

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
    -- ========== 基础操作 ==========
    -- 快速清屏（保留历史）
    { key = "k", mods = "CMD", action = action.ClearScrollback("ScrollbackAndViewport") },
    
    -- 复制模式（类似 vim）
    { key = "[", mods = "LEADER", action = action.ActivateCopyMode },
    
    -- 快速搜索
    { key = "/", mods = "LEADER", action = action.Search({ CaseInSensitiveString = "" }) },
    
    -- ========== Pane 管理 ==========
    -- 垂直分屏
    { key = "v", mods = "LEADER", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    -- 水平分屏
    { key = "s", mods = "LEADER", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    -- 关闭 pane
    { key = "x", mods = "LEADER", action = action.CloseCurrentPane({ confirm = true }) },
    -- 最大化/恢复 pane
    { key = "z", mods = "LEADER", action = action.TogglePaneZoomState },
    
    -- Pane 导航（使用 vim 风格）
    { key = "h", mods = "LEADER", action = action.ActivatePaneDirection("Left") },
    { key = "j", mods = "LEADER", action = action.ActivatePaneDirection("Down") },
    { key = "k", mods = "LEADER", action = action.ActivatePaneDirection("Up") },
    { key = "l", mods = "LEADER", action = action.ActivatePaneDirection("Right") },
    
    -- Pane 调整大小
    { key = "H", mods = "LEADER|SHIFT", action = action.AdjustPaneSize({ "Left", 5 }) },
    { key = "J", mods = "LEADER|SHIFT", action = action.AdjustPaneSize({ "Down", 5 }) },
    { key = "K", mods = "LEADER|SHIFT", action = action.AdjustPaneSize({ "Up", 5 }) },
    { key = "L", mods = "LEADER|SHIFT", action = action.AdjustPaneSize({ "Right", 5 }) },
    
    -- 旋转 panes
    { key = "r", mods = "LEADER", action = action.RotatePanes("Clockwise") },
    
    -- ========== Tab 管理 ==========
    -- 新建 Tab
    { key = "c", mods = "LEADER", action = action.SpawnTab("CurrentPaneDomain") },
    -- 关闭 Tab
    { key = "w", mods = "LEADER", action = action.CloseCurrentTab({ confirm = true }) },
    -- 切换 Tab
    { key = "1", mods = "LEADER", action = action.ActivateTab(0) },
    { key = "2", mods = "LEADER", action = action.ActivateTab(1) },
    { key = "3", mods = "LEADER", action = action.ActivateTab(2) },
    { key = "4", mods = "LEADER", action = action.ActivateTab(3) },
    { key = "5", mods = "LEADER", action = action.ActivateTab(4) },
    { key = "6", mods = "LEADER", action = action.ActivateTab(5) },
    { key = "7", mods = "LEADER", action = action.ActivateTab(6) },
    { key = "8", mods = "LEADER", action = action.ActivateTab(7) },
    { key = "9", mods = "LEADER", action = action.ActivateTab(8) },
    { key = "0", mods = "LEADER", action = action.ActivateTab(-1) },
    -- 上一个/下一个 Tab
    { key = "n", mods = "LEADER", action = action.ActivateTabRelative(1) },
    { key = "p", mods = "LEADER", action = action.ActivateTabRelative(-1) },
    -- 移动 Tab
    { key = ">", mods = "LEADER|SHIFT", action = action.MoveTabRelative(1) },
    { key = "<", mods = "LEADER|SHIFT", action = action.MoveTabRelative(-1) },
    
    -- ========== 工作区/项目切换 ==========
    -- 快速选择工作区
    { key = "f", mods = "LEADER", action = action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
    -- 新建工作区
    { key = "F", mods = "LEADER|SHIFT", action = action.PromptInputLine({
        description = wezterm.format({
            { Attribute = { Intensity = "Bold" } },
            { Foreground = { AnsiColor = "Fuchsia" } },
            { Text = "新建工作区名称:" },
        }),
        action = wezterm.action_callback(function(window, pane, line)
            if line then
                window:perform_action(action.SwitchToWorkspace({ name = line }), pane)
            end
        end),
    }) },
    
    -- ========== 开发工具快捷启动 ==========
    -- 快速打开 lazygit
    { key = "g", mods = "LEADER", action = action.SpawnCommandInNewTab({
        args = { "lazygit" },
        cwd = dev_utils.get_current_cwd(),
    }) },
    -- 快速打开 btop
    { key = "t", mods = "LEADER", action = action.SpawnCommandInNewTab({
        args = { "btop" },
    }) },
    -- 快速打开 nvim（在当前目录）
    { key = "e", mods = "LEADER", action = action.SpawnCommandInNewTab({
        args = { "nvim", "." },
        cwd = dev_utils.get_current_cwd(),
    }) },
    
    -- ========== 布局预设 ==========
    -- 开发三栏布局（编辑器 | 终端 | 辅助）
    { key = "d", mods = "LEADER", action = wezterm.action_callback(function(window, pane)
        dev_utils.apply_dev_layout(window, pane)
    end) },
    -- 双栏布局（左右）
    { key = "b", mods = "LEADER", action = wezterm.action_callback(function(window, pane)
        dev_utils.apply_split_layout(window, pane)
    end) },
    
    -- ========== 快速编辑配置 ==========
    -- 快速编辑 wezterm 配置
    { key = ",", mods = "LEADER", action = action.SpawnCommandInNewTab({
        args = { "nvim", wezterm.config_file },
    }) },
    -- 重载配置
    { key = "R", mods = "LEADER|SHIFT", action = action.ReloadConfiguration },
    
    -- ========== 其他实用功能 ==========
    -- 快速选择 URL 打开
    { key = "u", mods = "LEADER", action = action.QuickSelectArgs({
        label = "打开 URL",
        patterns = { "https?://\\S+" },
        action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.open_with(url)
        end),
    }) },
    -- 快速选择并复制
    { key = "y", mods = "LEADER", action = action.QuickSelect },
}

-- ============================================
-- 鼠标绑定
-- ============================================

config.mouse_bindings = {
    -- Ctrl+点击 打开链接
    {
        event = { Up = { streak = 1, button = "Left" } },
        mods = "CTRL",
        action = action.OpenLinkAtMouseCursor,
    },
    -- 右键粘贴
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "NONE",
        action = action.PasteFrom("Clipboard"),
    },
}

-- ============================================
-- 智能状态栏
-- ============================================

wezterm.on("update-status", function(window, pane)
    local cells = {}
    
    -- 获取当前工作目录
    local cwd = pane:get_current_working_dir()
    if cwd then
        local cwd_str = tostring(cwd):gsub("file://", "")
        -- 只显示最后两级目录
        local short_cwd = cwd_str:match("([^/]+/[^/]+)$") or cwd_str:match("([^/]+)$") or cwd_str
        table.insert(cells, "📁 " .. short_cwd)
    end
    
    -- 获取 Git 分支（使用 dev_utils 模块）
    local git_branch = dev_utils.get_git_branch(pane)
    if git_branch then
        table.insert(cells, "  " .. git_branch)
    end
    
    -- 当前时间
    local time = wezterm.strftime("%H:%M")
    table.insert(cells, " 🕐 " .. time)
    
    -- 用户名和主机名
    table.insert(cells, " 💻 " .. wezterm.hostname())
    
    -- 组合状态栏
    local text = table.concat(cells, " │ ")
    
    -- 使用 Powerline 风格
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
    local color_scheme = window:effective_config().resolved_palette
    
    window:set_right_status(wezterm.format({
        { Background = { Color = "none" } },
        { Foreground = { Color = color_scheme.background } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = color_scheme.background } },
        { Foreground = { Color = color_scheme.foreground } },
        { Text = " " .. text .. "  " },
    }))
end)

-- ============================================
-- Tab 标题格式化
-- ============================================

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = tab.active_pane.title
    local cwd = tab.active_pane.current_working_dir
    
    -- 如果是 home 目录，显示 ~
    if cwd then
        local cwd_str = tostring(cwd):gsub("file://", "")
        cwd_str = cwd_str:gsub(os.getenv("HOME") or "/Users/" .. os.getenv("USER"), "~")
        
        -- 根据进程名设置图标
        local icon = ""
        if title:find("nvim") or title:find("vim") then
            icon = " "
        elseif title:find("lazygit") then
            icon = ""
        elseif title:find("node") or title:find("npm") or title:find("pnpm") then
            icon = " "
        elseif title:find("python") or title:find("pip") or title:find("uv") then
            icon = " "
        elseif title:find("btop") or title:find("htop") or title:find("top") then
            icon = ""
        elseif title:find("ssh") then
            icon = "󰣀 "
        else
            icon = ""
        end
        
        -- 显示：图标 + 进程名 | 目录
        local display = icon .. title
        if #cwd_str > 15 then
            cwd_str = "..." .. cwd_str:sub(-12)
        end
        display = display .. "  " .. cwd_str
        
        -- 截断以适应宽度
        if #display > max_width - 4 then
            display = display:sub(1, max_width - 7) .. "..."
        end
        
        return {
            { Text = " " .. display .. " " },
        }
    end
    
    return {
        { Text = " " .. title .. " " },
    }
end)

-- ============================================
-- 窗口标题格式化
-- ============================================

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local zoomed = ""
    if tab.active_pane.is_zoomed then
        zoomed = "[Z] "
    end
    
    local index = ""
    if #tabs > 1 then
        index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
    end
    
    return zoomed .. index .. tab.active_pane.title
end)

-- ============================================
-- 启动时恢复工作区（可选）
-- ============================================

-- 自动恢复上次的 tabs（需要启用 session saving）
config.switch_to_last_active_tab_when_closing_tab = true

-- 退出前确认
config.window_close_confirmation = "AlwaysPrompt"

-- ============================================
-- 返回配置
-- ============================================

return config
