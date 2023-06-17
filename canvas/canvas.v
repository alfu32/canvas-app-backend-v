module canvas


type Number =f64
enum GlobalCompositeOperation{
	color = "color"
	color_burn = "color-burn"
	color_dodge = "color-dodge"
	copy = "copy"
	darken = "darken"
	destination_atop = "destination-atop"
	destination_in = "destination-in"
	destination_out = "destination-out"
	destination_over = "destination-over"
	difference = "difference"
	exclusion = "exclusion"
	hard_light = "hard-light"
	hue = "hue"
	lighten = "lighten"
	lighter = "lighter"
	luminosity = "luminosity"
	multiply = "multiply"
	overlay = "overlay"
	saturation = "saturation"
	screen = "screen"
	soft_light = "soft-light"
	source_atop = "source-atop"
	source_in = "source-in"
	source_out = "source-out"
	source_over = "source-over"
	xor = "xor"
}
interface CanvasCompositing {
	global_alpha Number
	global_composite_operation GlobalCompositeOperation
}
type CanvasImageSource=string
type CanvasGradient=string
type CanvasPattern=string
type CanvasFillRule = "evenodd" | "nonzero";

interface CanvasDrawImage {
	drawImage(image CanvasImageSource, dx Number, dy Number) void
	drawImage(image CanvasImageSource, dx Number, dy Number, dw Number, dh Number) void
	drawImage(image CanvasImageSource, sx Number, sy Number, sw Number, sh Number, dx Number, dy Number, dw Number, dh Number) void
}

interface CanvasDrawPath {
  beginPath() void
  clip(fillRule? CanvasFillRule) void
  clip(path Path2D, fillRule? CanvasFillRule) void
  fill(fillRule? CanvasFillRule) void
  fill(path Path2D, fillRule? CanvasFillRule) void
  isPointInPath(x Number, y Number, fillRule? CanvasFillRule) bool
  isPointInPath(path Path2D, x Number, y Number, fillRule? CanvasFillRule) bool
  isPointInStroke(x Number, y Number) bool
  isPointInStroke(path Path2D, x Number, y Number) bool
  stroke() void
  stroke(path Path2D) void
}

interface CanvasFillStrokeStyles {
	fill_style string //  | CanvasGradient | CanvasPattern;
	stroke_style string //  | CanvasGradient | CanvasPattern;
	createConicGradient(startAngle Number, x Number, y Number) CanvasGradient
	createLinearGradient(x0 Number, y0 Number, x1 Number, y1 Number) CanvasGradient
	createPattern(image CanvasImageSource, repetition ?string) !CanvasPattern
	createRadialGradient(x0 Number, y0 Number, r0 Number, x1 Number, y1 Number, r1 Number) CanvasGradient
}

interface CanvasFilters {
	filter string;
}

/** An opaque object describing a gradient. It is returned by the methods CanvasRenderingContext2D.createLinearGradient() or CanvasRenderingContext2D.createRadialGradient(). */
interface CanvasGradient {
/**
 * Adds a color stop with the given color to the gradient at the given offset. 0.0 is the offset at one end of the gradient, 1.0 is the offset at the other end.
 *
 * Throws an "IndexSizeError" DOMException if the offset is out of range. Throws a "SyntaxError" DOMException if the color cannot be parsed.
 */
addColorStop(offset Number, color string) void;
}

type ImageDataSettings=map[string]string
type ImageData=string
interface CanvasImageData {
	createImageData(sw Number, sh Number, settings? ImageDataSettings) ImageData
	createImageData(imagedata ImageData) ImageData
	getImageData(sx Number, sy Number, sw Number, sh Number, settings? ImageDataSettings) ImageData
	putImageData(imagedata ImageData, dx Number, dy Number) void
	putImageData(imagedata ImageData, dx Number, dy Number, dirtyX Number, dirtyY Number, dirtyWidth Number, dirtyHeight Number) void
}
type ImageSmoothingQuality = "high" | "low" | "medium";
interface CanvasImageSmoothing {
	image_smoothing_enabled bool;
	image_smoothing_quality ImageSmoothingQuality;
}

