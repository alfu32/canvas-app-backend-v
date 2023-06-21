module canvas

pub enum NodeType{
	text=1
	document=2
	element=3
	attribute=4
}
pub fn node_type_from_text(n string) NodeType {
	return match n {
		"text" { NodeType.text }
		"document" { NodeType.document }
		"element" { NodeType.element }
		"attribute" { NodeType.attribute }
		else { NodeType.element }
	}
}

[heap]
pub struct DOMNode{
	pub mut:
	parent_node ?&DOMNode
	node_type NodeType
	tag_name string
	attributes map[string]string
	children []&DOMNode
	node_value string
}

pub fn create_element(tag string) DOMNode{
	return DOMNode{
		parent_node: none
		node_type: .element
		tag_name: tag
		attributes: {}
		children: []&DOMNode{}
		node_value: ''
	}
}

pub fn (mut node DOMNode) append_child(mut ch &DOMNode) DOMNode{
	node.children << ch
	ch.parent_node=&node
	return node
}
pub fn (mut node DOMNode) set_attribute(attr_name string,attr_value string) DOMNode{
	node.attributes[attr_name]=attr_value
	return node
}
pub fn  (node DOMNode) to_xml() string {
	mut attrtext:= [""]
	for key,val in node.attributes{
		attrtext<<'${key}="${val}"'
	}
	mut childrentext:= []string{}
	for val in node.children{
		childrentext<<val.to_xml()
	}
return "
	<${node.tag_name}${attrtext.join(" ")}>${childrentext.join("")}</${node.tag_name}>
	".trim_indent()
}
