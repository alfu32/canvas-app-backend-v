module canvas

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
