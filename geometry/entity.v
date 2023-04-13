module geometry

import json


pub struct Entity{
pub mut:
	id string
	ent_type string
	json string
}
pub struct EntityMetadata{
	id string
	ent_type string=''
	technology string='javascript'
	text string=''
	tag string='code'
}

pub fn new_metadata(id string) EntityMetadata {
	return EntityMetadata{id:id}
}

pub fn from_json(j string) !Entity {
	mut e:=json.decode(Entity,j)or{
		panic(err)
	}
	e.json=j
	return e
}
pub fn entity_from_json_array(j string) ![]Entity {
	strings:=j.trim('][').replace('},{','}###---###{').split('###---###')
	mut ents:=json.decode([]Entity,j)or{
		panic(err)
	}
	for i,mut ent in ents {
		ent.json=strings[i]
	}
	return ents
}
pub fn (e Entity) get_box() !Box {
	return json.decode(Box,e.json)
}
