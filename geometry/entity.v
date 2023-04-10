module geometry

import json


pub struct Entity{
pub mut:
	id string
	ent_type string
	json string
}

pub fn (e Entity) get_box() !Box {
	return json.decode(Box,e.json)
}
