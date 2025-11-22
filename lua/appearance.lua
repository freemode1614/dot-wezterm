local wezterm = require("wezterm")

local module = {}

function module.is_dark()
	if wezterm.gui then
		wezterm.gui.get_appearance():find("Dark")
	end
end

return module
