module canvas


pub struct Style{
	svg_attr string
	canvas string
	svg string
	apply string
}
pub fn get_styles() map[string]Style {
	//Some basic mappings for attributes and default values.
	return {
		"strokeStyle":Style{
			svg_attr : "stroke", //corresponding svg attribute
			canvas : "#000000", //canvas default
			svg : "none",       //svg default
			apply : "stroke"    //apply on stroke() or fill()
		},
		"fillStyle":Style{
			svg_attr : "fill",
			canvas : "#000000",
			svg : "null", //svg default is black, but we need to special case this to handle canvas stroke without fill
			apply : "fill"
		},
		"lineCap":Style{
			svg_attr : "stroke-linecap",
			canvas : "butt",
			svg : "butt",
			apply : "stroke"
		},
		"lineJoin":Style{
			svg_attr : "stroke-linejoin",
			canvas : "miter",
			svg : "miter",
			apply : "stroke"
		},
		"miterLimit":Style{
			svg_attr : "stroke-miterlimit",
			canvas : "10",
			svg : "4",
			apply : "stroke"
		},
		"lineWidth":Style{
			svg_attr : "stroke-width",
			canvas : "1",
			svg : "1",
			apply : "stroke"
		},
		"globalAlpha": Style{
			svg_attr : "opacity",
			canvas : "1",
			svg : "1",
			apply : "fill stroke"
		},
		"font":Style{
			//font converts to multiple svg attributes, there is custom logic for this
			canvas : "10px sans-serif"
		},
		"shadowColor":Style{
			canvas : "#000000"
		},
		"shadowOffsetX":Style{
			canvas : "0"
		},
		"shadowOffsetY":Style{
			canvas : "0"
		},
		"shadowBlur":Style{
			canvas : "0"
		},
		"textAlign":Style{
			canvas : "start"
		},
		"textBaseline":Style{
			canvas : "alphabetic"
		}
	}
}
