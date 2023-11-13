module mdsite

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.mdsite
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.data.ourtime
import time
import v.embed_file

[heap]
pub struct Zola {
pub mut:
	sites []&ZSite  [skip; str: skip]
	path pathlib.Path 
	gitrepos map[string]gittools.GitRepo
	coderoot string
	gitstructure gittools.GitStructure  [skip; str: skip]
	embedded_files  []embed_file.EmbedFileData [skip; str: skip]

}

[params]
pub struct ZolaArgs {
pub mut:
	path string [required]
	coderoot string
	install bool = true
}


pub fn new(args ZolaArgs)!Zola{
	if args.install{
		mdsite.install()!
	}	
	mut gs := gittools.get(coderoot:args.coderoot)!
	mut sites:=Zola{
		path:pathlib.get_dir(path:args.path,create:true)!
		coderoot:args.coderoot
		gitstructure: gs
	}
	// sites.init()! // initialize mdsites embed logic
	return sites
}


// fn (mut tree Zola) init() ! {
// 	tree.embedded_files << $embed_file('template/css/print.css')
// 	tree.embedded_files << $embed_file('template/css/variables.css')
// 	tree.embedded_files << $embed_file('template/css/general.css')
// 	tree.embedded_files << $embed_file('template/mermaid-init.js')
// 	tree.embedded_files << $embed_file('template/echarts.min.js')
// 	tree.embedded_files << $embed_file('template/mermaid.min.js')
// }

pub struct ToDo{
pub mut:
	key string
	rev string
}

pub fn (mut self Zola) check()!{
	println(self)
	mut todo:=[]ToDo{}
	for key,repo_ in self.gitrepos{
		mut repo:=repo_
		repo.pull_reset()!	
		rev:=repo.rev()!
		lastrev:=osal.done_get("mdsiterev_${key}") or {""}
		// println("lastrev:$lastrev")
		// println("newrev:$rev")
		if lastrev!=rev{
			todo<<ToDo{key:key,rev:rev}
		}
	}
	//now we know which repo's changed
	for todoitem in todo{
		for mut site in self.sites{
			println(" - site check: ${site.name}")
			mut changed:=false
			if site.gitrepokey == todoitem.key{
				changed=true
			}
			for collection in site.collections{
				if collection.gitrepokey == todoitem.key{
					changed=true
				}
			}
			// println(changed)
			if changed{
				site.generate()!
				osal.done_set("mdsiterev_${todoitem.key}",todoitem.rev)!
				lastrev:=osal.done_get("mdsiterev_${todoitem.key}") or {""}
				// println("lastrev set:$lastrev")				
			}
		}
	}
}


[params]
pub struct WatchArgs {
pub mut:
	period int = 300 //5 min default
}
pub fn (mut self Zola) watch(args WatchArgs){
	mut t:=ourtime.now()
	mut last:=i64(0)
	for {		
		t.now()
		println("${t} ${t.unix_time()} period:${args.period}")
		if t.unix_time() > last + args.period{
			println(" - will try to check the mdsites")
			self.check() or {" - ERROR: couldn't check the repo's.\n$err"}
			last=t.unix_time()
		}		
		time.sleep(time.second)
	}

}
