module books
import freeflowuniverse.crystallib.installers.mdbook

//open the development tool and the browser to show the book you are working on
pub fn (site Site) mdbook_develop() ? {	
	mdbook.install()?
	mut gt := gittools.get(root: '')?
	mut repo := gt.repo_get_from_url(url: 'https://github.com/threefoldfoundation/books/tree/main/template/books/template')?
	template_dir = dest_repo.path_content_get()	

	//check the installer

	//book folder: /tmp/mdbooks/$name/book
	//todo: copy template info to the folder which represents the book

	// we use template to set the .toml...
	// we create export.sh (run) and develop.sh
	// copy the theme

	//call the command to to development
}



//export an mdbook to its html representation
pub fn (site Site) mdbook_export(path string) ? {	
	//
}