module library

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.markdowndocs { Link, Paragraph }
import freeflowuniverse.crystallib.texttools
import os

pub enum PageStatus {
	unknown
	ok
	error
}

[heap]
pub struct Page {
pub mut: // pointer to chapter
	name           string // received a name fix
	chapter        &Chapter          [str: skip]
	path           pathlib.Path
	pathrel        string
	state          PageStatus
	pages_included []&Page           [str: skip]
	pages_linked   []&Page           [str: skip]
	files_linked   []&File           [str: skip]
	categories     []string
	doc            &markdowndocs.Doc [str: skip]
	readonly       bool
	changed 	   bool
}

//update link on the page, find the link into the chapter
fn (mut page Page) link_update(mut link Link) ! {
	mut linkout:=link
	mut file_name := link.filename
	$if debug {
		println(' - get link ${link.content} with name:\'${file_name}\' for page: ${page.path.path}')
	}
	// check if the file or image is there, if yes we can return, nothing to do
	mut file_search := true
	mut fileoj0 := File{
		chapter: page.chapter
	}
	mut fileobj := &fileoj0

	if link.cat == .image {
		if page.chapter.image_exists(file_name) {
			file_search = false
			fileobj = page.chapter.image_get(file_name)!
		}
	} else {
		if page.chapter.file_exists(file_name) {
			file_search = false
			fileobj = page.chapter.file_get(file_name)!
		}
	}
	// TODO: implement wider search
	// if file_search {
	// 	// if the chapter is filled in then it means we need to copy the file here,
	// 	// or the image is not found, then we need to try and find it somewhere else
	// 	// we need to copy the image here
	// 	fileobj = page.chapter.chapters.image_file_find_over_chapters(file_name) or {
	// 		msg := "'${file_name}' not found for page:${page.path.path}, we looked over all chapters."
	// 		println('    * ${msg}')
	// 		page.chapter.error(path: page.path, msg: 'image ${msg}', cat: .image_not_found)
	// 		return
	// 	}
	// 	// we found the image should copy to the chapter now
	// 	println("     * image or file found in other chapter: '${fileobj}'")
	// 	println(link)
	// 	mut dest := pathlib.get('${page.path.path_dir()}/img/${fileobj.path.name()}')
	// 	pathlib.get_dir('${page.path.path_dir()}/img', true)! // make sure it exists
	// 	println(' *** COPY: ${fileobj.path.path} to ${dest.path}')
	// 	if fileobj.path.path == dest.path {
	// 		println(fileobj)
	// 		panic('source and destination is same when trying to fix link (copy).')
	// 	}
	// 	fileobj.path.copy(mut dest)!
	// 	page.chapter.image_new(mut dest)! // make sure chapter knows about the new file
	// 	fileobj.path = dest

	// 	fileobj.path.check()
	// 	if fileobj.path.is_link() {
	// 		fileobj.path.unlink()! // make a real file, not a link
	// 	}
	// }

	// means we now found the file or image
	page.files_linked << fileobj
	linkcompare1:=link.description+link.url+link.filename+link.content
	imagelink_rel := pathlib.path_relative(page.path.path_dir(), fileobj.path.path)!
	link.description = ''
	link.url = imagelink_rel
	link.filename = os.base(imagelink_rel)
	link.content = link.wiki()
	linkcompare2:=link.description+link.url+link.filename+link.content
	if linkcompare1!=linkcompare2{
		page.changed=true
	}

	// link.link_update(mut paragraph, imagelink_rel, !page.readonly)!
	// if true || fileobj.path.path.contains('today_internet') {
	// 	println(link)
	// 	println(linkout)
	// 	// println(paragraph.wiki())
	// 	println(fileobj)
	// 	println(imagelink_rel)
	// 	panic('45jhg')
	// }
	
}

// checks if external link returns 404
// if so, prompts user to replace with new link
fn (mut page Page) fix_external_link(mut link Link) ! {
	// TODO: check if external links works
	// TODO: do error if not exist
}

fn (mut page Page) fix() ! {
	page.fix_links()!
	//TODO: do includes
	if page.changed{
		println("CHANGED: $page.path")
		page.save()!
		page.changed=false
	}
}

// walk over all links and fix them with location
fn (mut page Page) fix_links() ! {
	for mut paragraph in page.doc.items.filter(it is Paragraph) {
		if mut paragraph is Paragraph {
			for mut item_link in paragraph.items {
				if mut item_link is Link {
					if item_link.isexternal {
						page.fix_external_link(mut item_link)!
					} else if item_link.cat == .image || item_link.cat == .file {
						//this will change the link
						page.link_update(mut item_link)!
					}
				}
			}
		}
	}
}

// will execute on 1 specific macro = include
fn (mut page Page) process_macro_include(content string) !string {
	mut result := []string{}
	for mut line in content.split_into_lines() {
		mut page_name_include := ''
		if line.trim_space().starts_with('{{#include') {
			page_name_include = texttools.name_fix_no_ext(line.all_after_first('#include').all_before('}}').trim_space())
		}
		// TODO: need other type of include macro format !!!include ...
		if page_name_include != '' {
			//* means we dereference, we have a copy so we can change
			mut page_include := *page.chapter.page_get(page_name_include) or {
				msg := "include:'${page_name_include}' not found for page:${page.path.path}"
				page.chapter.error(path: page.path, msg: 'include ${msg}', cat: .page_not_found)
				line = '> ERROR: ${msg}'
				continue
			}
			page_include.readonly = true // we should not save this file
			page_include.name = 'DONOTSAVE'
			page_include.path = page.path // we need to operate in path from where we include from

			line = ''
			// for line_include in page_include.doc.content.split_into_lines() {
			// 	result << line_include
			// }
			panic('implement include')
			if page_include.files_linked.len > 0 {
				page_include.fix()!
			}
		}
		if line != '' {
			result << line
		}
	}
	return result.join('\n')
}

// // will process the macro's and return string
// fn (mut page Page) process_macros() !string {
// 	mut out := page.doc.content
// 	out = page.process_macro_include(out)!
// 	return out
// }

[params]
pub struct PageSaveArgs{
pub mut:
	dest string
}

// save the page on the requested dest
// make sure the macro's are being executed
pub fn (mut page Page) save(args_ PageSaveArgs) ! {
	mut args:=args_
	if args.dest == '' {
		args.dest = page.path.path
	}
	// out := page.process_macros()!
	out := page.doc.wiki()
	mut p := pathlib.get_file(args.dest, true)!
	p.write(out)!

	// mutate page to save updated doc
	updated_doc := markdowndocs.new(path: p.path) or { panic('cannot parse,${err}') }	
	page.doc = &updated_doc
}
