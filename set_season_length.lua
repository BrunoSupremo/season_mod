season_mod = {}

function season_mod:_on_required_loaded()
	local config = radiant.util.get_config('change_season_every_month')
	if not config then
		radiant.util.set_config("change_season_every_month", false)
	end
end

radiant.events.listen_once(radiant, 'radiant:required_loaded', season_mod, season_mod._on_required_loaded)

return season_mod
