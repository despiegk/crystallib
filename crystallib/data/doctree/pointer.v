module doctree

import freeflowuniverse.crystallib.core.texttools

pub enum PointerCat {
	page
	image
	video
	file
	html
}

// links to a page, image or file
pub struct Pointer {
pub mut:
	playbook  string // is the key of a playbook
	name      string // is name without extension, all namefixed (lowercase...)
	cat       PointerCat
	extension string // e.g. jpg
	error     string // if there is an error on the pointer, then will be visible in this property
	tree      string
}

// will return a clean pointer to a page, image or file
//```
// input is e.g. myplaybook:filename.jpg
// 	or filename.jpg
// 	or mypage.md
//
//```
pub fn pointer_new(txt_ string) !Pointer {
	mut p := Pointer{}
	mut txt := txt_.trim_space().replace('\\', '/').replace('//', '/').all_after_last('/')

	// take colon parts out
	nrcolon := txt.count(':')
	splitted_colons := txt.split(':')
	if nrcolon > 2 {
		return error("pointer can only have 2 ':' inside. ${txt}")
	} else if nrcolon == 1 {
		p.playbook = texttools.name_fix_keepext(splitted_colons[0])
		p.name = texttools.name_fix_keepext(splitted_colons[1])
	} else {
		p.name = texttools.name_fix_keepext(splitted_colons[0])
	}

	splitted := p.name.split('.')
	if splitted.len == 0 {
		// no extension so needs to be markdown
		p.cat = .page
	} else {
		// now need to check if we find imagename		
		p.extension = splitted.last().to_lower()
		if p.extension == 'md' {
			p.cat = .page
		} else if p.extension in ['jpg', 'jpeg', 'svg', 'gif', 'png'] {
			p.cat = .image
		} else if p.extension in ['mp4', 'mov'] {
			p.cat = .image
		} else {
			p.cat = .file
		}
		p.name = splitted[0]
	}

	if p.cat == .image || p.cat == .page {
		p.name = p.name.trim_right('_')
	}

	return p
}

// represents the pointer in minimal string format
pub fn (p Pointer) str() string {
	mut out := ''
	if p.playbook.len > 0 {
		out = '${p.playbook}:${p.name}'
	} else {
		out = p.name
	}

	if p.extension.len > 0 {
		out += '.${p.extension}'
	}
	return out
}

pub fn (p Pointer) is_image() bool {
	return p.cat == .image
}

pub fn (p Pointer) is_file_video_html() bool {
	return p.cat == .image || p.cat == .file || p.cat == .video
}
