module dbsql

import geometry
import json
import math
import db.mysql

pub struct SqliteResultCode{
	code i64
	short string
	long string
}

struct SelectResult[K]{
	rows []K
	result_code SqliteResultCode
}
pub struct SqlitePool {
	pub mut :
	username string= 'admin'
	dbname string= 'geodb'
	password string= 'password'
}
pub fn (mut s SqlitePool) init_mysql()!{
	s.mysql_exec("
		CREATE TABLE IF NOT EXISTS BOXES(
			id VARCHAR(40),
			ent_type VARCHAR(40),
			json VARCHAR(4000),
			x0 DOUBLE,
			y0 DOUBLE,
			x1 DOUBLE,
			y1 DOUBLE,
			visible_size DOUBLE
		)
	") or {
		panic(err)
	}
}
pub fn (mut s SqlitePool) disconnect()!{
	println("closed database $s")
}
struct GenericRow{
	vals []string
}
fn (mut s SqlitePool) mysql_exec(q string) ! {
	println("mysql_query opened database")
	println("mysql_query opened $q")
	mut con:=mysql.Connection{
		username: s.username
		dbname: s.dbname
		password: s.password
	}
	con.connect() or {
		panic("could not connect to $s ")
	}
	con.query(q) or {
		panic(err)
	}
	con.close()
	println("mysql_query closed database")
}
fn (mut s SqlitePool) mysql_query(q string) !SelectResult[GenericRow] {
	println("mysql_query opened database")
	println("mysql_query opened $q")
	mut con:=mysql.Connection{
		username: s.username
		dbname: s.dbname
		password: s.password
	}
	con.connect() or {
		panic("could not connect to $s ")
	}
	rv:= con.query(q) or {
		panic(err)
	}
	mut rows:=[]GenericRow{}
	for r in rv.rows() {
		rows<<GenericRow{vals: r.vals.map(it.str())}
	}
	con.close()
	println("mysql_query closed database")
	return SelectResult[GenericRow]{
		rows,SqliteResultCode{
		code: 101
		short: 'dummy mysql result'
		long: 'dummy mysql result'
	}}
}
pub fn (mut s SqlitePool)  get_all_entities() []geometry.Entity {
	q:="
		SELECT id,ent_type,json,x0,y0,x1,y1,visible_size
		FROM BOXES"
	println("executing query $q")
	r:=s.mysql_query(q) or {
		panic(err)
	}
	return r.rows.map(fn(r GenericRow) geometry.Entity {
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
	r:=s.mysql_query(q) or {
		panic(err)
	}
	return r.rows.map(fn(r GenericRow) geometry.Entity {
		return geometry.Entity{
			id: r.vals[0]
			ent_type: r.vals[1]
			json: r.vals[2]
		}
	})
}
pub fn (mut s SqlitePool) store_entities(es []geometry.Entity) !{
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
		s.mysql_exec(h+q+'') or {
			panic(err)
		}
	}
}
