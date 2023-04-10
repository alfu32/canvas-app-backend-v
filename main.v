module main

import vweb
import os
import dbsql
import geometry
import json

struct App {
	vweb.Context
}

struct Object {
	title       string
	description string
}

fn main() {
	vweb.run_at(new_app(), vweb.RunParams{
		port: 8081
	}) or { panic(err) }
}

fn new_app() &App {
	mut app := &App{}
	// makes all static files available.
	app.mount_static_folder_at(os.resource_abs_path('.'), '/')
	return app
}


['/entities/:x0/:y0/:w/:h'; get]
pub fn (mut app App) get_entities(x0 string,y0 string,w string,h string) vweb.Result {
	bx:=geometry.Box{anchor:geometry.Point{x:x0.i64(),y:y0.i64()},size:geometry.Point{x:w.i64(),y:h.i64()}}
	println(bx)
	return app.json[[]geometry.Entity](dbsql.get_entities_inside(bx))
}
['/entities'; post]
fn (mut app App) store_entity() vweb.Result {
	dbsql.store_entities(json.decode([]geometry.Entity,app.req.data) or { [] })
	return app.json[[]geometry.Entity](dbsql.get_entities_inside(geometry.Box{anchor:geometry.Point{},size:geometry.Point{}}))
}

['/']
pub fn (mut app App) page_home() vweb.Result {
	// all this constants can be accessed by src/templates/page/home.html file.
	page_title := 'V is the new V'
	v_url := 'https://github.com/vlang/v'

	list_of_object := [
			Object{
			title: 'One good title'
			description: 'this is the first'
		},
			Object{
			title: 'Other good title'
			description: 'more one'
		},
	]
	// $vweb.html() in `<folder>_<name> vweb.Result ()` like this
	// render the `<name>.html` in folder `./templates/<folder>`
	return app.json[[]Object](list_of_object)
}
