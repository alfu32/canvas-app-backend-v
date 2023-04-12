module main

import vweb
import os
import dbsql
import geometry
import json

[heap]
struct App {
	vweb.Context
	mut : dbpool dbsql.SqlitePool
}

pub fn (mut app App) destroy_handler(sig os.Signal){
	println("received $sig")
	app.dbpool.disconnect() or {
		panic(err)
	}
	exit(0)
}
fn main() {
	app:=new_app()
	h:=os.signal_opt(os.Signal.term,app.destroy_handler)!
	println(h)
	vweb.run_at(app, vweb.RunParams{
		port: 8081
	}) or { panic(err) }
}

fn new_app() App {
	mut dbpool:=dbsql.SqlitePool{}
	dbpool.specifier=":memory:"//"/home/alfu64/Development/canvas-app/backend/geo.sqlite.db"
	dbpool.init() or {
		panic(err)
	}
	mut app := App{
		dbpool: dbpool
	}
	// makes all static files available.
	app.mount_static_folder_at(os.resource_abs_path('.'), '/')
	return app
}


['/entities/all'; get]
pub fn (mut app App) get_all_entities() vweb.Result {
	return app.json[[]geometry.Entity](app.dbpool.get_all_entities())
}
['/entities/:x0/:y0/:w/:h/:s'; get]
pub fn (mut app App) get_entities(x0 string,y0 string,w string,h string,s string) vweb.Result {
	bx:=geometry.Box{anchor:geometry.Point{x:x0.i64(),y:y0.i64()},size:geometry.Point{x:w.i64(),y:h.i64()}}
	println(bx)
	return app.json[[]geometry.Entity](app.dbpool.get_entities_inside_box(bx))
}
['/entities'; post]
fn (mut app App) store_entity() vweb.Result {
	rcode := app.dbpool.store_entities(json.decode([]geometry.Entity,app.req.data) or { [] }) or {
		println("could not properly store one of the decoded entities")
		panic(err)
	}
	return app.json[[]geometry.Entity](app.dbpool.get_all_entities())
}

