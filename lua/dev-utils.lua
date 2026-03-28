local wezterm = require("wezterm")
local module = {}

-- ============================================
-- 获取当前 pane 的工作目录
-- ============================================
function module.get_current_cwd()
    local pane = wezterm.mux.get_active_workspace()
    -- 返回主目录作为默认值
    return os.getenv("HOME") or "/Users/" .. os.getenv("USER")
end

-- ============================================
-- 获取指定 pane 的 Git 分支
-- ============================================
function module.get_git_branch(pane)
    local cwd = pane:get_current_working_dir()
    if not cwd then
        return nil
    end
    
    -- 尝试从环境变量获取（如果 shell 设置了）
    local vars = pane:get_user_vars()
    if vars and vars.git_branch then
        return vars.git_branch
    end
    
    -- 简单的分支名检测（通过执行 git 命令）
    -- 注意：这可能会稍微慢一点，建议通过 shell 集成设置环境变量
    local success, stdout, stderr = wezterm.run_child_process({
        "git",
        "-C",
        tostring(cwd):gsub("file://", ""),
        "branch",
        "--show-current",
    })
    
    if success then
        local branch = stdout:gsub("%s+$", "")
        if branch ~= "" then
            return branch
        end
    end
    
    return nil
end

-- ============================================
-- 检测项目类型并返回图标
-- ============================================
function module.detect_project_type(cwd)
    if not cwd then
        return ""
    end
    
    local cwd_str = tostring(cwd):gsub("file://", "")
    
    -- 检测 package.json（Node.js 项目）
    local f = io.open(cwd_str .. "/package.json", "r")
    if f then
        f:close()
        return " Node"
    end
    
    -- 检测 Cargo.toml（Rust 项目）
    f = io.open(cwd_str .. "/Cargo.toml", "r")
    if f then
        f:close()
        return " Rust"
    end
    
    -- 检测 go.mod（Go 项目）
    f = io.open(cwd_str .. "/go.mod", "r")
    if f then
        f:close()
        return " Go"
    end
    
    -- 检测 pyproject.toml 或 requirements.txt（Python 项目）
    f = io.open(cwd_str .. "/pyproject.toml", "r")
    if not f then
        f = io.open(cwd_str .. "/requirements.txt", "r")
    end
    if f then
        f:close()
        return " Python"
    end
    
    -- 检测 .git（Git 仓库）
    f = io.open(cwd_str .. "/.git/config", "r")
    if f then
        f:close()
        return " Git"
    end
    
    return ""
end

-- ============================================
-- 应用开发三栏布局
-- 布局：[编辑器] | [终端] | [辅助/日志]
-- ============================================
function module.apply_dev_layout(window, pane)
    local tab = window:mux_window()
    local panes = tab:panes_with_info()
    
    -- 如果已经有多个 pane，先关闭它们
    if #panes > 1 then
        for i = #panes, 2, -1 do
            panes[i].pane:activate()
            window:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), pane)
        end
        panes[1].pane:activate()
    end
    
    -- 获取第一个 pane
    local first_pane = tab:active_pane()
    
    -- 右边分屏（终端）
    local second_pane = first_pane:split({
        direction = "Right",
        size = { Percent = 40 },
    })
    
    -- 再垂直分屏（辅助窗口）
    local third_pane = second_pane:split({
        direction = "Bottom",
        size = { Percent = 50 },
    })
    
    -- 在第一个 pane 启动 nvim（如果是项目目录）
    -- first_pane:send_text("nvim .\\n")
    
    -- 激活第一个 pane
    first_pane:activate()
end

-- ============================================
-- 应用双栏布局
-- 布局：[代码] | [终端/预览]
-- ============================================
function module.apply_split_layout(window, pane)
    local tab = window:mux_window()
    local panes = tab:panes_with_info()
    
    -- 如果已经有多个 pane，先关闭它们
    if #panes > 1 then
        for i = #panes, 2, -1 do
            panes[i].pane:activate()
            window:perform_action(wezterm.action.CloseCurrentPane({ confirm = false }), pane)
        end
        panes[1].pane:activate()
    end
    
    -- 获取第一个 pane
    local first_pane = tab:active_pane()
    
    -- 右边分屏
    first_pane:split({
        direction = "Right",
        size = { Percent = 50 },
    })
    
    -- 激活第一个 pane
    first_pane:activate()
end

-- ============================================
-- 获取项目根目录（向上查找 .git）
-- ============================================
function module.find_project_root(cwd)
    if not cwd then
        return nil
    end
    
    local cwd_str = tostring(cwd):gsub("file://", "")
    local current = cwd_str
    
    -- 向上查找 5 层
    for _ = 1, 5 do
        local f = io.open(current .. "/.git/config", "r")
        if f then
            f:close()
            return current
        end
        
        -- 向上移动一级
        local parent = current:match("^(.+)/[^/]+$")
        if not parent or parent == current then
            break
        end
        current = parent
    end
    
    return cwd_str
end

-- ============================================
-- 工作区快速切换（常用项目）
-- ============================================
function module.get_quick_workspaces()
    local home = os.getenv("HOME") or "/Users/" .. os.getenv("USER")
    
    -- 这里可以定义常用项目路径
    local workspaces = {
        { id = home, label = "🏠 Home" },
        { id = home .. "/.config", label = "⚙️  Config" },
    }
    
    -- 添加代码目录（如果存在）
    local code_dirs = {
        home .. "/code",
        home .. "/projects",
        home .. "/work",
        home .. "/dev",
        home .. "/Developer",
    }
    
    for _, dir in ipairs(code_dirs) do
        local f = io.open(dir, "r")
        if f then
            f:close()
            table.insert(workspaces, { id = dir, label = "💻 " .. dir:match("([^/]+)$") })
        end
    end
    
    return workspaces
end

-- ============================================
-- 格式化文件大小
-- ============================================
function module.format_bytes(bytes)
    local units = { "B", "KB", "MB", "GB", "TB" }
    local unit_index = 1
    
    while bytes >= 1024 and unit_index < #units do
        bytes = bytes / 1024
        unit_index = unit_index + 1
    end
    
    return string.format("%.1f %s", bytes, units[unit_index])
end

return module
