module dbsql

import geometry

pub fn get_entities_inside(box geometry.Box) []geometry.Entity {
	return [
		geometry.Entity {
			id:'1'
			ent_type:'generic'
			json:'{"id":1,"anchor":{"x":0,"y":0},"size":{"x":10,"y":10}}'
		}
		geometry.Entity {
			id:'2'
			ent_type:'generic'
			json:'{"id":2,"anchor":{"x":4,"y":4},"size":{"x":10,"y":10}}'
		}
		geometry.Entity {
			id:'2'
			ent_type:'generic'
			json:'{"id":2,"anchor":{"x":6,"y":6},"size":{"x":10,"y":10}}'
		}
	]
}

pub fn store_entities(es []geometry.Entity) {

}
