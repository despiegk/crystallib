module paramsparser

import freeflowuniverse.crystallib.core.texttools

enum ParamStatus {
	start
	name // found name of the var (could be an arg)
	value_wait // wait for value to start (can be quote or end of spaces and first meaningful char)
	value // value started, so was no quote
	quote // quote found means value in between ''
	comment
}

// convert text with e.g. color:red or color:'red' to arguments
// multiline is supported
// result is params object which allows you to query the info you need
// params is following:
//
// struct Params {
// 	params []Param
// 	args   []Arg
// }
// struct Arg {
// 	value string
// }
// struct Param {
// 	key   string
// 	value string
// }
// it has nice methods to query the params
pub fn parse(text string) !Params {
	mut text2 := texttools.dedent(text)
	// mut text2 := text
	// println("****PARSER")
	// println(text2)
	// println("****PARSER END")
	text2 = texttools.multiline_to_single(text2)!
	text2 = text2.replace("\"","'")
	// println(text2)
	// println("1")
	validchars := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_,./'

	mut ch := ''
	mut ch_prev := ''
	mut state := ParamStatus.start
	mut result := Params{}
	mut key := ''
	mut value := ''
	mut comment := ''

	for i in 0 .. text2.len {
		ch = text2[i..i + 1]
		// println(" - '${ch_prev}${ch}' ${state}")
		// check for comments end
		if state == .start {
			if ch == ' ' {
				ch_prev = ch
				continue
			}

			state = .name
		}
		if state == .name {
			if ch_prev == '/' && ch == '/' {
				// we are now comment
				state = .comment
				ch_prev = ch
				continue
			}

			if ch == ' ' && key == '' {
				ch_prev = ch
				continue
			}
			// waiting for :
			if ch == ':' {
				state = ParamStatus.value_wait
				ch_prev = ch
				continue
			} else if ch == ' ' {
				state = ParamStatus.start
				result.set_arg_with_comment(key, comment)
				key = ''
				comment = ''
				value = ''
				ch_prev = ch
				continue
			} else if !validchars.contains(ch) {
				return error("text to params processor: parameters can only be A-Za-z0-9 and _., found illegal char: '${key}${ch}' in\n${text2}\n\n")
			} else {
				key += ch
				ch_prev = ch
				continue
			}
		}
		if state == .value_wait {
			if ch == "'" {
				state = .quote
				ch_prev = ch
				continue
			}
			// means the value started, we can go to next state
			if ch != ' ' {
				state = .value
			}
		}
		if state == .value {
			if ch == ' ' {
				state = .start
				result.set_with_comment(key, value, comment)
				key = ''
				value = ''
				comment = ''
			} else {
				value += ch
			}
			ch_prev = ch
			continue
		}
		if state == .quote {
			if ch == "'" {
				state = .start
				result.set_with_comment(key, value, comment)
				key = ''
				value = ''
				comment = ''
			} else {
				value += ch
			}
			ch_prev = ch
			continue
		}

		if state == .value || state == ParamStatus.start {
			if ch == '/' && ch_prev == '/' {
				// we are now comment
				state = .comment
			}
		}

		if state == ParamStatus.comment {
			if ch == '/' && ch_prev == '-' {
				state = .start
				ch_prev = ch
				continue
			}
			comment += ch
		}

		ch_prev = ch
	}

	// last value
	if state == ParamStatus.value || state == ParamStatus.quote {
		result.set_with_comment(key, value, comment)
	}

	if state == ParamStatus.name {
		if key != '' {
			result.set_arg_with_comment(key, comment)
		}
	}

	return result
}
