module compiler

import entities
import dbpool

struct EntityWithMetadata{
pub mut:
	entity entities.Entity
	meta entities.EntityMetadata
}

pub fn compile (es entities.Entity[],db dbpool.DbPool) string[]{
	// mut metadata = db.get_metadata_by_id(ent.id);
	// mut all = map[string]int{}
	// for ent in es {
	//
	// }
	return string[]{}
}
