module canvas

interface CanvasCompositing {
	global_alpha Number
	global_composite_operation GlobalCompositeOperation
}

interface CanvasDrawImage {
	//drawImage(image CanvasImageSource, dx Number, dy Number)
	//drawImage(image CanvasImageSource, dx Number, dy Number, dw Number, dh Number)
	draw_image(image CanvasImageSource, sx Number, sy Number, sw Number, sh Number, dx Number, dy Number, dw Number, dh Number)
}
interface CanvasDrawPath {
  begin_path()
  // clip(fillRule CanvasFillRule)
  clip(path Path2D, fillRule CanvasFillRule)
  // fill(fillRule CanvasFillRule)
  fill(path Path2D, fillRule CanvasFillRule)
  // is_point_in_path(x Number, y Number, fillRule CanvasFillRule) bool
  is_point_in_path(path Path2D, x Number, y Number, fillRule CanvasFillRule) bool
  // is_point_in_stroke(x Number, y Number) bool
  is_point_in_stroke(path Path2D, x Number, y Number) bool
  stroke()
  // stroke(path Path2D)
}

interface CanvasFillStrokeStyles {
	fill_style string //  | CanvasGradient | CanvasPattern
	stroke_style string //  | CanvasGradient | CanvasPattern
	create_conic_gradient(startAngle Number, x Number, y Number) CanvasGradient
	create_linear_gradient(x0 Number, y0 Number, x1 Number, y1 Number) CanvasGradient
	create_pattern(image CanvasImageSource, repetition string) !CanvasPattern
	create_radial_gradient(x0 Number, y0 Number, r0 Number, x1 Number, y1 Number, r1 Number) CanvasGradient
}

interface CanvasFilters {
	filter string
}

/** An opaque object describing a gradient. It is returned by the methods CanvasRenderingContext2D.createLinearGradient() or CanvasRenderingContext2D.createRadialGradient(). */
interface CanvasGradient {
/**
 * Adds a color stop with the given color to the gradient at the given offset. 0.0 is the offset at one end of the gradient, 1.0 is the offset at the other end.
 *
 * Throws an "IndexSizeError" DOMException if the offset is out of range. Throws a "SyntaxError" DOMException if the color cannot be parsed.
 */
add_color_stop(offset Number, color string)
}
interface CanvasImageData {
	create_image_data(sw Number, sh Number, settings ImageDataSettings) ImageData
	// create_image_data(imagedata ImageData) ImageData
	get_image_data(sx Number, sy Number, sw Number, sh Number, settings ImageDataSettings) ImageData
	//put_image_data(imagedata ImageData, dx Number, dy Number)
	put_image_data(imagedata ImageData, dx Number, dy Number, dirtyX Number, dirtyY Number, dirtyWidth Number, dirtyHeight Number)
}
interface CanvasImageSmoothing {
	image_smoothing_enabled bool
	image_smoothing_quality ImageSmoothingQuality
}

interface CanvasPath {
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
}
interface CanvasPathDrawingStyles {
	line_cap CanvasLineCap
	line_dash_offset Number
	line_join CanvasLineJoin
	line_width Number
	miter_limit Number
	get_line_dash() []Number
	set_line_dash(segments []Number)
}

/** An opaque object describing a pattern, based on an image, a canvas, or a video, created by the CanvasRenderingContext2D.createPattern() method. */
interface CanvasPattern {
	/** Sets the transformation matrix that will be used when rendering the pattern during a fill or stroke painting operation. */
	set_transform(transform SVGMatrix)
}

interface CanvasRect {
	clear_rect(x Number, y Number, w Number, h Number)
	fill_rect(x Number, y Number, w Number, h Number)
	stroke_rect(x Number, y Number, w Number, h Number)
}

interface CanvasShadowStyles {
	shadow_blur Number
	shadow_color string
	shadow_offset_x Number
	shadow_offset_y Number
}

interface CanvasState {
	restore()
	save()
}

struct TextMetrics {
/** Returns the measurement described below. */
actual_bounding_box_ascent  Number
/** Returns the measurement described below. */
actual_bounding_box_descent  Number
/** Returns the measurement described below. */
actual_bounding_box_left  Number
/** Returns the measurement described below. */
actual_bounding_box_right  Number
/** Returns the measurement described below. */
font_bounding_box_ascent  Number
/** Returns the measurement described below. */
font_bounding_box_descent  Number
/** Returns the measurement described below. */
width  Number
}
interface CanvasText {
	fill_text(text string, x Number, y Number, maxWidth Number)
	measure_text(text string) TextMetrics
	stroke_text(text string, x Number, y Number, maxWidth Number)
}
interface CanvasTextDrawingStyles {
	direction CanvasDirection
	font string
	font_kerning CanvasFontKerning
	text_align CanvasTextAlign
	text_baseline CanvasTextBaseline
}

interface CanvasTransform {
	get_transform() SVGMatrix// DOMMatrix
	reset_transform()
	rotate(angle Number)
	scale(x Number, y Number)
	set_transform(a Number, b Number, c Number, d Number, e Number, f Number)
	set_transform_matrix(transform SVGMatrix)
	transform(a Number, b Number, c Number, d Number, e Number, f Number)
	translate(x Number, y Number)
}
interface CanvasRenderingContext2DSettings {
	alpha bool
	color_space PredefinedColorSpace
	desynchronized bool
	will_read_frequently bool
}

/** The CanvasRenderingContext2D interface, part of the Canvas API, provides the 2D rendering context for the drawing surface of a <canvas> element. It is used for drawing shapes, text, images, and other objects. */
interface CanvasRenderingContext2D{
	CanvasCompositing
	CanvasDrawImage
	CanvasDrawPath
	CanvasFillStrokeStyles
	CanvasFilters
	CanvasImageData
	CanvasImageSmoothing
	CanvasPath
	CanvasPathDrawingStyles
	CanvasRect
	CanvasShadowStyles
	CanvasState
	CanvasText
	CanvasTextDrawingStyles
	CanvasTransform
	canvas DOMNode
	get_context_attributes() CanvasRenderingContext2DSettings
}
