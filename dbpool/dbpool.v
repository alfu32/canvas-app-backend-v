module dbpool

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
pub struct DbPool {
	pub mut :
	username string= 'admin'
	dbname string= 'geodb'
	password string= 'password'
}
pub fn (mut s DbPool) init_mysql()!{
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
	".trim_indent()) or {
		panic(err)
	}
	s.mysql_exec("
		CREATE TABLE IF NOT EXISTS METADATA(
			id VARCHAR(40),
			json VARCHAR(4000)
		)
	".trim_indent()) or {
		panic(err)
	}
	s.mysql_exec("
		create or replace function box_contains_point(
			px NUMERIC(15),py NUMERIC(15),bx0 NUMERIC(15),
			by0 NUMERIC(15),bx1 NUMERIC(15),by1 NUMERIC(15)
		) RETURNS BOOLEAN
		BEGIN
			return px between bx0 and bx1 and py between by0 and by1;
		END;
	".trim_indent()) or {
		panic(err)
	}
	s.mysql_exec("
		create or replace function box_intersects_box(
			ax0 NUMERIC(15),ay0 NUMERIC(15),ax1 NUMERIC(15),ay1 NUMERIC(15),
			bx0 NUMERIC(15),by0 NUMERIC(15),bx1 NUMERIC(15),by1 NUMERIC(15)
		)
			RETURNS BOOLEAN
		BEGIN
			return box_contains_point(ax0,ay0, bx0,by0,bx1,by1)
				OR box_contains_point(ax0,ay1, bx0,by0,bx1,by1)
				OR box_contains_point(ax1,ay1, bx0,by0,bx1,by1)
				OR box_contains_point(ax1,ay0, bx0,by0,bx1,by1)
				OR box_contains_point(bx0,by0, ax0,ay0,ax1,ay1)
				OR box_contains_point(bx0,by1, ax0,ay0,ax1,ay1)
				OR box_contains_point(bx1,by1, ax0,ay0,ax1,ay1)
				OR box_contains_point(bx1,by0, ax0,ay0,ax1,ay1);
		END;
	".trim_indent()) or {
		panic(err)
	}
}
pub fn (mut s DbPool) disconnect()!{
	println("closed database $s")
}
struct GenericRow{
	vals []string
}
fn (mut s DbPool) mysql_exec(q string) ! {
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
}
fn (mut s DbPool) mysql_query(q string) !SelectResult[GenericRow] {
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
	return SelectResult[GenericRow]{
		rows,SqliteResultCode{
		code: 101
		short: 'dummy mysql result'
		long: 'dummy mysql result'
	}}
}
pub fn (mut s DbPool)  get_all_entities() []geometry.Entity {
	q:="
		SELECT id,ent_type,json,x0,y0,x1,y1,visible_size
		FROM BOXES
	".trim_indent()
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
pub fn (mut s DbPool)  get_entities_inside_box(box geometry.Box) []geometry.Entity {
	x0:=box.anchor.x
	x1:=box.corner().x
	y0:=box.anchor.y
	y1:=box.corner().y
	q:="
		SELECT id,ent_type,json,x0,y0,x1,y1,visible_size
		FROM BOXES
		WHERE box_intersects_box(x0,y0,x1,y1,$x0,$y0,$x1,$y1)
	".trim_indent()
	println(q)
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
pub fn (mut s DbPool) store_entities(es []geometry.Entity) !{
	h:=""
	for ent in es{
		bx:=json.decode(geometry.Box,ent.json) or {
			panic(err)
		}
		x0:=bx.anchor.x
		y0:=bx.anchor.y
		x1:=bx.corner().x
		y1:=bx.corner().y
		vs:=math.max[f64](x1-x0,y1-y0)
		q:="
			INSERT INTO BOXES(id,ent_type,json,x0,y0,x1,y1,visible_size)
			VALUES ('${ent.id}','${ent.ent_type}','${ent.json}',$x0,$y0,$x1,$y1,$vs)
		".trim_indent()
		s.mysql_exec(h+q+'') or {
			panic(err)
		}
	}
}
pub fn (mut s DbPool)  get_metadatas_by_ids(id_list []string) []geometry.Entity {
	placeholder_id:='########-####-####-####-############'
	default_metadata:=json.encode(geometry.new_metadata(placeholder_id))
	ids:=id_list.map("'${it}'").join(',')
	q:="
		SELECT
		    bx.id,
		    bx.ent_type,
		    NVL(mdt.json,REPLACE('$default_metadata','$placeholder_id',bx.id)) as json
		FROM BOXES bx
		LEFT JOIN METADATA mdt on bx.id=mdt.id
		WHERE bx.id in ($ids)
	".trim_indent()
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

pub fn (mut s DbPool) store_metadatas(id string,data string) ! {
	mut q:="
		INSERT INTO METADATA(id,json) VALUES ('$id','$data') ON DUPLICATE KEY UPDATE SET json=json
	".trim_indent()
	s.mysql_exec(q) or {
		panic(err)
	}
}
