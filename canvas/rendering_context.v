module canvas

import math

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
pub mut:
	current_node &DOMNode
	current_path []PointPath
	current_position Point2
	current_transform SVGMatrix
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
	line_dash []Number

	canvas &DOMNode
}

pub fn canvas_rendering_context2d_svg_init() CanvasRenderingContext2DSvg {
	mut svg:=create_element("svg")
	svg.set_attribute("xmlns",'http://www.w3.org/2000/svg')
	return CanvasRenderingContext2DSvg{
		current_node: &svg,
		current_path: []
		current_position: Point2{0,0,0,0,''}
		current_transform: SVGMatrix{}
		fill_style: "#FFFFFF"
		stroke_style: "#000000"
		line_cap: .butt
		line_dash_offset: 2
		line_join: .bevel
		line_width: 1
		miter_limit: 2
		direction: .inherit
		font: "14px Arial"
		font_kerning: .auto
		text_align: .center
		text_baseline: .alphabetic,
		line_dash: []

		canvas: &svg
	}
}

pub fn (mut this CanvasRenderingContext2DSvg) set_view_box(x Number,y Number,w Number,h Number){
	this.canvas.set_attribute("viewBox","$x $y $w $h")
}

pub fn (mut this CanvasRenderingContext2DSvg) begin_path(){
	mut path:=create_element("path")
	if this.current_node.tag_name == "path" {
		this.current_node=this.current_node.parent_node or {
			panic("parent node was none at begin_path() , ${this.current_node.to_xml()}")
		}
	}
	this.current_node.append_child(mut path)
	this.current_node=&path
	this.current_path=[]PointPath{}
}
pub fn (mut this CanvasRenderingContext2DSvg) fill(){
	this.current_node.set_attribute("fill",this.fill_style)
}
pub fn (mut this CanvasRenderingContext2DSvg) stroke(){
	this.current_node.set_attribute("stroke",this.stroke_style)
}
pub fn (mut this CanvasRenderingContext2DSvg) arc(
	x Number, y Number,
	radius Number,
	p_start_angle Number,
	p_end_angle Number,
	counter_clockwise bool
){

	// in canvas no circle is drawn if no angle is provided.
	if p_start_angle == p_end_angle {
		return
	}
	mut start_angle := math.fmod(p_start_angle , ( 2 * math.pi ))
	mut end_angle := math.fmod(p_end_angle , ( 2 * math.pi ))
	if start_angle == end_angle {
		dir := if counter_clockwise { -1.0 } else { 1.0 }
		//circle time! subtract some of the angle so svg is happy (svg elliptical arc can't draw a full circle)
		end_angle = math.fmod(end_angle + (2*math.pi) - 0.001 * dir , (2*math.pi))
	}
	end_x := x+radius*math.cos(end_angle)
	end_y := y+radius*math.sin(end_angle)
	start_x := x+radius*math.cos(start_angle)
	start_y := y+radius*math.sin(start_angle)
	sweep_flag := if counter_clockwise { 0 } else { 1 }
	mut large_arc_flag := 0
	mut diff := end_angle - start_angle

	// https://github.com/gliffy/canvas2svg/issues/4
	if diff < 0 {
		diff += 2*math.pi
	}

	if counter_clockwise {
		large_arc_flag = if diff > math.pi { 0 } else { 1 }
	} else {
		large_arc_flag = if diff > math.pi { 1 } else { 0 }
	}
	this.line_to(start_x, start_y)
	this.current_path << "A $x $y 0 $large_arc_flag $sweep_flag $end_x $end_y"
	this.update_path()
	this.current_position = Point2{x: x, y: y,z:0,t:0,tag:''}
}
pub fn (mut this CanvasRenderingContext2DSvg) arc_to(x1 Number, y1 Number, x2 Number, y2 Number, radius Number) ! {

	// Let the point (x0, y0) be the last point in the subpath.
	x0 := this.current_position.x
	y0 := this.current_position.y

	// Negative values for radius must cause the implementation to throw an IndexSizeError exception.
	if radius < 0 {
		error("IndexSizeError: The radius provided ($radius) is negative.")
	}

	// If the point (x0, y0) is equal to the point (x1, y1),
	// or if the point (x1, y1) is equal to the point (x2, y2),
	// or if the radius radius is zero,
	// then the method must add the point (x1, y1) to the subpath,
	// and connect that point to the previous point (x0, y0) by a straight line.
	if ((x0 == x1) && (y0 == y1))
		|| ((x1 == x2) && (y1 == y2))
		|| (radius == 0) {
		this.line_to(x1, y1)
		return
	}

	// Otherwise, if the points (x0, y0), (x1, y1), and (x2, y2) all lie on a single straight line,
	// then the method must add the point (x1, y1) to the subpath,
	// and connect that point to the previous point (x0, y0) by a straight line.
	unit_vec_p1_p0 := (Point2{x:x0 - x1,y:y0 - y1,z:0,t:0,tag:''}).normalized()
	unit_vec_p1_p2 := (Point2{x:x2 - x1,y:y2 - y1,z:0,t:0,tag:''}).normalized()// normalize([x2 - x1, y2 - y1])
	if unit_vec_p1_p0.x * unit_vec_p1_p2.y == unit_vec_p1_p0.y * unit_vec_p1_p2.x {
		this.line_to(x1, y1)
		return
	}

	// Otherwise, let The Arc be the shortest arc given by circumference of the circle that has radius radius,
	// and that has one point tangent to the half-infinite line that crosses the point (x0, y0) and ends at the point (x1, y1),
	// and that has a different point tangent to the half-infinite line that ends at the point (x1, y1), and crosses the point (x2, y2).
	// The points at which this circle touches these two lines are called the start and end tangent points respectively.

	// note that both vectors are unit vectors, so the length is 1
	cos := (unit_vec_p1_p0.x * unit_vec_p1_p2.x + unit_vec_p1_p0.y * unit_vec_p1_p2.y)
	theta := math.acos(math.abs(cos))

	// Calculate origin
	unit_vec_p1_origin := (Point2{
		x:unit_vec_p1_p0.x + unit_vec_p1_p2.x,
		y:unit_vec_p1_p0.y + unit_vec_p1_p2.y
	}).normalized()
	len_p1_origin := radius / math.sin(theta / 2)
	mut x := x1 + len_p1_origin * unit_vec_p1_origin.x
	mut y := y1 + len_p1_origin * unit_vec_p1_origin.y

	// Calculate start angle and end angle
	// rotate 90deg clockwise (note that y axis points to its down)
	unit_vec_origin_start_tangent := Point2{
		x:-unit_vec_p1_p0.y,
		y:unit_vec_p1_p0.x
	}
	// rotate 90deg counter clockwise (note that y axis points to its down)
	unit_vec_origin_end_tangent := Point2{
		x:unit_vec_p1_p2.y,
		y:-unit_vec_p1_p2.x
	}
	get_angle := fn (vector Point2 ) Number {
		// get angle (clockwise) between vector and (1, 0)
		x := vector.x
		y := vector.y
		if y >= 0 { // note that y axis points to its down
			return math.acos(x)
		} else {
			return -math.acos(x)
		}
	}
	start_angle := get_angle(unit_vec_origin_start_tangent)
	end_angle := get_angle(unit_vec_origin_end_tangent)

	// Connect the point (x0, y0) to the start tangent point by a straight line
	this.line_to(x + unit_vec_origin_start_tangent.x * radius,
	y + unit_vec_origin_start_tangent.y * radius)

	// Connect the start tangent point to the end tangent point by arc
	// and adding the end tangent point to the subpath.
	this.arc(x, y, radius, start_angle, end_angle,false)
}
fn (mut this CanvasRenderingContext2DSvg) update_path(){
	this.current_node.set_attribute("d",this.current_path.join(" "))
}
pub fn (mut this CanvasRenderingContext2DSvg) bezier_curve_to(
	cp1x Number, cp1y Number, cp2x Number, cp2y Number,
	x Number, y Number
){
	this.current_position = Point2{x: x, y: y,z:0,t:0,tag:''}
	this.current_path << "C $cp1x $cp1y $cp2x $cp2y $x $y"
	this.update_path()
}
pub fn (mut this CanvasRenderingContext2DSvg) close_path(){
	this.current_path << "Z"
	this.update_path()
}
pub fn (mut this CanvasRenderingContext2DSvg) ellipse(cx Number, cy Number, rx Number, ry Number, rotation Number, startAngle Number, endAngle Number, counterclockwise bool){
	//<ellipse cx="100" cy="50" rx="100" ry="50" />
	mut ellipse := create_element("ellipse")
	ellipse.set_attribute("cx","$cx")
	ellipse.set_attribute("cy","$cy")
	ellipse.set_attribute("rx","$rx")
	ellipse.set_attribute("ry","$ry")
	this.current_node.append_child(mut ellipse)
}
pub fn (mut this CanvasRenderingContext2DSvg) line_to(x Number, y Number){

	this.current_position = Point2{x: x, y: y,z:0,t:0,tag:''}
	this.current_path << "L $x $y"
	this.update_path()
}
pub fn (mut this CanvasRenderingContext2DSvg) move_to(x Number, y Number){
	this.current_position = Point2{x: x, y: y,z:0,t:0,tag:''}
	this.current_path << "M $x $y"
	this.update_path()
}
pub fn (mut this CanvasRenderingContext2DSvg) quadratic_curve_to(cpx Number, cpy Number, x Number, y Number){
	this.current_position = Point2{x: x, y: y,z:0,t:0,tag:''}
	this.current_path << "Q $cpx $cpy $x $y"
	this.update_path()
}
pub fn (mut this CanvasRenderingContext2DSvg) rect(x Number, y Number, w Number, h Number) &DOMNode{
	mut rect:= create_element("rect")
	rect.set_attribute("x","$x")
	rect.set_attribute("y","$x")
	rect.set_attribute("width","$w")
	rect.set_attribute("height","$h")
	this.current_node.append_child(mut rect)
	return &rect
}
pub fn (mut this CanvasRenderingContext2DSvg) round_rect(x Number, y Number, w Number, h Number, radii []Number) &DOMNode{
	return this.rect(x,y,w,h)
}
pub fn (this CanvasRenderingContext2DSvg) get_line_dash() []Number{
	return this.line_dash
}
pub fn (this CanvasRenderingContext2DSvg) set_line_dash(segments []Number){}
pub fn (this CanvasRenderingContext2DSvg) clear_rect(x Number, y Number, w Number, h Number){}
pub fn (mut this CanvasRenderingContext2DSvg) fill_rect(x Number, y Number, w Number, h Number){
	mut r:=this.rect(x,y,w,h)
	r.set_attribute("fill",this.fill_style)
}
pub fn (mut this CanvasRenderingContext2DSvg) stroke_rect(x Number, y Number, w Number, h Number){
	mut r:= this.rect(x,y,w,h)
	r.set_attribute("stroke",this.stroke_style)
}
pub fn (mut this CanvasRenderingContext2DSvg) save(){
	mut g:=create_element("g")
	this.current_node.append_child(mut g)
	this.current_node=&g
}
pub fn (mut this CanvasRenderingContext2DSvg) restore(){
	this.current_node=this.current_node.parent_node or {
		panic("parent node was none at restore() , ${this.current_node.to_xml()}")
	}
}
pub fn (mut this CanvasRenderingContext2DSvg) text(text string, x Number, y Number, maxWidth Number) DOMNode {
	mut t:=create_element("text")
	t.set_attribute("x","$x")
	t.set_attribute("y","$y")
	t.node_value=text
	this.current_node.append_child(mut t)
	return t
}
pub fn (mut this CanvasRenderingContext2DSvg) fill_text(text string, x Number, y Number, maxWidth Number){
	mut t:=this.text(text,x,y,maxWidth)
	t.set_attribute("fill",this.fill_style)
	this.current_node.append_child(mut t)
}
pub fn (this CanvasRenderingContext2DSvg) measure_text(text string) TextMetrics{
	return TextMetrics{}
}
pub fn (mut this CanvasRenderingContext2DSvg) stroke_text(text string, x Number, y Number, maxWidth Number){
	mut t:=this.text(text,x,y,maxWidth)
	t.set_attribute("stroke",this.stroke_style)
	this.current_node.append_child(mut t)
}
pub fn (mut this CanvasRenderingContext2DSvg) get_transform() SVGMatrix{
	return this.current_transform
}
pub fn (mut this CanvasRenderingContext2DSvg) reset_transform(){
	this.current_node.set_attribute("transform","1 0 0 0 1 0")
}
pub fn (mut this CanvasRenderingContext2DSvg) rotate(angle Number){
	mut tf:= this.current_transform.rotate(angle)
	this.set_transform_matrix(mut tf)
}
pub fn (mut this CanvasRenderingContext2DSvg) scale(x Number, y Number){
	mut tf:=this.current_transform.scale(x,y)
	this.set_transform_matrix(mut tf)
}
pub fn (mut this CanvasRenderingContext2DSvg) set_transform(a Number, b Number, c Number, d Number, e Number, f Number){
	mut arr:=create_matrix(a,b,c,d,e,f)
	this.set_transform_matrix(mut arr)
}
pub fn (mut this CanvasRenderingContext2DSvg) set_transform_matrix(mut tf SVGMatrix){
	this.current_transform=tf
	this.current_node.set_attribute("transform",tf.to_svg_string())
}
pub fn (mut this CanvasRenderingContext2DSvg) transform(a Number, b Number, c Number, d Number, e Number, f Number){
	// this.set_transform(a,b,c,d,e,f)
}
pub fn (mut this CanvasRenderingContext2DSvg) translate(x Number, y Number){
	mut mx:=this.current_transform.translate(x,y)
	this.set_transform_matrix(mut mx)
}
