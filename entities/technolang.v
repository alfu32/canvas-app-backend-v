module entities

pub struct TechnoLang{
	pub:
	technoid string="none"
	langid string="markdown"
	extension string="md"
}
pub fn new_technolang() TechnoLang {
	return TechnoLang{"none","markdown","md"}
}