interface CanvasPath {
	arc(x Number, y Number, radius Number, startAngle Number, endAngle Number, counterclockwise? bool) void;
	arcTo(x1 Number, y1 Number, x2 Number, y2 Number, radius Number) void;
	bezierCurveTo(cp1x Number, cp1y Number, cp2x Number, cp2y Number, x Number, y Number) void;
	closePath() void;
	ellipse(x Number, y Number, radiusX Number, radiusY Number, rotation Number, startAngle Number, endAngle Number, counterclockwise? bool) void;
	lineTo(x Number, y Number) void;
	moveTo(x Number, y Number) void;
	quadraticCurveTo(cpx Number, cpy Number, x Number, y Number) void;
	rect(x Number, y Number, w Number, h Number) void;
	roundRect(x Number, y Number, w Number, h Number, radii ?Number[]) void;
}
type CanvasLineCap = "butt" | "round" | "square";
type CanvasLineJoin = "bevel" | "miter" | "round";
interface CanvasPathDrawingStyles {
	line_cap CanvasLineCap;
	line_dash_offset Number;
	line_join CanvasLineJoin;
	line_width Number;
	miter_limit Number;
	getLineDash() Number[];
	setLineDash(segments Number[]) void;
}

/** An opaque object describing a pattern, based on an image, a canvas, or a video, created by the CanvasRenderingContext2D.createPattern() method. */
interface CanvasPattern {
	/** Sets the transformation matrix that will be used when rendering the pattern during a fill or stroke painting operation. */
	setTransform(transform? DOMMatrix2DInit) void;
}

interface CanvasRect {
	clearRect(x Number, y Number, w Number, h Number) void;
	fillRect(x Number, y Number, w Number, h Number) void;
	strokeRect(x Number, y Number, w Number, h Number) void;
}

interface CanvasShadowStyles {
	shadow_blur Number;
	shadow_color string;
	shadow_offset_x Number;
	shadow_offset_y Number;
}

interface CanvasState {
	restore() void;
	save() void;
}

interface CanvasText {
	fillText(text string, x Number, y Number, maxWidth? Number) void;
	measureText(text string) TextMetrics;
	strokeText(text string, x Number, y Number, maxWidth? Number) void;
}

type CanvasDirection = "inherit" | "ltr" | "rtl";
type CanvasFillRule = "evenodd" | "nonzero";
type CanvasFontKerning = "auto" | "none" | "normal";
type CanvasFontStretch = "condensed" | "expanded" | "extra-condensed" | "extra-expanded" | "normal" | "semi-condensed" | "semi-expanded" | "ultra-condensed" | "ultra-expanded";

type CanvasTextAlign = "center" | "end" | "left" | "right" | "start";
type CanvasTextBaseline = "alphabetic" | "bottom" | "hanging" | "ideographic" | "middle" | "top";
interface CanvasTextDrawingStyles {
	direction CanvasDirection;
	font string;
	font_kerning CanvasFontKerning;
	text_align CanvasTextAlign;
	text_baseline CanvasTextBaseline;
}

interface CanvasTransform {
	getTransform() DOMMatrix;
	resetTransform() void;
	rotate(angle Number) void;
	scale(x Number, y Number) void;
	setTransform(a Number, b Number, c Number, d Number, e Number, f Number) void;
	setTransform(transform? DOMMatrix2DInit) void;
	transform(a Number, b Number, c Number, d Number, e Number, f Number) void;
	translate(x Number, y Number) void;
}
interface CanvasRenderingContext2DSettings {
	alpha? bool;
	color_space? PredefinedColorSpace;
	desynchronized? bool;
	will_read_frequently? bool;
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
	canvas DOMNode;
	getContextAttributes() CanvasRenderingContext2DSettings;
}
