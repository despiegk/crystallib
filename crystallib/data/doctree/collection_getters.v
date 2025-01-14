module doctree

import freeflowuniverse.crystallib.core.texttools

pub fn (tree Tree) playbooknames() []string {
	mut res := []string{}
	for _, playbook in tree.playbooks {
		res << playbook.name
	}
	res.sort()
	return res
}

pub struct CollectionNotFound {
	Error
pub:
	pointer Pointer
	msg     string
}

pub fn (err CollectionNotFound) msg() string {
	if err.msg.len > 0 {
		return err.msg
	}
	return '"Cannot find playbook ${err.pointer} in tree.\n}'
}

pub fn (tree Tree) playbook_exists(name string) bool {
	namelower := texttools.name_fix(name)
	if namelower in tree.playbooks {
		return true
	}
	return false
}

// internal function
fn (tree Tree) playbook_get_from_pointer(p Pointer) !Collection {
	if p.tree.len > 0 && p.tree != tree.name {
		return CollectionNotFound{
			pointer: p
			msg: 'tree name was not empty and was not same as tree.\n${p}'
		}
	}
	mut ch := tree.playbooks[p.playbook] or { return CollectionNotFound{
		pointer: p
	} }
	return *ch
}

pub fn (tree Tree) playbook_get(name string) !Collection {
	name_fixed := texttools.name_fix(name)
	return tree.playbook_get_from_pointer(Pointer{ playbook: name_fixed })!
}
