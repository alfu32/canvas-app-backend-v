module geometry

import json
import strings


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
	mut ents:=json.decode([]Entity,j)or{
		panic(err)
	}
	if ents.len == 0 {
		return ents
	} else if ents.len == 1 {
		ents[0].json=j[1..j.len-1]
		return ents
	}else {
		jstring_array:=j[1..j.len-1].replace('},{"id":"','}###----###{').split('###----###')
		println(jstring_array)
		for i,mut ent in ents {
			ent.json='{"id":"${jstring_array[i]}}'
		}
		ents[0].json='${jstring_array[0]}}'
		ents.last().json='{"id":"${jstring_array.last()}}'
		return ents
	}
}
pub fn (e Entity) get_box() !Box {
	return json.decode(Box,e.json)
}
