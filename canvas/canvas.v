module canvas

type SVGMatrix=[]f64
type Number =f64
enum GlobalCompositeOperation{
	color=0xFF
	color_burn
	color_dodge
	copy
	darken
	destination_atop
	destination_in
	destination_out
	destination_over
	difference
	exclusion
	hard_light
	hue
	lighten
	lighter
	luminosity
	multiply
	overlay
	saturation
	screen
	soft_light
	source_atop
	source_in
	source_out
	source_over
	xor
}
pub fn (gco GlobalCompositeOperation) to_string() string{
	return match gco {
		.color { "color" }
		.color_burn { "color-burn" }
		.color_dodge { "color-dodge" }
		.copy { "copy" }
		.darken { "darken" }
		.destination_atop { "destination-atop" }
		.destination_in { "destination-in" }
		.destination_out { "destination-out" }
		.destination_over { "destination-over" }
		.difference { "difference" }
		.exclusion { "exclusion" }
		.hard_light { "hard-light" }
		.hue { "hue" }
		.lighten { "lighten" }
		.lighter { "lighter" }
		.luminosity { "luminosity" }
		.multiply { "multiply" }
		.overlay { "overlay" }
		.saturation { "saturation" }
		.screen { "screen" }
		.soft_light { "soft-light" }
		.source_atop { "source-atop" }
		.source_in { "source-in" }
		.source_out { "source-out" }
		.source_over { "source-over" }
		.xor { "xor" }
	}
}
interface CanvasCompositing {
	global_alpha Number
	global_composite_operation GlobalCompositeOperation
}
type CanvasImageSource=string

