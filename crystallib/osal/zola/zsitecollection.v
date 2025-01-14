module zola

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.osal
// import log
// import os

// TODO: the idea is we can also pull in parts of websites in one mother website e.g. for blogs, just like we do for wiki

pub struct ZSiteCollection {
pub mut:
	site       &ZSite       @[skip; str: skip]
	name       string
	url        string
	reset      bool
	pull       bool
	gitrepokey string
	path       pathlib.Path
}

@[params]
pub struct ZSiteCollectionArgs {
pub mut:
	name string
	url  string
}

pub fn (mut b ZSite) collection_add(args_ ZSiteCollectionArgs) ! {
	mut args := args_
	mut c := ZSiteCollection{
		url: args.url
		name: args.name
		site: &b
	}
	b.collections << c
}

pub fn (mut self ZSiteCollection) prepare() ! {
	console.print_header(' zola collection prepare: ${self.url}')
	mut gs := self.site.zola.gitstructure
	mut locator := gs.locator_new(self.url)!
	mut repo := gs.repo_get(locator: locator, reset: false, pull: false)!
	self.site.zola.gitrepos[repo.key()] = repo
	self.gitrepokey = repo.key()
	self.path = locator.path_on_fs()!
	self.path.link('${self.site.path_build.path}/src/${self.name}', true)!
}
