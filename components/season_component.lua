local SeasonModComponent = class()
-- local log = radiant.log.create_logger('meu_log')

function SeasonModComponent:initialize()
   self._sv.timer = nil
end

function SeasonModComponent:activate()
	self._season_data = radiant.entities.get_entity_data(self._entity, 'season_mod:season_data')
	if not self._season_data then
		return
	end
	if not self._sv.timer then
		-- self._sv.timer = stonehearth.calendar:set_persistent_interval("SeasonModComponent update", "1m+1h", 
		self._sv.timer = stonehearth.calendar:set_persistent_interval("SeasonModComponent update", "1h+30d", 
			radiant.bind(self, '_on_check_season'), '1h')
	end
end

function SeasonModComponent:_on_check_season()
	if self._season_data.current_season ~= self:get_season() then
		self:update_entity_season()
	end
end

function SeasonModComponent:update_entity_season()
	local location = radiant.entities.get_world_grid_location(self._entity)
	if not location then
		return
	end

	if not self._season_data[self:get_season()] then
		return
	end

    local new_entity = radiant.entities.create_entity(self._season_data[self:get_season()])
    radiant.terrain.remove_entity(self._entity)
    radiant.terrain.place_entity_at_exact_location(new_entity, location, { owner = self._entity, force_iconic=false })
    new_entity:add_component('season_mod:season')

    --turn it to correct rotation
    local rotation = self._entity:get_component('mob'):get_facing() +180 % 360 --spin 180
    radiant.entities.turn_to(new_entity, rotation)
    radiant.entities.destroy_entity(self._entity)
end

function SeasonModComponent:get_season()
	local date = stonehearth.calendar:get_date_data()
	if radiant.util.get_config('change_season_every_month',false) then
		local date_modulo = date.month % 4
		if date_modulo == 1 then
			return "spring"
		elseif date_modulo == 2 then
			return "summer"
		elseif date_modulo == 3 then
			return "autumn"
		else
			return "winter"
		end
	else
		if date.month <= 3 then
			return "spring"
		elseif date.month <= 6 then
			return "summer"
		elseif date.month <= 9 then
			return "autumn"
		else
			return "winter"
		end
	end
end

function SeasonModComponent:destroy()
	if self._sv.timer then
		self._sv.timer:destroy()
		self._sv.timer = nil
	end
	self.__saved_variables:mark_changed()
end

return SeasonModComponent