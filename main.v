module main

import vweb
import os
import dbpool
import alfu32.geometry
import net.http
import entities
import users
import json
import sync.pool

struct AppConfig {
pub mut:
	pool dbpool.DbPool
	kinde users.KindeApi
}
[heap]
struct App {
	vweb.Context
	mut :
	middlewares map[string][]vweb.Middleware
	pool dbpool.DbPool
	kinde users.KindeApi
}

pub fn (mut app App) to_app_cfg() AppConfig{
	return AppConfig{
		pool: app.pool
		kinde: app.kinde
	}
}
pub fn (mut app App) destroy_handler(sig os.Signal){
	println("shutting down ...")
	app.pool.disconnect() or {
		panic(err)
	}
	mut appcfg:=app.to_app_cfg()
	os.write_file('./vapp-settings.json',json.encode_pretty(appcfg)) or {
		println("could not save configuration")
		panic(err)
	}
	println("done!")
	exit(0)
}
fn main() {
	app:=new_app()
	os.signal_opt(os.Signal.term,app.destroy_handler)!
	os.signal_opt(os.Signal.int,app.destroy_handler)!
	vweb.run_at(app, vweb.RunParams{
		port: 8081
	}) or { panic(err) }
}

fn new_app() App {
	config:=os.read_file('./vapp-settings.json') or {
		panic(err)
	}
	mut app_cfg:=json.decode(AppConfig,config.str()) or {
		panic(err)
	}
	mut app := App{
		pool: dbpool.connect(
			app_cfg.pool.username,
			app_cfg.pool.dbname,
			app_cfg.pool.password,
		) or { panic(err) },
		kinde: users.KindeApi{
			domain: app_cfg.kinde.domain
			audience: app_cfg.kinde.audience
			client_id: app_cfg.kinde.client_id
			secret: app_cfg.kinde.secret
			proxy_authorization: app_cfg.kinde.proxy_authorization
			token: users.Token{
				access_token: app_cfg.kinde.token.access_token
				expires_in: app_cfg.kinde.token.expires_in
				scope: app_cfg.kinde.token.scope
				token_type: app_cfg.kinde.token.token_type
			}
		}
	}
	app.pool.init_mysql() or {
		panic(err)
	}
	if app.kinde.token.access_token == '' {
		println("no token found ... fetching new token")
		app.kinde.get_client_credentials() or {
			panic(err)
		}
	}
	println(app.kinde.token)
	app.middlewares= {
		// chaining is allowed, middleware will be evaluated in order
		// '/entities': [middleware_func, other_func]
		'/':         [logger,intercept]
	}
	// makes all static files available.
	app.mount_static_folder_at(os.resource_abs_path('.'), '/')
	return app
}

pub fn logger(mut ctx vweb.Context) bool {
	/// println('logger ${ctx.req.method} ${ctx.req.url}')
	return true
}
pub fn intercept(mut ctx vweb.Context) bool {

	/// println('intercepted ${ctx.req.method} ${ctx.req.url}')
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
		"Content-Type,Content-Length,Authentication"
	)
	ctx.header.add(
		http.CommonHeader.keep_alive,
		"timeout=2, max=100"
	)
	if ctx.req.method==http.Method.options {
		ctx.add_header(
			"coucou",
			"options"
		)
	}
	//// if ctx.req.method==http.Method.options {
	//// 	return true
	//// } else {
	//// 	return true
	//// }
	return true
}
['/'; options]
pub fn (mut app App) on_options() vweb.Result{
	return app.text("[]")
}
['/entities/all'; get;options]
pub fn (mut app App) get_all_entities() vweb.Result {
	if app.req.method == http.Method.options {
		/// return app.json[[]entities.Entity](app.pool.get_all_entities())
		return app.text("[]")
	}
	return app.json[[]entities.Entity](app.pool.get_all_entities())
}
['/entities/:x0/:y0/:w/:h'; get;options]
pub fn (mut app App) get_entities(x0 string,y0 string,w string,h string) vweb.Result {
	bx:=geometry.Box{anchor:geometry.Point{x:x0.i64(),y:y0.i64()},size:geometry.Point{x:w.i64(),y:h.i64()}}
	if app.req.method == http.Method.options {
		return app.text("[]")
	}
	/// println(bx)
	return app.json[[]entities.Entity](app.pool.get_entities_inside_box(bx))
}
['/entities'; post;options]
fn (mut app App) store_entity() vweb.Result {
	if app.req.method == http.Method.options {
		return app.text("[]")
	}
	/// println("received ${app.req.data}")
	mut decoded:=entities.entity_from_json_array(app.req.data) or { [] }
	/// println("decoded $decoded")
	app.pool.store_entities(decoded) or {
		panic(err)
	}
	all_ents:=app.pool.get_all_entities()
	/// println("all_ents $all_ents")
	return app.json[[]entities.Entity](all_ents)
}
['/entities/:ids'; delete;options]
fn (mut app App) delete_entity(ids string) vweb.Result {
	if app.req.method == http.Method.options {
		return app.text("[]")
	}
	id_list:=ids.split(",")
	/// println(id_list)
	return app.json[[]string](app.pool.delete_entities(id_list))
}
['/config/:ids'; get;options]
pub fn (mut app App) get_config(ids string) vweb.Result {
	if app.req.method == http.Method.options {
		return app.text("[]")
	}
	id_list:=ids.split(",")
	/// println(id_list)
	return app.json[[]entities.Entity](app.pool.get_metadatas_by_ids(id_list))
}

['/config/:ids'; post;options]
pub fn (mut app App) store_config(id string) vweb.Result {
	if app.req.method == http.Method.options {
		return app.text("[]")
	}
	/// println(id)
	app.pool.store_metadatas(id,app.req.data) or {
		panic(err)
	}
	return app.text(app.req.data)
}
['/technologies/:lang'; get;options]
pub fn (mut app App) get_technologies_for_language(lang string) vweb.Result {

	if app.req.method == http.Method.options {
		return app.text("[]")
	}
	/// println(lang)
	return app.json[[]entities.TechnoLang](app.pool.get_technologies_for_language(lang))
}
['/languages'; get;options]
pub fn (mut app App) get_languages() vweb.Result {
	if app.req.method == http.Method.options {
		return app.text("[]")
	}
	return app.json[[]string](app.pool.get_languages())
}
['/technologies'; get;options]
pub fn (mut app App) get_technologies() vweb.Result {
	if app.req.method == http.Method.options {
		return app.text("[]")
	}
	return app.json[[]entities.TechnoLang](app.pool.get_technologies())
}
