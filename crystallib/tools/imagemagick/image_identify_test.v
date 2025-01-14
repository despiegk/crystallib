import freeflowuniverse.crystallib.tools.imagemagick { image_new }
import freeflowuniverse.crystallib.core.pathlib
import os

const testpath = os.dir(@FILE) + '/example'

fn test_identify_verbose() {
	mut img_path := pathlib.get('${testpath}/small_png.png')
	mut image := image_new(mut img_path) or { panic('Cannot get new image:\n ${err}') }
	println('1st ${image}')
	assert image.size_x == 0
	assert image.size_y == 0

	image.identify() or { panic('Cannot identify image:\n ${err}') }

	assert image.size_x == 960
	assert image.size_y == 540
	assert image.transparent == false

	// TODO: test with more images
}
