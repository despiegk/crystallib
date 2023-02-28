module markdowndocs

import pathlib

pub struct Doc {
pub mut:
	content string
	items   []DocItem
	path    pathlib.Path
}

type DocItem = Action
	| Actions
	| CodeBlock
	| Comment
	| Header
	| Html
	| Paragraph
	| Table
	| Link



pub fn (mut doc Doc) wiki() string {
	mut out := ''
	for mut item in doc.items {
		match mut item {
			Table { out += item.wiki() }
			Action { out += item.wiki() }
			Actions { out += item.wiki() }
			Header { out += item.wiki() }
			Paragraph { out += item.wiki() }
			Html { out += item.wiki() }
			Comment { out += item.wiki() }
			CodeBlock { out += item.wiki() }
			Link { out += item.wiki() }
		}
	}
	return out
}


fn (mut doc Doc) process() ! {
	doc.parse()!
	for mut item in doc.items {
		match mut item {
			Table { item.process()! }
			Action { item.process()! }
			Actions { item.process()! }
			Header { item.process()! }
			Paragraph { item.process()! }
			Html { item.process()! }
			Comment { item.process()! }
			CodeBlock { item.process()! }
			Link { item.process()! }
		}
	}
}

pub fn (mut doc Doc) html() string {
	mut out := ''
	for mut item in doc.items {
		match mut item {
			Table { out += item.html() }
			Action { out += item.html() }
			Actions { out += item.html() }
			Header { out += '<h${item.depth}>${item.content}</h${item.depth}>\n' } //todo: should be moved to item.html()
			Paragraph { out += '<p>${item.content}</p>\n' }
			Html { out += item.html() }
			Comment { out += item.html() }
			CodeBlock { out += item.html() }
			Link { out += item.html() }
		}
	}
	return out
}

pub fn (mut doc Doc) save_wiki() ! {
	doc.path.write(doc.wiki())!
}


// fn (mut doc Doc) last_item_name() string {
// 	return parser.doc.items.last().type_name().all_after_last('.').to_lower()
// }

// // if state is this name will return true
// fn (mut doc Doc) last_item_name_check(tocheck string) bool {
// 	if doc.last_item_name() == tocheck.to_lower().trim_space() {
// 		return true
// 	}
// 	return false
// }