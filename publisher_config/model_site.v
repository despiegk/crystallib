module publisher_config

// import despiegk.crystallib.texttools
import despiegk.crystallib.gittools
import despiegk.crystallib.path

struct Empty {}


pub struct SiteConfig {
mut:
	repo 	   gittools.GitRepo
pub mut:
	name       string
	prefix 	   string //prefix as will be used on web, is optional
	publish_path string //path where the publishing will be done
	pull       bool // if set will pull but not reset
	reset      bool // if set will reset & pull, reset means remove changes
	cat        SiteCat
	path  	   path.Path
	domains    []string
	descr      string
	acl        []SiteACE // access control list
	trackingid string    // Matomo/Analytics
	opengraph  OpenGraph
	state 	   SiteState
	// depends []SiteDependency
	// configroot &ConfigRoot
	raw		   SiteConfigRaw
}

// pub struct SiteDependency {
// pub mut:
// 	git_url       string
// 	path        string  //path in the git repo as defined by the git_url
// 	fs_path	  string    //path as on fs, can be local to the location of this config file
// 	branch      string
// }

pub enum SiteCat {
	wiki
	data
	web
}

pub enum SiteState {
	init
	loaded
	processed
}

fn site_new(site_in SiteConfigRaw) ?SiteConfig{

	mut gt := gittools.new()

	mut sc := SiteConfig{
		name: site_in.name
		prefix: site_in.prefix
		pull: site_in.pull
		reset: site_in.reset
		domains: site_in.domains
		descr: site_in.descr
		acl: site_in.acl
		trackingid: site_in.trackingid
		opengraph: site_in.opengraph
		raw: site_in
	}

	match site_in.cat.to_lower().trim(" "){
		"web" {
			sc.cat = SiteCat.web
		}
		"wiki","" {
			sc.cat = SiteCat.wiki
		}
		"data" {
			sc.cat = SiteCat.data
		}
		else{
			return error("cannot find type of site, needs to be wiki, web or data, if undefined will be wiki")
		}
	}

	if site_in.fs_path == "" && site_in.git_url == ""{
		return error("fs_path or git_url needs to be specified in: \n$site_in")
	}

	if site_in.fs_path != ""{
		if site_in.git_url!= "" {
			return error("cannot specify fs_path and git_url in: \n$site_in")
		}
		sc.path = path.get(site_in.fs_path)
		sc.repo = gt.repo_get_from_path(sc.path.path,site_in.pull,site_in.reset) or {
			return error("cannot get repo from: $site_in.fs_path\n$err")
		}

	}
	if site_in.git_url!= ""{
		if site_in.fs_path != "" {
			return error("cannot specify fs_path and git_url in: \n$site_in")
		}
		args := gittools.RepoGetFromUrlArgs{
			url:site_in.git_url
			pull:site_in.pull
			reset:site_in.reset
		}
		sc.repo = gt.repo_get_from_url(args) or {
			return error("cannot get repo from: $site_in.git_url\n$err")
		}
		sc.path = path.get(sc.repo.path())
	}	
	return sc
}

pub fn (site SiteConfig) repo_get() gittools.GitRepo {
	if site.repo.addr.name == ""{
		panic("Cannot return repo, because was not initialized, name empty")
	}

	return site.repo

}



pub fn (site SiteConfig) reponame() string {
	mut r:= site.repo_get()
	return r.addr.name
}

pub fn (site SiteConfig) git_url() string {
	mut r:= site.repo_get()
	return r.addr.url_http_get()
}
