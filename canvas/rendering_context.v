module canvas

interface CanvasRenderingContext2DInterface{
	fill_style string //  | CanvasGradient | CanvasPattern
	stroke_style string //  | CanvasGradient | CanvasPattern
	begin_path()
	fill()
	stroke()
	arc(x Number, y Number, radius Number, startAngle Number, endAngle Number, counterclockwise bool)
	arc_to(x1 Number, y1 Number, x2 Number, y2 Number, radius Number)
	bezier_curve_to(cp1x Number, cp1y Number, cp2x Number, cp2y Number, x Number, y Number)
	close_path()
	ellipse(x Number, y Number, radiusX Number, radiusY Number, rotation Number, startAngle Number, endAngle Number, counterclockwise bool)
	line_to(x Number, y Number)
	move_to(x Number, y Number)
	quadratic_curve_to(cpx Number, cpy Number, x Number, y Number)
	rect(x Number, y Number, w Number, h Number)
	round_rect(x Number, y Number, w Number, h Number, radii []Number)
	line_cap CanvasLineCap
	line_dash_offset Number
	line_join CanvasLineJoin
	line_width Number
	miter_limit Number
	get_line_dash() []Number
	set_line_dash(segments []Number)
	clear_rect(x Number, y Number, w Number, h Number)
	fill_rect(x Number, y Number, w Number, h Number)
	stroke_rect(x Number, y Number, w Number, h Number)
	restore()
	save()
	direction CanvasDirection
	font string
	font_kerning CanvasFontKerning
	text_align CanvasTextAlign
	text_baseline CanvasTextBaseline

	fill_text(text string, x Number, y Number, maxWidth Number)
	measure_text(text string) TextMetrics
	stroke_text(text string, x Number, y Number, maxWidth Number)

	get_transform() SVGMatrix// DOMMatrix
	reset_transform()
	rotate(angle Number)
	scale(x Number, y Number)
	set_transform(a Number, b Number, c Number, d Number, e Number, f Number)
	set_transform_matrix(transform SVGMatrix)
	transform(a Number, b Number, c Number, d Number, e Number, f Number)
	translate(x Number, y Number)

	canvas DOMNode
}


struct CanvasRenderingContext2DSvg {
mut:
	current_node DOMNode
	current_path Path2D
pub mut:
	fill_style string //  | CanvasGradient | CanvasPattern
	stroke_style string //  | CanvasGradient | CanvasPattern
	line_cap CanvasLineCap
	line_dash_offset Number
	line_join CanvasLineJoin
	line_width Number
	miter_limit Number
	direction CanvasDirection
	font string
	font_kerning CanvasFontKerning
	text_align CanvasTextAlign
	text_baseline CanvasTextBaseline

	canvas DOMNode
}



pub fn (mut ctx CanvasRenderingContext2DSvg) begin_path(){
	ctx.current_path=[]Point2D{}
}
pub fn (ctx CanvasRenderingContext2DSvg) fill(){}
pub fn (ctx CanvasRenderingContext2DSvg) stroke(){}
pub fn (ctx CanvasRenderingContext2DSvg) arc(x Number, y Number, radius Number, startAngle Number, endAngle Number, counterclockwise bool){}
pub fn (ctx CanvasRenderingContext2DSvg) arc_to(x1 Number, y1 Number, x2 Number, y2 Number, radius Number){}
pub fn (ctx CanvasRenderingContext2DSvg) bezier_curve_to(cp1x Number, cp1y Number, cp2x Number, cp2y Number, x Number, y Number){}
pub fn (ctx CanvasRenderingContext2DSvg) close_path(){}
pub fn (ctx CanvasRenderingContext2DSvg) ellipse(x Number, y Number, radiusX Number, radiusY Number, rotation Number, startAngle Number, endAngle Number, counterclockwise bool){}
pub fn (ctx CanvasRenderingContext2DSvg) line_to(x Number, y Number){}
pub fn (ctx CanvasRenderingContext2DSvg) move_to(x Number, y Number){}
pub fn (ctx CanvasRenderingContext2DSvg) quadratic_curve_to(cpx Number, cpy Number, x Number, y Number){}
pub fn (ctx CanvasRenderingContext2DSvg) rect(x Number, y Number, w Number, h Number){

}
pub fn (ctx CanvasRenderingContext2DSvg) round_rect(x Number, y Number, w Number, h Number, radii []Number){}
pub fn (ctx CanvasRenderingContext2DSvg) get_line_dash() []Number{
	return []
}
pub fn (ctx CanvasRenderingContext2DSvg) set_line_dash(segments []Number){}
pub fn (ctx CanvasRenderingContext2DSvg) clear_rect(x Number, y Number, w Number, h Number){}
pub fn (ctx CanvasRenderingContext2DSvg) fill_rect(x Number, y Number, w Number, h Number){}
pub fn (ctx CanvasRenderingContext2DSvg) stroke_rect(x Number, y Number, w Number, h Number){}
pub fn (ctx CanvasRenderingContext2DSvg) restore(){}
pub fn (mut ctx CanvasRenderingContext2DSvg) save(){
	ctx.current_node=create_element("g")
}
pub fn (ctx CanvasRenderingContext2DSvg) fill_text(text string, x Number, y Number, maxWidth Number){}
pub fn (ctx CanvasRenderingContext2DSvg) measure_text(text string) TextMetrics{
	return TextMetrics{}
}
pub fn (ctx CanvasRenderingContext2DSvg) stroke_text(text string, x Number, y Number, maxWidth Number){}
pub fn (ctx CanvasRenderingContext2DSvg) get_transform() SVGMatrix{
	return [
		1.0,0,0,0,
		0,1,0,0,
		0,0,1,0,
		0,0,0,1,
	]
}
pub fn (ctx CanvasRenderingContext2DSvg) reset_transform(){}
pub fn (ctx CanvasRenderingContext2DSvg) rotate(angle Number){}
pub fn (ctx CanvasRenderingContext2DSvg) scale(x Number, y Number){}
pub fn (ctx CanvasRenderingContext2DSvg) set_transform(a Number, b Number, c Number, d Number, e Number, f Number){}
pub fn (ctx CanvasRenderingContext2DSvg) set_transform_matrix(transform SVGMatrix){}
pub fn (ctx CanvasRenderingContext2DSvg) transform(a Number, b Number, c Number, d Number, e Number, f Number){}
pub fn (ctx CanvasRenderingContext2DSvg) translate(x Number, y Number){}
