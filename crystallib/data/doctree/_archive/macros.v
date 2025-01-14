module doctree

// import freeflowuniverse.crystallib.baobab.spawner

pub enum MacroResultState {
	ok
	error
	stop
}

pub struct MacroResult {
pub mut:
	result string
	error  string
	state  MacroResultState
}

pub interface IMacroProcessor {
mut:
	// spawner &spawner.Spawner
	process(code string) !MacroResult
}
