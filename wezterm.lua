local wezterm = require("wezterm")
local action = wezterm.action

-- 加载模块
local appearance = require("lua/appearance")

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

-- Tab 设置（简化，因为 Zellij 接管了 Tab）
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

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
-- 快捷键配置（Zellij 为主，WezTerm 做窗口管理）
-- ============================================

-- Leader key 改为 Ctrl+b（与 Zellij 的 tmux 模式一致，方便记忆）
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
    -- ========== 窗口管理（WezTerm 职责）==========
    -- 新建窗口
    { key = "n", mods = "CMD", action = action.SpawnWindow },
    
    -- 关闭窗口
    { key = "w", mods = "CMD", action = action.CloseCurrentTab({ confirm = true }) },
    
    -- 快速清屏（保留历史）
    { key = "k", mods = "CMD", action = action.ClearScrollback("ScrollbackAndViewport") },
    
    -- ========== 工作区管理（WezTerm 职责）==========
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
    -- 切换到上一个工作区
    { key = "[", mods = "LEADER", action = action.SwitchWorkspaceRelative(-1) },
    -- 切换到下一个工作区
    { key = "]", mods = "LEADER", action = action.SwitchWorkspaceRelative(1) },
    
    -- ========== 字体调整（WezTerm 职责）==========
    -- 增大字体
    { key = "=", mods = "CMD", action = action.IncreaseFontSize },
    -- 减小字体
    { key = "-", mods = "CMD", action = action.DecreaseFontSize },
    -- 重置字体
    { key = "0", mods = "CMD", action = action.ResetFontSize },
    
    -- ========== 复制/粘贴（WezTerm 职责）==========
    -- 复制模式（类似 vim）
    { key = "[", mods = "LEADER", action = action.ActivateCopyMode },
    -- 快速搜索
    { key = "/", mods = "LEADER", action = action.Search({ CaseInSensitiveString = "" }) },
    -- 快速选择并复制
    { key = "y", mods = "LEADER", action = action.QuickSelect },
    -- 快速选择 URL 打开
    { key = "u", mods = "LEADER", action = action.QuickSelectArgs({
        label = "打开 URL",
        patterns = { "https?://\\S+" },
        action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.open_with(url)
        end),
    }) },
    
    -- ========== 开发工具快捷启动（WezTerm 职责）==========
    -- 快速打开 lazygit（在新窗口，方便独立操作）
    { key = "g", mods = "LEADER", action = action.SpawnCommandInNewWindow({
        args = { "zellij", "attach", "lazygit", "--create", "--", "lazygit" },
    }) },
    -- 快速打开 btop（系统监控）
    { key = "t", mods = "LEADER", action = action.SpawnCommandInNewWindow({
        args = { "zellij", "attach", "btop", "--create", "--", "btop" },
    }) },
    -- 快速打开笔记/待办（可选，示例）
    { key = "n", mods = "LEADER", action = action.SpawnCommandInNewWindow({
        args = { "zellij", "attach", "notes", "--create", "--", "nvim", "~/notes.md" },
    }) },
    
    -- ========== Zellij 相关（WezTerm 辅助）==========
    -- 快速启动 Zellij（如果当前没有运行）
    { key = "z", mods = "LEADER", action = action.SendString("zellij attach main --create\n") },
    -- 启动 Zellij 并直接创建开发会话
    { key = "Z", mods = "LEADER|SHIFT", action = action.SendString("zellij attach dev --create\n") },
    
    -- ========== 配置管理（WezTerm 职责）==========
    -- 快速编辑 wezterm 配置
    { key = ",", mods = "LEADER", action = action.SpawnCommandInNewTab({
        args = { "nvim", wezterm.config_file },
    }) },
    -- 重载配置
    { key = "r", mods = "LEADER", action = action.ReloadConfiguration },
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
-- 智能状态栏（简化版）
-- ============================================

wezterm.on("update-status", function(window, pane)
    local cells = {}
    
    -- 当前工作区名称
    local workspace = window:active_workspace()
    if workspace and workspace ~= "default" then
        table.insert(cells, " workspace: " .. workspace .. " ")
    end
    
    -- 当前时间
    local time = wezterm.strftime("%H:%M")
    table.insert(cells, " " .. time .. " ")
    
    -- 组合状态栏
    local text = table.concat(cells, "│")
    
    -- 使用 Powerline 风格
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
    local color_scheme = window:effective_config().resolved_palette
    
    window:set_right_status(wezterm.format({
        { Background = { Color = "none" } },
        { Foreground = { Color = color_scheme.background } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = color_scheme.background } },
        { Foreground = { Color = color_scheme.foreground } },
        { Text = text },
    }))
end)

-- ============================================
-- Tab 标题格式化（简化）
-- ============================================

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = tab.active_pane.title
    
    -- 截断以适应宽度
    if #title > max_width - 4 then
        title = title:sub(1, max_width - 7) .. "..."
    end
    
    return {
        { Text = " " .. title .. " " },
    }
end)

-- ============================================
-- 窗口标题
-- ============================================

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
    local workspace = pane:window():active_workspace()
    local title = tab.active_pane.title
    
    if workspace and workspace ~= "default" then
        return "[" .. workspace .. "] " .. title
    end
    
    return title
end)

-- ============================================
-- 默认启动命令（自动启动 Zellij）
-- ============================================

-- 如果希望在打开 WezTerm 时自动启动 Zellij，取消下面这行的注释
-- config.default_prog = { "zellij", "attach", "main", "--create" }

-- 或者使用更智能的方式：如果已经在 Zellij 中，就不再启动
config.set_environment_variables = {
    -- 告诉 shell 当前在 WezTerm 中
    WEZTERM = "1",
}

-- ============================================
-- 返回配置
-- ============================================

return config
