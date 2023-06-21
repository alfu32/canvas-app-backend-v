module main

import canvas

fn main() {
	println('Hello, World!')
	ce:=canvas.create_element
	mut div:=ce("pre")
	div.set_attribute("class","button button-primary")
	div.set_attribute("id","1234567")
	div.append_child(mut ce("a"))
	div.append_child(mut ce("b"))
	div.append_child(mut ce("code"))
	div.append_child(mut ce("div"))
	println(div.to_xml())
}
