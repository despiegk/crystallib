module docgen

import v.doc
import v.pref
import freeflowuniverse.crystallib.jsonschema
import freeflowuniverse.crystallib.openrpc {OpenRPC, Method}
import freeflowuniverse.crystallib.codemodel {Struct, Function}
import freeflowuniverse.crystallib.codeparser

// configuration parameters for OpenRPC Document generation.
[params]
pub struct DocGenConfig {
	title string // Title of the JSON-RPC API
	description string // Description of the JSON-RPC API
	version string = '1.0.0' // OpenRPC Version used
	source string // Source code directory to generate doc from
	strict bool // Strict mode generates document for only methods and struct with the attribute `openrpc`
	exclude_dirs []string // directories to be excluded when parsing source for document generation
	exclude_files []string // files to be excluded when parsing source for document generation
}

// docgen generates OpenRPC Document struct for JSON-RPC API defined in the config params.
// returns generated OpenRPC struct which can be encoded into json using `openrpc.OpenRPC.encode()`
pub fn docgen(config DocGenConfig) !OpenRPC {
	$if debug {
		eprintln('Generating OpenRPC Document from path: $config.source')
	}

	code := codeparser.parse_v(
		config.source,
		exclude_dirs: config.exclude_dirs
		exclude_files: config.exclude_files
	)!
	mut schemas := map[string]jsonschema.SchemaRef{}
	mut methods := []openrpc.Method{}

	for struct_ in code.filter(it is Struct).map(it as Struct) {
		schema := jsonschema.struct_to_schema(struct_)
		schemas[struct_.name] = schema
	}

	for function in code.filter(it is Function).map(it as Function) {
		method := fn_to_method(function)
		methods << method
	}

	return OpenRPC {
		info: openrpc.Info {
			title: config.title
			version: config.version
		}
		methods: methods
		components: openrpc.Components {
			schemas: schemas
		}
	}
}

fn fn_to_method(function codemodel.Function) Method {
	$if debug {
		eprintln('Converting function to method: $function.name')
		// println('comments: $function.comments')
	}

	params := params_to_descriptors(function.params)
	result_schema := jsonschema.typesymbol_to_schema(function.result.typ.symbol)
	result_name := if function.result.name != '' {
		function.result.name
	} else {
		function.result.typ.symbol
	}

	result := openrpc.ContentDescriptor {
		name: result_name
		schema: result_schema
		description: function.result.description
	}

	return openrpc.Method{
		name: function.name
		params: params
		result: result
	}
}

// get_param_descriptors takes in a list of params
// returns content descriptors for the params
fn params_to_descriptors(params []codemodel.Param) []openrpc.ContentDescriptorRef {
	
	mut descriptors := []openrpc.ContentDescriptorRef{}

	for param in params {
		schemaref := jsonschema.typesymbol_to_schema(param.typ.symbol)
		descriptors << openrpc.ContentDescriptorRef(openrpc.ContentDescriptor{
			name: param.name
			schema: schemaref
			description: param.description
		})
	}

	return descriptors
}