interface CanvasDrawImage {
	//drawImage(image CanvasImageSource, dx Number, dy Number)
	//drawImage(image CanvasImageSource, dx Number, dy Number, dw Number, dh Number)
	draw_image(image CanvasImageSource, sx Number, sy Number, sw Number, sh Number, dx Number, dy Number, dw Number, dh Number)
}
type Path2D=[]f64
interface CanvasDrawPath {
  begin_path()
  // clip(fillRule ?CanvasFillRule)
  clip(path Path2D, fillRule ?CanvasFillRule)
  // fill(fillRule ?CanvasFillRule)
  fill(path Path2D, fillRule ?CanvasFillRule)
  // is_point_in_path(x Number, y Number, fillRule ?CanvasFillRule) bool
  is_point_in_path(path Path2D, x Number, y Number, fillRule ?CanvasFillRule) bool
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
	create_pattern(image CanvasImageSource, repetition ?string) !CanvasPattern
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

type ImageDataSettings=map[string]string
type ImageData=string
interface CanvasImageData {
	create_image_data(sw Number, sh Number, settings ?ImageDataSettings) ImageData
	// create_image_data(imagedata ImageData) ImageData
	get_image_data(sx Number, sy Number, sw Number, sh Number, settings ?ImageDataSettings) ImageData
	//put_image_data(imagedata ImageData, dx Number, dy Number)
	put_image_data(imagedata ImageData, dx Number, dy Number, dirtyX Number, dirtyY Number, dirtyWidth Number, dirtyHeight Number)
}
enum ImageSmoothingQuality{
	high=0xEF //="high"
	low //="low"
	medium //="medium"
}
pub fn (isq ImageSmoothingQuality) to_string() string{
	return match isq {
		.high { "high"}
		.low { "low"}
		.medium { "medium"}
	}
}
interface CanvasImageSmoothing {
	image_smoothing_enabled bool
	image_smoothing_quality ImageSmoothingQuality
}

interface CanvasPath {
	arc(x Number, y Number, radius Number, startAngle Number, endAngle Number, counterclockwise? bool)
	arc_to(x1 Number, y1 Number, x2 Number, y2 Number, radius Number)
	bezier_curve_to(cp1x Number, cp1y Number, cp2x Number, cp2y Number, x Number, y Number)
	close_path()
	ellipse(x Number, y Number, radiusX Number, radiusY Number, rotation Number, startAngle Number, endAngle Number, counterclockwise? bool)
	line_to(x Number, y Number)
	move_to(x Number, y Number)
	quadratic_curve_to(cpx Number, cpy Number, x Number, y Number)
	rect(x Number, y Number, w Number, h Number)
	round_rect(x Number, y Number, w Number, h Number, radii ?[]Number)
}
enum CanvasLineCap{
	butt=0xDF//="butt"
	round//="round"
	square//="square"
}
pub fn (clc CanvasLineCap) to_string() string{
	return match clc {
		.butt { "butt"}
		.round { "round"}
		.square { "square"}
	}
}
enum CanvasLineJoin{
	bevel=0xCF//="bevel"
	miter//="miter"
	round//="round"
}
pub fn (clj CanvasLineJoin) to_string() string{
	return match clj {
		.bevel { "bevel"}
		.miter { "miter"}
		.round { "round"}
	}
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
	set_transform(transform ?SVGMatrix)
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

interface TextMetrics {
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
	fill_text(text string, x Number, y Number, maxWidth ?Number)
	measure_text(text string) TextMetrics
	stroke_text(text string, x Number, y Number, maxWidth ?Number)
}

enum CanvasDirection{
	inherit=0xBF//="inherit"
	ltr//="ltr"
	rtl//="rtl"
}
pub fn (cd CanvasDirection) to_string() string{
	return match cd {
		.inherit { "inherit"}
		.ltr { "ltr"}
		.rtl { "rtl"}
	}
}
enum CanvasFillRule{
	evenodd=0xAF//="evenodd"
	nonzero//="nonzero"
}
pub fn (cfr CanvasFillRule) to_string() string{
	return match cfr {
		.evenodd { "evenodd"}
		.nonzero { "nonzero"}
	}
}
enum CanvasFontKerning{
	auto=0x9F//="auto"
	no//"none"
	normal//="normal"
}
pub fn (cfk CanvasFontKerning) to_string() string{
	return match cfk {
		.auto { "auto"}
		.no { "none"}
		.normal { "normal"}
	}
}
enum CanvasFontStretch{
	condensed=0x8F//="condensed"
	expanded//="expanded"
	extra_condensed//="extra-condensed"
	extra_expanded//="extra-expanded"
	normal//="normal"
	semi_condensed//="semi-condensed"
	semi_expanded//="semi-expanded"
	ultra_condensed//="ultra-condensed"
	ultra_expanded//="ultra-expanded"
}
pub fn (cfs CanvasFontStretch) to_string() string{
	return match cfs {
		.condensed { "condensed" }
		.expanded { "expanded" }
		.extra_condensed { "extra-condensed" }
		.extra_expanded { "extra-expanded" }
		.normal { "normal" }
		.semi_condensed { "semi-condensed" }
		.semi_expanded { "semi-expanded" }
		.ultra_condensed { "ultra-condensed" }
		.ultra_expanded { "ultra-expanded" }
	}
}

enum CanvasTextAlign{
	center=0x7F//="center"
	end//="end"
	left//="left"
	right//="right"
	start//="start"
}
pub fn (cta CanvasTextAlign) to_string() string{
	return match cta {
		.center { "center"}
		.end { "end"}
		.left { "left"}
		.right { "right"}
		.start { "start"}
	}
}
enum CanvasTextBaseline{
	alphabetic=0x6F//="alphabetic"
	bottom//="bottom"
	hanging//="hanging"
	ideographic//="ideographic"
	middle//="middle"
	top//="top"
}
pub fn (ctbl CanvasTextBaseline) to_string() string{
	return match ctbl {
		.alphabetic { "alphabetic"}
		.bottom { "bottom"}
		.hanging { "hanging"}
		.ideographic { "ideographic"}
		.middle { "middle"}
		.top { "top"}
	}
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
enum PredefinedColorSpace {
	display_p3=0x5F//"display-p3"
	srgb// ="srgb"
}
pub fn (pcs PredefinedColorSpace) to_string() string{
	return match pcs {
		.display_p3 { "display-p3"}
		.srgb { "srgb"}
	}
}
interface CanvasRenderingContext2DSettings {
	alpha? bool
	color_space ?PredefinedColorSpace
	desynchronized? bool
	will_read_frequently? bool
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
