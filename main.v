module main

import vweb
import os
import dbsql
import geometry
import json
import net.http
import net.urllib

[heap]
struct App {
	vweb.Context
	middlewares map[string][]vweb.Middleware
	mut : dbpool dbsql.SqlitePool
}

pub fn (mut app App) destroy_handler(sig os.Signal){
	app.dbpool.disconnect() or {
		panic(err)
	}
	exit(0)
}
fn main() {
	app:=new_app()
	os.signal_opt(os.Signal.term,app.destroy_handler)!
	vweb.run_at(app, vweb.RunParams{
		port: 8081
	}) or { panic(err) }
}

fn new_app() App {
	mut dbpool:=dbsql.SqlitePool{}
	dbpool.init_mysql() or {
		panic(err)
	}
	mut app := App{
		dbpool: dbpool,
		middlewares: {
			// chaining is allowed, middleware will be evaluated in order
			// '/entities': [middleware_func, other_func]
			'/':         [intercept]
		}
	}
	// makes all static files available.
	app.mount_static_folder_at(os.resource_abs_path('.'), '/')
	return app
}

pub fn intercept(mut ctx vweb.Context) bool {

	println('intercepted ${ctx.req.method} ${ctx.req.url}')
	host:=ctx.req.header.get(http.CommonHeader.origin) or {
		"*"
	}
	ctx.header.add(
		http.CommonHeader.access_control_allow_origin,
		host
	)
	ctx.header.add(
		http.CommonHeader.access_control_allow_methods,
		"GET,POST,PUT,PATCH,DELETE,OPTIONS,TRACE"
	)
	ctx.header.add(
		http.CommonHeader.access_control_allow_headers,
		"Content-Type,Content-Length"
	)
	ctx.header.add(
		http.CommonHeader.keep_alive,
		"timeout=2, max=100"
	)

	if ctx.req.method==http.Method.options {
		return true
	} else {
		return true
	}
}

['/entities/all'; get;options]
pub fn (mut app App) get_all_entities() vweb.Result {
	if app.req.method == http.Method.options {
		return app.json[[]geometry.Entity](app.dbpool.get_all_entities())
	} else {
		return app.json[[]geometry.Entity](app.dbpool.get_all_entities())
	}
}
['/entities/:x0/:y0/:w/:h'; get;options]
pub fn (mut app App) get_entities(x0 string,y0 string,w string,h string) vweb.Result {
	bx:=geometry.Box{anchor:geometry.Point{x:x0.i64(),y:y0.i64()},size:geometry.Point{x:w.i64(),y:h.i64()}}
	if app.req.method == http.Method.options {
		println(bx)
		return app.json[[]geometry.Entity](app.dbpool.get_entities_inside_box(bx))
	} else {
		println(bx)
		return app.json[[]geometry.Entity](app.dbpool.get_entities_inside_box(bx))
	}
}
['/entities'; post;options]
fn (mut app App) store_entity() vweb.Result {
	if app.req.method == http.Method.options {
		return app.json[[]geometry.Entity](app.dbpool.get_all_entities())
	} else {
		println("received ${app.req.data}")
		mut decoded:=geometry.entity_from_json_array(app.req.data) or { [] }
		println("decoded $decoded")
		app.dbpool.store_entities(decoded) or {
			panic(err)
		}
		all_ents:=app.dbpool.get_all_entities()
		println("all_ents $all_ents")
		return app.json[[]geometry.Entity](all_ents)
	}
}

