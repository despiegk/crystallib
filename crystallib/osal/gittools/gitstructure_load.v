module gittools

import os
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
// import time

// the factory for getting the gitstructure
// git is checked uderneith $/code
fn (mut gitstructure GitStructure) load() ! {
	// print_backtrace()
	// if true{panic("s")}
	gitstructure.repos.clear()
	mut done := []string{}
	// path which git repos will be recursively loaded
	git_path := gitstructure.rootpath
	if !(os.exists(gitstructure.rootpath.path)) {
		os.mkdir_all(gitstructure.rootpath.path)!
	}
	gitstructure.load_recursive(git_path.path, mut done)!
	for mut repo in gitstructure.repos {
		repo.status()!
		// println(repo)
	}
}

fn (mut gitstructure GitStructure) reload() ! {
	// print_backtrace()
	// if true{panic("s")}
	gitstructure.repos.clear()
	mut done := []string{}
	// path which git repos will be recursively loaded
	git_path := gitstructure.rootpath
	if !(os.exists(gitstructure.rootpath.path)) {
		os.mkdir_all(gitstructure.rootpath.path)!
	}
	gitstructure.load_recursive(git_path.path, mut done)!
	for mut repo in gitstructure.repos {
		repo.load()!
	}
}

// fn (mut gitstructure GitStructure) reload() ! {
// 	gitstructure.repos.clear()
// 	gitstructure.cache_reset()!
// 	mut done := []string{}
// 	// path which git repos will be recursively loaded
// 	git_path := gitstructure.rootpath
// 	if !(os.exists(gitstructure.rootpath.path)) {
// 		os.mkdir_all(gitstructure.rootpath.path)!
// 	}
// 	gitstructure.load_recursive(git_path.path, mut done)!
// 	for mut repo in gitstructure.repos {		
// 		// println(" - ${repo.addr}")
// 		repo.load()!
// 		// repo.status()!
// 		println(repo)
// 	}
// }

// // internal function to be executed in thread
// fn repo_refresh(addr GitAddr, path string) {
// 	repo_load(addr, path) or { panic(err) }
// 	// console.print_header(' thread done: ${path}')
// 	// println(" ==== ${addr.name}")
// 	// r.load() or {panic(err)}
// }

// pub fn (mut gs GitStructure) reload() ! {

// 	mut done := []string{}
// 	gs.load_recursive(gs.rootpath.path, mut done)!
// 	// mut threads := []thread{}
// 	for mut repo in gs.repos {
// 		// threads<<spawn repo_refresh(repo.addr,repo.path.path)
// 		repo_load(repo.addr,repo.path.path)!
// 		repo.status()!
// 	}
// 	// println(" - wait for threads")
// 	// time.sleep(time.Duration(time.second)*10)
// 	// threads.wait()
// 	// console.print_header(' all repo refresh jobs finished.')
// }

fn (mut gitstructure GitStructure) load_recursive(path1 string, mut done []string) ! {
	// console.print_debug("gs load: $path1")
	path1o := pathlib.get(path1)
	relpath := path1o.path_relative(gitstructure.rootpath.path)!
	if relpath.count('/') > 4 {
		return
	}

	items := os.ls(path1) or {
		return error('cannot load gitstructure because cannot find ${path1}')
	}
	mut pathnew := ''
	for item in items {
		pathnew = os.join_path(path1, item)
		if os.is_dir(pathnew) {
			if os.exists(os.join_path(pathnew, '.git')) {
				mut repo := gitstructure.repo_from_path(pathnew)!
				gitstructure.repos << &repo
				continue
			}
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}
			gitstructure.load_recursive(pathnew, mut done)!
		}
	}
}
