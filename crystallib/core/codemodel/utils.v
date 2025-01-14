module codemodel

pub struct GetStruct {
	code []CodeItem
	mod  string
	name string
}

pub fn get_struct(params GetStruct) ?Struct {
	structs_ := params.code.filter(it is Struct).map(it as Struct)
	structs := structs_.filter(it.name == params.name)
	if structs.len == 0 {
		return none
	} else if structs.len > 1 {
		panic('Multiple structs with same name found. This should never happen.')
	}
	return structs[0]
}

pub fn inflate_types(mut code []CodeItem) {
	for mut item in code {
		if item is Struct {
			// TODO: handle this when refactoring types / structs

			inflate_struct_fields(code, mut item)
		}
	}
}

pub fn inflate_struct_fields(code []CodeItem, mut struct_ CodeItem) {
	for mut field in (struct_ as Struct).fields {
		// TODO: fix inflation for imported types
		if field.typ.symbol.starts_with_capital() {
			field.structure = get_struct(
				code: code
				name: field.typ.symbol
			) or { continue }
		}
	}
}
