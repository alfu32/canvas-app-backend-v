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
		"stroke_style":Style{
			svg_attr : "stroke", //corresponding svg attribute
			canvas : "#000000", //canvas default
			svg : "none",       //svg default
			apply : "stroke"    //apply on stroke() or fill()
		},
		"fill_style":Style{
			svg_attr : "fill",
			canvas : "#000000",
			svg : "null", //svg default is black, but we need to special case this to handle canvas_v.exclude stroke without fill
			apply : "fill"
		},
		"line_cap":Style{
			svg_attr : "stroke-linecap",
			canvas : "butt",
			svg : "butt",
			apply : "stroke"
		},
		"line_join":Style{
			svg_attr : "stroke-linejoin",
			canvas : "miter",
			svg : "miter",
			apply : "stroke"
		},
		"miter_limit":Style{
			svg_attr : "stroke-miterlimit",
			canvas : "10",
			svg : "4",
			apply : "stroke"
		},
		"line_width":Style{
			svg_attr : "stroke-width",
			canvas : "1",
			svg : "1",
			apply : "stroke"
		},
		"global_alpha": Style{
			svg_attr : "opacity",
			canvas : "1",
			svg : "1",
			apply : "fill stroke"
		},
		"font":Style{
			//font converts to multiple svg attributes, there is custom logic for this
			canvas : "10px sans-serif"
		},
		"shadow_color":Style{
			canvas : "#000000"
		},
		"shadow_offset_x":Style{
			canvas : "0"
		},
		"shadow_offset_y":Style{
			canvas : "0"
		},
		"shadow_blur":Style{
			canvas : "0"
		},
		"text_align":Style{
			canvas : "start"
		},
		"text_baseline":Style{
			canvas : "alphabetic"
		}
	}
}
