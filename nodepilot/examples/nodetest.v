module main

import freeflowuniverse.crystallib.nodepilot

fn main() {
	nodeip := "300:c282:7f31:4aa4:7af6:297:a65a:28f4"

	mut n := nodepilot.nodepilot_new("kds1", nodeip)?
	n.prepare()?
}
