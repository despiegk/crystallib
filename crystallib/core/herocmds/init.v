module herocmds

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.ui.console
import cli { Command, Flag }

pub fn cmd_init(mut cmdroot Command) {
	mut cmd_run := Command{
		name: 'init'
		description: 'init hero'
		required_args: 0
		execute: cmd_init_execute
	}

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'reset'
		abbrev: 'r'
		description: 'will reset.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'develop'
		abbrev: 'd'
		description: 'will put system in development mode.'
	})

	cmd_run.add_flag(Flag{
		flag: .bool
		required: false
		name: 'hero'
		description: 'will compile hero.'
	})

	cmdroot.add_command(cmd_run)
}

fn cmd_init_execute(cmd Command) ! {
	mut develop := cmd.flags.get_bool('develop') or { false }
	mut reset := cmd.flags.get_bool('reset') or { false }
	mut hero := cmd.flags.get_bool('hero') or { false }

	base.install()!

	if hero {
		base.hero()!
	} else if develop {
		base.develop(reset: reset)!
	}

	r := osal.profile_path_add_hero()!
	console.print_header(' add path ${r} to profile.')
	console.print_header(' hero init ok.')
}
