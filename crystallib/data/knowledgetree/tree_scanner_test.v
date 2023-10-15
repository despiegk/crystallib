module knowledgetree

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.params
import os

const (
	collections_path = os.dir(@FILE) + '/testdata/collections'
	tree_name        = 'mdbook_test_tree'
	book1_path       = os.dir(@FILE) + '/testdata/book1'
	book1_dest       = os.dir(@FILE) + '/testdata/_book1'
)

fn test_scan() ! {
	mut tree := new()!
	tree.scan(
		path: knowledgetree.collections_path
		heal: false
	)!

	// mut c := tree.collection_get('solution')!

	// assert c.page_exists('grant')
	// assert c.page_exists('grant3') == false
	// assert c.image_exists('centralized_internet.jpg')
	// assert c.image_exists('centralized_internet_.jpg')
	// mut i := c.image_get('centralized_internet_.jpg')!
	// println(i)
	// assert c.image_exists('duplicate_centralized_internet.jpg')
	// assert c.image_exists('duplicate_centralized_internets_.jpg') == false

	// mut page := c.page_get('casperlabs_deployment')!
	// mut page2 := c.page_get('casperlabs_Deployment')!
	// assert page == page2
}