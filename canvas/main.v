module main

import canvas

fn main() {
	println('Hello, World!')
	ce:=canvas.create_element
	mut div:=ce("pre")
	div.set_attribute("class","button button-primary")
	div.set_attribute("id","1234567")
	div.append_child(ce("a"))
	div.append_child(ce("b"))
	div.append_child(ce("code"))
	div.append_child(ce("div"))
	println(div.to_xml())
}
