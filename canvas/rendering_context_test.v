module canvas


fn test_create(){
	ctx:=canvas_rendering_context2d_svg_init()
	println(ctx.canvas.to_xml())
	println(ctx)
}

fn test_stroke_rect(){
	mut ctx:=canvas_rendering_context2d_svg_init()
	ctx.stroke_rect(0,0,10,10)
	println(ctx.canvas.to_xml())
	println(ctx.canvas)
}

fn test_fill_rect(){
	mut ctx:=canvas_rendering_context2d_svg_init()
	ctx.fill_rect(0,0,10,10)
	println(ctx.canvas.to_xml())
	println(ctx.canvas)
}

fn test_stroke_path(){
	mut ctx:=canvas_rendering_context2d_svg_init()
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
	ctx.close_path()
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
