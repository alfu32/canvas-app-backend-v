module dbsql

import geometry
import db.sqlite
import json
import math

pub const sqlite_error_codes=$embed_file("sqlite-codes.json",.zlib)
pub struct SqliteResultCode{
	code i64
	short string
	long string
}
pub fn find_result_code_by_id(id i64) SqliteResultCode{
	all:=json.decode([]SqliteResultCode,sqlite_error_codes.to_string()) or {
		panic(err)
	}
	// println(all)
	fnd:= all.filter(fn [id](a SqliteResultCode)bool{return a.code == id})
	if fnd.len == 0 {
		return SqliteResultCode{code:id,short:"undefined",long:"undefined"}
	} else {
		return fnd[0]
	}
}

pub struct SqlitePool {
	pub mut :
		specifier string
		flags []sqlite.OpenModeFlag= [sqlite.OpenModeFlag.readwrite,sqlite.OpenModeFlag.nomutex,]
		sync_mode sqlite.SyncMode =sqlite.SyncMode.off
		journal_mode sqlite.JournalMode = sqlite.JournalMode.off
}
struct SelectResult{
	rows []sqlite.Row
	result_code SqliteResultCode
}
pub fn (mut s SqlitePool) init()!{
	s.with_connection(fn ( db sqlite.DB ) !SelectResult {
		r,i := db.exec("
			CREATE TABLE IF NOT EXISTS BOXES(
				id VARCHAR(40) PRIMARY KEY NOT NULL,
				ent_type VARCHAR(40),
				json VARCHAR(4000),
				x0 DOUBLE,
				y0 DOUBLE,
				x1 DOUBLE,
				y1 DOUBLE,
				visible_size DOUBLE
			)
		")
		return SelectResult{r,find_result_code_by_id(i)}
	}) or {
		panic(err)
	}
}
pub fn (mut s SqlitePool) with_connection(execute_statements fn(db sqlite.DB)!SelectResult)!SelectResult{
	println("opened database")
	mut db:=sqlite.connect(
		s.specifier) or {
		panic("could not connect to ${s.specifier} ")
	}
	if db.is_open {
		println("the database ${s.specifier} is open")
	} else {
		println("the database ${s.specifier} is NOT open")
	}
	db.synchronization_mode(s.sync_mode)
	db.journal_mode(s.journal_mode)
	rv:= execute_statements(db) or {
		panic(err)
	}
	db.close() or {
		panic(err)
	}
	println("closed database")
	return rv
}
pub fn (mut s SqlitePool) disconnect()!{
	println("closed database")
}
fn (mut s SqlitePool) query(q string) !SelectResult {
	println("opened database")
	mut db:=sqlite.connect(
		s.specifier) or {
		panic("could not connect to ${s.specifier} ")
	}
	if db.is_open {
		println("the database ${s.specifier} is open")
	} else {
		println("the database ${s.specifier} is NOT open")
	}
	db.synchronization_mode(s.sync_mode)
	db.journal_mode(s.journal_mode)
	mut r,mut i:= db.exec(q)
	defer {
		r,i=db.exec("COMMIT")

		println("$r $i")
		db.close() or {
			panic(err)
		}
		println("closed database")
	}
	return SelectResult{r,find_result_code_by_id(i)}
}
pub fn (mut s SqlitePool)  get_all_entities() []geometry.Entity {
	q:="
		SELECT id,ent_type,json,x0,y0,x1,y1,visible_size
		FROM BOXES"
	println("executing query $q")
	r:=s.query(q) or {
		panic(err)
	}
	return r.rows.map(fn(r sqlite.Row) geometry.Entity {
		return geometry.Entity{
			id: r.vals[0]
			ent_type: r.vals[1]
			json: r.vals[2]
		}
	})
}
pub fn (mut s SqlitePool)  get_entities_inside_box(box geometry.Box) []geometry.Entity {
	x0:=box.anchor.x
	x1:=box.corner().x
	y0:=box.anchor.y
	y1:=box.corner().y
	q:="
		SELECT id,ent_type,json,x0,y0,x1,y1,visible_size
		FROM BOXES
		WHERE (x0 BETWEEN $x0 and $x1 and x1 BETWEEN $x0 and $x1
		and y0 BETWEEN $y0 and $y1 and y1 BETWEEN $y0 and $y1 )
		or ($x0 BETWEEN x0 and x1 and $x1 BETWEEN x0 and x1
		and $y0 BETWEEN y0 and y1 and $y1 BETWEEN y0 and y1 )"
	println("executing query $q")
	r:=s.query(q) or {
		panic(err)
	}
	return r.rows.map(fn(r sqlite.Row) geometry.Entity {
		return geometry.Entity{
			id: r.vals[0]
			ent_type: r.vals[1]
			json: r.vals[2]
		}
	})
}
pub fn (mut s SqlitePool) store_entities(es []geometry.Entity) ![]SelectResult {
	mut rcodes:=[]SelectResult{}
	h:="INSERT INTO BOXES(id,ent_type,json,x0,y0,x1,y1,visible_size) VALUES "
	for ent in es{
		bx:=json.decode(geometry.Box,ent.json) or {
			panic(err)
		}
		x0:=bx.anchor.x
		y0:=bx.anchor.y
		x1:=bx.corner().x
		y1:=bx.corner().y
		vs:=math.max[f64](x1-x0,y1-y0)
		q:="('${ent.id}','${ent.ent_type}','${ent.json}',$x0,$y0,$x1,$y1,$vs)"
		println(h+q )
		rcode:=s.query(h+q+'') or {
			panic(err)
		}
		rcodes<<rcode
	}
	return rcodes
}
