module canvas

fn test_node_type_from_text(){
	text:="text"
	document:="document"
	element:="element"
	attribute:="attribute"

	assert (node_type_from_text(text)==.text)
	assert (node_type_from_text(document)==.document)
	assert (node_type_from_text(element)==.element)
	assert (node_type_from_text(attribute)==.attribute)
}
fn test_create_element(){
	node:=create_element("div")
	println("node")
}

fn test_to_xml(){

	ce:=canvas.create_element
	mut div:=ce("pre")
	div.set_attribute("class","button button-primary")
	div.set_attribute("id","1234567")
	div.append_child(mut ce("a"))
	div.append_child(mut ce("b"))
	div.append_child(mut ce("code"))
	div.append_child(mut ce("div"))
	println(div.to_xml())
	assert (div.to_xml()=='<pre class="button button-primary" id="1234567"><a></a><b></b><code></code><div></div></pre>')
}
