module playbook

import freeflowuniverse.crystallib.data.paramsparser

@[params]
pub struct FilterSortArgs {
pub:
	priorities map[int]string // filter and give priority
}

// filter parser based on the criteria
//```
// string for filter is $actor:$action, ... name and globs are possible (*,?)
//
// struct FilterSortArgs {
// 	 priorities  map[int]string //filter and give priority
//```
// the action_names or actor_names can be a glob in match_glob .
// see https://modules.vlang.io/index.html#string.match_glob .
// the highest priority will always be chosen . (it can be a match happens 2x)
// return  []Action
pub fn (mut plbook PlayBook) filtersort(args FilterSortArgs) ! {
	mut nrs := args.priorities.keys()
	nrs.sort()
	for prio in nrs {
		argsfilter := args.priorities[prio] or { panic('bug') }
		mut actionsfound := plbook.find(filter: argsfilter)!
		// console.print_header('- ${prio}:(${actionsfound.len})\n${argsfilter}")
		for mut actionfiltered in actionsfound {
			if actionfiltered.id in plbook.done {
				continue
			}
			actionfiltered.priority = prio
			if prio !in plbook.priorities {
				plbook.priorities[prio] = []int{}
			}
			if actionfiltered.id !in plbook.done {
				plbook.priorities[prio] << actionfiltered.id
				plbook.done << actionfiltered.id
			}
		}
	}
}

@[params]
pub struct FindArgs {
pub:
	filter       string
	include_done bool
}

// filter is of form $actor.$action, ... name and globs are possible (*,?) .
// comma separated, actor and name needs to be specified, if more than one use * glob .
// e.g. find("core.person_select,myactor.*,green*.*")
pub fn (mut plbook PlayBook) find(args FindArgs) ![]&Action {
	filter := args.filter.replace(':', '.').trim_space()
	mut res := []&Action{}
	mut items := []string{}
	if filter.contains(',') {
		items = filter.split(',').map(it.trim_space())
	} else {
		items << filter.trim_space()
	}
	for action in plbook.actions {
		// println("${action.actor}:${action.name}:${action.id}")
		if action.match_items(items) {
			// println(" OK")
			if !args.include_done && action.done {
				continue
			}
			res << action
		}
	}
	return res
}

pub fn (mut plbook PlayBook) find_by_name(args ActionGetArgs) ![]&Action {
	return plbook.find(filter: '${args.actor}.${args.name}')
}

fn (action Action) match_items(items []string) bool {
	for p in items {
		mut actor := ''
		mut name := ''
		if p.contains('.') {
			actor = p.all_before('.').trim_space()
			name = p.all_after_last('.').trim_space()
		} else {
			name = p.trim_space()
			actor = 'core'
		}
		// console.print_header('- checkmatch:${actor}:${name}")
		if action.checkmatch(actor: actor, name: name) {
			return true
		}
	}
	return false
}

@[params]
pub struct MatchFilter {
pub mut:
	actor string
	name  string
	cid   string
}

// check if the action matches following the filter args .
// the action_names or actor_names can be a glob in match_glob .
// see https://modules.vlang.io/index.html#string.match_glob
fn (action Action) checkmatch(args MatchFilter) bool {
	if args.cid.len > 0 {
		if args.cid != action.cid {
			return false
		}
	}
	if args.actor.len > 0 {
		if args.actor.contains('*') || args.actor.contains('?') || args.actor.contains('[') {
			if !action.actor.match_glob(args.actor) {
				return false
			}
		} else {
			if action.actor != args.actor.to_lower().trim_space() {
				return false
			}
		}
	}
	if args.name.len > 0 {
		if args.name.contains('*') || args.name.contains('?') || args.name.contains('[') {
			if !action.name.match_glob(args.name) {
				return false
			}
		} else {
			if action.name != args.name.to_lower().trim_space() {
				return false
			}
		}
	}
	return true
}

// find all relevant parser, return the params out of one .
// filter is of form $actor.$action, ... name and globs are possible (*,?) .
// comma separated, actor and name needs to be specified, if more than one use * glob .
// e.g. find("core.person_select,myactor.*,green*.*")
pub fn (mut plbook PlayBook) params_get(filter string) !paramsparser.Params {
	mut paramsresult := paramsparser.new('')!
	for action in plbook.find(filter: filter)! {
		paramsresult.merge(action.params)!
	}
	return paramsresult
}
