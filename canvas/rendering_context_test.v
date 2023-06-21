module canvas


fn test_create(){
	ctx:=canvas_rendering_context2d_svg_init()
	println(ctx.canvas.to_xml())
	println(ctx)
	assert ctx.canvas.to_xml() == '<svg xmlns="http://www.w3.org/2000/svg"></svg>' , '${ctx.canvas.to_xml()} is not ok'
}
fn test_viewbox(){
	mut ctx:=canvas_rendering_context2d_svg_init()
	ctx.set_view_box(0,0,1024,768)
	println(ctx.canvas.to_xml())
	println(ctx)
	assert ctx.canvas.to_xml() == '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0.0 0.0 1024.0 768.0"></svg>' , '${ctx.canvas.to_xml()} is not ok'
}

fn test_stroke_rect(){
	mut ctx:=canvas_rendering_context2d_svg_init()
	ctx.stroke_style="#AA3333"
	ctx.stroke_rect(0,0,10,10)
	println(ctx.canvas.to_xml())
	println(ctx.canvas)
	assert ctx.canvas.to_xml() == '<svg xmlns="http://www.w3.org/2000/svg"><rect x="0.0" y="0.0" width="10.0" height="10.0" stroke="${ctx.stroke_style}"></rect></svg>' , '${ctx.canvas.to_xml()} is not ok'
}

fn test_fill_rect(){
	mut ctx:=canvas_rendering_context2d_svg_init()
	ctx.fill_style="#AA3333"
	ctx.fill_rect(0,0,10,10)
	println(ctx.canvas.to_xml())
	println(ctx.canvas)
	assert ctx.canvas.to_xml() == '<svg xmlns="http://www.w3.org/2000/svg"><rect x="0.0" y="0.0" width="10.0" height="10.0" fill="${ctx.fill_style}"></rect></svg>' , '${ctx.canvas.to_xml()} is not ok'
}

fn test_stroke_path(){
	mut ctx:=canvas_rendering_context2d_svg_init()
	ctx.fill_style="#FFFFAA"
	ctx.begin_path()
	ctx.move_to(0,0)
	ctx.line_to(0,10)
	ctx.line_to(10,10)
	ctx.line_to(10,0)
	ctx.close_path()
	ctx.stroke()
	ctx.begin_path()
	ctx.move_to(0,0)
	ctx.line_to(0,10)
	ctx.line_to(10,10)
	ctx.line_to(10,0)
	ctx.stroke_style="#AA3333"
	ctx.stroke()
	ctx.fill()
	println(ctx.canvas.to_xml())
	println(ctx.canvas)
}

fn test_save_restore(){
	mut ctx:=canvas_rendering_context2d_svg_init()
	ctx.fill_rect(0,0,10,10)
	ctx.save()
	ctx.fill_rect(0,0,10,10)
	ctx.restore()

	ctx.save()
	ctx.translate(10,10)
	ctx.fill_rect(0,0,10,10)
	ctx.restore()

	println(ctx.canvas.to_xml())
	println(ctx.canvas)
}
fn test_translate(){
	mut ctx:=canvas_rendering_context2d_svg_init()
	ctx.fill_rect(0,0,10,10)
	ctx.save()
	ctx.translate(10,10)
	ctx.fill_rect(0,0,10,10)
	ctx.restore()

	println(ctx.canvas.to_xml())
	println(ctx.canvas)
}
