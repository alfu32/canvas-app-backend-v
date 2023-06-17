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
