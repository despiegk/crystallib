module markdowndocs


fn test_link1() {
	mut docs:=new(content:'[Architecture](architecture/architecture.md)')!

	println(docs)
	

	r:=markdowndocs.Paragraph{
		content: '[Architecture](architecture/architecture.md)'
		items: [markdowndocs.ParagraphItem(markdowndocs.Link{
			content: '[Architecture](architecture/architecture.md)'
			cat: .page
			isexternal: false
			include: true
			newtab: false
			moresites: false
			description: 'Architecture'
			url: 'architecture/architecture.md'
			filename: 'architecture.md'
			path: 'architecture'
			site: ''
			extra: ''
			state: .ok
			error_msg: ''
		})]
		changed: false
	}
	// assert r == docs
	panic('s')
}

// fn test_link2() {
// 	mut lp := LinkParseResult{}
// 	mut para := Paragraph{}
// 	lp = para.link_parser('[Architecture](@*!architecture/architecture.md)') or { panic(err) }

// 	correct_lp := LinkParseResult{
// 		links: [
// 			Link{
// 				content: '[Architecture](@*!architecture/architecture.md)'
// 				cat: .page
// 				isexternal: false
// 				include: true
// 				newtab: true
// 				moresites: true
// 				description: 'Architecture'
// 				url: ''
// 				filename: 'architecture.md'
// 				path: 'architecture'
// 				site: ''
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 		]
// 	}
// 	assert lp.str() == correct_lp.str()
// }

// fn test_link3() {
// 	mut lp := LinkParseResult{}
// 	mut para := Paragraph{}
// 	lp = para.link_parser('[AArchitecture](@*!architecture.md)') or { panic(err) }

// 	assert lp.str() == LinkParseResult{
// 		links: [
// 			Link{
// 				content: '[AArchitecture](@*!architecture.md)'
// 				cat: .page
// 				isexternal: false
// 				include: true
// 				newtab: true
// 				moresites: true
// 				description: 'AArchitecture'
// 				url: ''
// 				filename: 'architecture.md'
// 				path: ''
// 				site: ''
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 		]
// 	}.str()
// }

// fn test_link4() {
// 	mut lp := LinkParseResult{}
// 	mut para := Paragraph{}
// 	lp = para.link_parser("[AArchitecture](./img/license_threefoldfzc.png ':size=800x900')") or {
// 		panic(err)
// 	}

// 	assert lp.str() == LinkParseResult{
// 		links: [
// 			Link{
// 				content: "[AArchitecture](./img/license_threefoldfzc.png ':size=800x900')"
// 				cat: .image
// 				isexternal: false
// 				include: true
// 				newtab: false
// 				moresites: false
// 				description: 'AArchitecture'
// 				url: ''
// 				filename: 'license_threefoldfzc.png'
// 				path: 'img'
// 				site: ''
// 				extra: "':size=800x900'"
// 				state: .ok
// 				error_msg: ''
// 			},
// 		]
// 	}.str()
// }

// fn test_link5() {
// 	mut lp := LinkParseResult{}
// 	mut para := Paragraph{}
// 	lp = para.link_parser('[Architecture](@*!testsite:architecture/architecture.md)') or {
// 		panic(err)
// 	}

// 	assert lp.str() == LinkParseResult{
// 		links: [
// 			Link{
// 				content: '[Architecture](@*!testsite:architecture/architecture.md)'
// 				cat: .page
// 				isexternal: false
// 				include: true
// 				newtab: true
// 				moresites: true
// 				description: 'Architecture'
// 				url: ''
// 				filename: 'architecture.md'
// 				path: 'architecture'
// 				site: 'testsite'
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 		]
// 	}.str()
// }

// fn test_link6() {
// 	mut lp := LinkParseResult{}
// 	mut para := Paragraph{}
// 	lp = para.link_parser('[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)') or {
// 		panic(err)
// 	}

// 	correct_lp := LinkParseResult{
// 		links: [
// 			Link{
// 				content: '[Architecture](https://library.threefold.me/info/threefold#/technology/threefold__technology?ee=dd)'
// 				cat: .html
// 				isexternal: true
// 				include: true
// 				newtab: false
// 				moresites: false
// 				description: 'Architecture'
// 				url: ''
// 				filename: ''
// 				path: ''
// 				site: ''
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 		]
// 	}
// 	// direct object comparison fails, so compare strings
// 	assert lp.str() == correct_lp.str()
// }

// fn test_link7() {
// 	mut lp := LinkParseResult{}
// 	mut para := Paragraph{}
// 	lp = para.link_parser('
// 		hi [Architecture](mysite:new/newer.md) is something else [Something](yes/start.md) 
// 		line
// 		 [Something](yes/start.md) 
// 	') or {
// 		panic(err)
// 	}

// 	correct_lp := LinkParseResult{
// 		links: [
// 			Link{
// 				content: '[Architecture](mysite:new/newer.md)'
// 				cat: .page
// 				isexternal: false
// 				include: true
// 				newtab: false
// 				moresites: false
// 				description: 'Architecture'
// 				url: ''
// 				filename: 'newer.md'
// 				path: 'new'
// 				site: 'mysite'
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 			Link{
// 				content: '[Something](yes/start.md)'
// 				cat: .page
// 				isexternal: false
// 				include: true
// 				newtab: false
// 				moresites: false
// 				description: 'Something'
// 				url: ''
// 				filename: 'start.md'
// 				path: 'yes'
// 				site: ''
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 			Link{
// 				content: '[Something](yes/start.md)'
// 				cat: .page
// 				isexternal: false
// 				include: true
// 				newtab: false
// 				moresites: false
// 				description: 'Something'
// 				url: ''
// 				filename: 'start.md'
// 				path: 'yes'
// 				site: ''
// 				extra: ''
// 				state: .ok
// 				error_msg: ''
// 			},
// 		]
// 	}

// 	assert lp.str() == correct_lp.str()
// }
