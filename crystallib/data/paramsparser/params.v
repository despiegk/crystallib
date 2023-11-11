module paramsparser

[heap]
pub struct Params {
pub mut:
	params []Param
	args   []string
}

pub struct Param {
pub mut:
	key     string
	value   string
	comment string
}

// get params from txt, same as parse()
pub fn new(txt string) !Params {
	return parse(txt)!
}

pub fn new_from_dict(kwargs map[string]string) !Params {
	mut p := Params{}
	for key, val in kwargs {
		p.set(key, val)
	}
	return p
}

pub fn new_params() Params {
	return Params{}
}

pub fn (mut params Params) delete(key string) {
	key2 := key.to_lower().trim_space()
	if params.exists(key) {
		mut params_out := []Param{}
		for p in params.params {
			if p.key != key2 {
				params_out << p
			}
		}
		params.params = params_out
	}
}

pub fn (mut params Params) set(key string, value string) {
	mut key2 := ''
	mut value2 := ''

	key2 = key.to_lower().trim_space()

	value2 = value.trim(" '")
	value2 = value2.replace('<<BR>>', '\n')
	value2 = value2.replace('\\n', '\n')
	value2 = value2.trim_right(' ')

	params.delete(key)
	params.params << Param{
		key: key2
		value: value2
	}
}

pub fn (mut params Params) delete_arg(key string) {
	key2 := key.to_lower().trim_space()
	if params.exists_arg(key2) {
		params.args.delete(params.args.index(key2))
	}
}

pub fn (mut params Params) set_arg(value string) {
	mut value2 := value.trim(" '")
	value2 = value2.replace('<<BR>>', '\n')
	if !params.exists_arg(value2) {
		params.args << value2
	}
}

// parse new txt as params and merge into params
pub fn (mut params Params) merge_text(txt string) ! {
	paramsnew := parse(txt)!
	for p in paramsnew.params {
		params.set(p.key, p.value)
	}
	for a in paramsnew.args {
		params.set_arg(a)
	}
}

pub fn (mut params Params) merge(params_to_merge Params) ! {
	for p in params_to_merge.params {
		params.set(p.key, p.value)
	}
	for a in params_to_merge.args {
		params.set_arg(a)
	}
}

pub fn (p Params) empty() bool {
	if p.params.len == 0 && p.args.len == 0 {
		return true
	}
	return false
}

pub fn (p Params) str() string {
	mut out := ''
	out = p.export(
		presort: ['id', 'cid', 'oid', 'name']
		postsort: ['mtime', 'ctime', 'time']
		indent: '    '
		maxcolsize: 120
		multiline: true
	)
	return out
}
