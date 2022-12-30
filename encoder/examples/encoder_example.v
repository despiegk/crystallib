module main

import freeflowuniverse.crystallib.encoder
import crypto.ed25519

struct AStruct{
	items []string
	nr int
	privkey []u8
}

fn do1() ! {
	mut b := encoder.encoder_new()
	a:=AStruct{
		items: ['a', 'b']
		nr: 10
		privkey: []u8{len: 5, init: u8(0xf8)}
	}
	b.add_list_string(a.items)
	b.add_int(a.nr)
	_, privkey := ed25519.generate_key()!
	b.add_bytes(privkey)

	println(b.data)
	a2:=AStruct{}
	//TODO: needs to be implemented
	// a2.items = b.get_list_string()
	// a2.nr = b.get_int()
	// a2.privkey = b.get_bytes()

	//TODO: do an assert and copy the code to the autotests
	assert a.items == a2.items
    assert a.nr == a2.nr
	assert a.privkey == a2.privkey
}

fn do2() ! {

	a:=AStruct{
		items: ['a', 'b']
		nr: 10
		privkey: []u8{len: 5, init: u8(0xf8)}
	}

	serialize_data:=encoder.encode(a)

	_ := encoder.decode[AStruct](serialize_data) or {
	eprintln('Failed to decode, error: ${err}')
	return
}



}


fn main() {
	do1() or { panic(err) }
	do2() or { panic(err) }
}


//TODO: adjust