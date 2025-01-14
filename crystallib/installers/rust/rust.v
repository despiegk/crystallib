module rust

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
// install rust will return true if it was already installed

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args InstallArgs) ! {
	// install rust if it was already done will return true
	console.print_header('start install rust')

	// osal.done_delete('install_rust')!

	if !args.reset && osal.done_exists('install_rust') {
		console.print_header('rust was already installed')
		return
	}

	osal.execute_stdout("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y")!

	osal.profile_path_add('${os.home_dir()}/.cargo/bin')!

	osal.done_set('install_rust', 'OK')!
	return
}
