// make sure that the names are always normalized so its easy to find them back
module texttools

import os

const ignore_for_name="\\/[]()?!@#$%^&*<>:;{}|~"
const keep_ascii='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+={}[]"\':;?/>.<,|\\~` '

pub fn name_fix(name string) string {
	pagename := name_fix_keepext(name)

	if pagename.ends_with('.md') {
		fixed_pagename := pagename[0..pagename.len - 3]
		return fixed_pagename
	}
	res := pagename.clone()
	return res
}

pub fn name_clean(r string) string {
	mut res := []string{}
	for ch in r {
		mut c := ch.ascii_str()
		if ignore_for_name.contains(c){
			continue
		}
		res << c
	}
	return res.join('')
}


//remove all chars which are not ascii
pub fn ascii_clean(r string) string {
	mut res := []string{}
	for ch in r {
		mut c := ch.ascii_str()
		if keep_ascii.contains(c){
			res << c
		}		
	}
	return res.join('')
}
