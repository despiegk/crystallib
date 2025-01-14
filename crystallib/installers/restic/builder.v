module restic

// import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.golang
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.ui.console

const url = 'https://github.com/restic/restic'

@[params]
pub struct BuildArgs {
pub mut:
	reset    bool
	bin_push bool = true
}

// install restic will return true if it was already installed
pub fn build(args BuildArgs) ! {
	// make sure we install base on the node
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}
	golang.install()!

	// install restic if it was already done will return true
	console.print_header('build restic')

	gitpath := gittools.code_get(coderoot: '/tmp/builder', url: restic.url, reset: true, pull: true)!

	cmd := '
	source ~/.cargo/env
	cd ${gitpath}
	exit 1 #todo
	'
	osal.execute_stdout(cmd)!

	// if args.bin_push {
	// 	installers.bin_push(
	// 		cmdname: 'restic'
	// 		source: '/tmp/builder/github/threefoldtech/restic/target/x86_64-unknown-linux-musl/release/restic'
	// 	)!
	// }
}
