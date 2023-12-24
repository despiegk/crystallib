module mdbook

import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.osal
// import log
// import os

// is playbook for one specific book
pub struct MDBookCollection {
pub mut:
	book       &MDBook      @[skip; str: skip]
	name       string
	url        string
	reset      bool
	pull       bool
	gitrepokey string
	path       pathlib.Path
}

@[params]
pub struct MDBookCollectionArgs {
pub mut:
	name string
	url  string
}

pub fn (mut book MDBook) playbook_add(args_ MDBookCollectionArgs) ! {
	mut args := args_
	mut c := MDBookCollection{
		url: args.url
		name: args.name
		book: &book
	}
	c.clone()! // don't pull if it exists
	book.playbooks << c
}

fn (mut self MDBookCollection) clone() ! {
	println(' - mdbook playbook clone no pull: ${self.url}')
	mut gs := self.book.books.gitstructure
	mut locator := gs.locator_new(self.url)!
	mut repo := gs.repo_get(locator: locator, reset: false, pull: false)! // here no reset will be done later
	self.book.books.gitrepos[repo.key()] = repo
	self.gitrepokey = repo.key()
	self.path = locator.path_on_fs()!
	// Question: is this a good place to link playbooks
	self.link()!

	// self.path.link('${self.book.path_build.path}/src/${self.name}', true)!
	// println(srcpath)
	// println(' - mdbook playbook: ${srcpath}')
}

fn (mut self MDBookCollection) link() ! {
	println(' - link playbook: ${self.path.path} -> ${self.book.path_build.path}/src/${self.name}')
	self.path.link('${self.book.path_build.path}/src/${self.name}', true)!
	// println(' - mdbook playbook: ${srcpath}')
	// panic('link playbook')
}