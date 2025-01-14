module mdbook

import freeflowuniverse.crystallib.osal
import os
// import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.play

@[heap]
pub struct MDBook {
	play.Base
pub mut:
	books        &MDBooks           @[skip; str: skip]
	name         string
	url          string
	path_build   pathlib.Path
	path_publish pathlib.Path
	collections  []MDBookCollection
	gitrepokey   string
	title        string
	initdone     bool
}

@[params]
pub struct MDBookArgs {
pub mut:
	name  string @[required]
	title string
	url   string @[required] // url of the summary.md file
}

pub fn (mut books MDBooks) book_new(args MDBookArgs) !&MDBook {
	path_build := '${books.path_build}/${args.name}'
	path_publish := '${books.path_publish}/${args.name}'

	mut book := MDBook{
		name: args.name
		url: args.url
		title: args.title
		path_build: pathlib.get_dir(path: path_build, create: true)!
		path_publish: pathlib.get_dir(path: path_publish, create: true)!
		books: &books
	}

	mut gs := books.gitstructure
	mut locator := gs.locator_new(book.url)!
	mut repo := gs.repo_get(locator: locator, reset: false, pull: false)! // don't pull this happens later
	books.gitrepos[repo.key()] = repo
	book.gitrepokey = repo.key()

	books.books << &book

	return &book
}

// only executes at init time
fn (mut book MDBook) clone() ! {
	for mut c in book.collections {
		c.clone()!
	}
}

pub fn (mut book MDBook) edit() ! {
	console.print_header('edit book: ${book.name}')
	cmd := 'code \'${book.path_build.path}/src\''
	console.print_debug(cmd)
	osal.exec(cmd: cmd)!
}

pub fn (mut book MDBook) open() ! {
	console.print_header('open book: ${book.name}')
	cmd := 'open \'${book.path_build.path}/book/index.html\''
	console.print_debug(cmd)
	// cmd:='bash ${book.path_build.path}/develop.sh'
	osal.exec(cmd: cmd)!
}

fn (mut book MDBook) prepare() ! {
	mut gs := book.books.gitstructure
	mut locator := gs.locator_new(book.url)!
	mut path_summary_dir := locator.path_on_fs()!
	mut path_summary := path_summary_dir.file_get_ignorecase('summary.md')!
	os.mkdir_all('${book.path_build.path}/src')!
	path_summary.link('${book.path_build.path}/src/SUMMARY.md', true)!
	console.print_header(' mdbook summary: ${path_summary.path}')
	book.template_install()!
	console.print_header(' mdbook prepared: ${book.path_build.path}')
}

pub fn (mut book MDBook) generate() ! {
	// TODO: uncomment when fixed
	// if book.changed() == false {
	// 	return
	// }
	console.print_header(' book generate: ${book.name} on ${book.path_build.path}')

	if book.initdone == false {
		book.books.init()!
	}

	// write the css files
	for item in book.books.embedded_files {
		if item.path.ends_with('.css') {
			css_name := item.path.all_after_last('/')
			// osal.file_write('${html_path.trim_right('/')}/css/${css_name}', item.to_string())!

			dpath := '${book.path_publish.path}/css/${css_name}'
			// console.print_stdout(' templ ${dpath}')
			mut dpatho := pathlib.get_file(path: dpath, create: true)!
			dpatho.write(item.to_string())!
		}
	}
	book.summary_image_set()!
	osal.exec(
		cmd: '	
				cd ${book.path_build.path}
				mdbook build --dest-dir ${book.path_publish.path}'
		retry: 0
	)!
}

fn (mut book MDBook) template_install() ! {
	if book.title == '' {
		book.title = book.name
	}

	// get embedded files to the mdbook dir
	for item in book.books.embedded_files {
		dpath := '${book.path_build.path}/${item.path.all_after_first('/')}'
		// console.print_debug(' embed: ${dpath}')
		mut dpatho := pathlib.get_file(path: dpath, create: true)!
		dpatho.write(item.to_string())!
	}

	c := $tmpl('template/book.toml')
	mut tomlfile := book.path_build.file_get_new('book.toml')!
	tomlfile.write(c)!

	c1 := $tmpl('template/build.sh')
	mut file1 := book.path_build.file_get_new('build.sh')!
	file1.write(c1)!
	file1.chmod(0o770)!

	c2 := $tmpl('template/develop.sh')
	mut file2 := book.path_build.file_get_new('develop.sh')!
	file2.write(c2)!
	file2.chmod(0o770)!
}

fn (mut book MDBook) summary_image_set() ! {
	// this is needed to link the first image dir in the summary to the src, otherwise empty home image

	summaryfile := '${book.path_build.path}/src/SUMMARY.md'
	mut p := pathlib.get_linked_file(path: summaryfile)!
	c := p.read()!
	mut first := true
	for line in c.split_into_lines() {
		if !(line.trim_space().starts_with('-')) {
			continue
		}
		if line.contains('](') && first {
			folder_first := line.all_after('](').all_before_last(')')
			folder_first_dir_img := '${book.path_build.path}/src/${folder_first.all_before_last('/')}/img'
			// println(folder_first_dir_img)
			// if true{panic("s")}
			if os.exists(folder_first_dir_img) {
				mut image_dir := pathlib.get_dir(path: folder_first_dir_img)!
				image_dir.copy(dest: '${book.path_build.path}/src/img')!
			}

			first = false
		}
	}
}

// all the gitrepo keys
fn (mut book MDBook) gitrepo_keys() []string {
	mut res := []string{}
	res << book.gitrepokey
	for collection in book.collections {
		if collection.gitrepokey !in res {
			res << collection.gitrepokey
		}
	}
	return res
}

// is there change in repo since last build?
fn (mut book MDBook) changed() bool {
	mut change := false
	gitrepokeys := book.gitrepo_keys()
	for key, status in book.books.gitrepos_status {
		if key in gitrepokeys {
			// means this book is using that gitrepo, so if it changed the book changed
			if status.revlast != status.revlast {
				change = true
			}
		}
	}
	return change
}
