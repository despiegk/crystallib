module encoder

import time
import math

fn test_string() {
	mut e := encoder.encoder_new()
	e.add_string('a')
	e.add_string('bc')
	assert e.data == [e.version, 1, 0, 97, 2, 0, 98, 99]

	mut d := encoder.decoder_new(e.data)
	assert d.get_string() == 'a'
	assert d.get_string() == 'bc'
}

fn test_int() {
	mut e := encoder.encoder_new()
	e.add_int(math.min_i32)
	e.add_int(math.max_i32)
	assert e.data == [e.version, 0x00, 0x00, 0x00, 0x80, 0xff, 0xff, 0xff, 0x7f]

	mut d := encoder.decoder_new(e.data)
	assert d.get_int() == math.min_i32
	assert d.get_int() == math.max_i32
}

fn test_bytes() {
	sb := 'abcdef'.bytes()

	mut e := encoder.encoder_new()
	e.add_list_u8(sb)
	assert e.data == [e.version, 6, 0, 97, 98, 99, 100, 101, 102]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_u8() == sb
}

fn test_u8() {
	mut e := encoder.encoder_new()
	e.add_u8(math.min_u8)
	e.add_u8(math.max_u8)
	assert e.data == [e.version, 0x00, 0xff]

	mut d := encoder.decoder_new(e.data)
	assert d.get_u8() == math.min_u8
	assert d.get_u8() == math.max_u8
}

fn test_u16() {
	mut e := encoder.encoder_new()
	e.add_u16(math.min_u16)
	e.add_u16(math.max_u16)
	assert e.data == [e.version, 0x00, 0x00, 0xff, 0xff]

	mut d := encoder.decoder_new(e.data)
	assert d.get_u16() == math.min_u16
	assert d.get_u16() == math.max_u16
}

fn test_u32() {
	mut e := encoder.encoder_new()
	e.add_u32(math.min_u32)
	e.add_u32(math.max_u32)
	assert e.data == [e.version, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff]

	mut d := encoder.decoder_new(e.data)
	assert d.get_u32() == math.min_u32
	assert d.get_u32() == math.max_u32
}

fn test_u64() {
	mut e := encoder.encoder_new()
	e.add_u64(math.min_u64)
	e.add_u64(math.max_u64)
	assert e.data == [e.version, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]

	mut d := encoder.decoder_new(e.data)
	assert d.get_u64() == math.min_u64
	assert d.get_u64() == math.max_u64
}

fn test_time() {
	mut e := encoder.encoder_new()
	t := time.now()
	e.add_time(t)

	mut d := encoder.decoder_new(e.data)
	assert d.get_time() == t
}

fn test_list_string() {
	list := ['a', 'bc', 'def']

	mut e := encoder.encoder_new()
	e.add_list_string(list)
	assert e.data == [e.version, 3, 0, 1, 0, 97, 2, 0, 98, 99, 3, 0, 100, 101, 102]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_string() == list
}

fn test_list_int() {
	list := [0x872fea95, 0, 0xfdf2e68f]

	mut e := encoder.encoder_new()
	e.add_list_int(list)
	assert e.data == [e.version, 3, 0, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_int() == list
}

fn test_list_u8() {
	list := [u8(153), 0, 22]

	mut e := encoder.encoder_new()
	e.add_list_u8(list)
	assert e.data == [e.version, 3, 0, 153, 0, 22]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_u8() == list
}

fn test_list_u16() {
	list := [u16(0x8725), 0, 0xfdff]

	mut e := encoder.encoder_new()
	e.add_list_u16(list)
	assert e.data == [e.version, 3, 0, 0x25, 0x87, 0, 0, 0xff, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_u16() == list
}

fn test_list_u32() {
	list := [u32(0x872fea95), 0, 0xfdf2e68f]

	mut e := encoder.encoder_new()
	e.add_list_u32(list)
	assert e.data == [e.version, 3, 0, 0x95, 0xea, 0x2f, 0x87, 0, 0, 0, 0, 0x8f, 0xe6, 0xf2, 0xfd]

	mut d := encoder.decoder_new(e.data)
	assert d.get_list_u32() == list
}

fn test_map_string() {
	mp := {
		'1': 'a'
		'2': 'bc'
	}
	
	mut e := encoder.encoder_new()
	e.add_map_string(mp)
	assert e.data == [e.version, 2, 0, 1, 0, 49, 1, 0, 97, 1, 0, 50, 2, 0, 98, 99]

	mut d := encoder.decoder_new(e.data)
	assert d.get_map_string() == mp
}

fn test_map_bytes() {
	mp := {
		'1': 'a'.bytes()
		'2': 'bc'.bytes()
	}
	
	mut e := encoder.encoder_new()
	e.add_map_bytes(mp)
	assert e.data == [e.version, 2, 0, 1, 0, 49, 1, 0, 0, 0, 97, 1, 0, 50, 2, 0, 0, 0, 98, 99]

	mut d := encoder.decoder_new(e.data)
	assert d.get_map_bytes() == mp
}

struct AStruct{
	a string
	b int
	c u8
	d u16
	e u32
	f u64
	g time.Time
	h []string
	i []int
	j []u8
	k []u16
	l []u32
	m map[string]string
	n map[string][]u8
	child BStruct
}

struct BStruct{
	n int
}

fn test_struct() {
	input := AStruct{
		a: 'a'
		b: int(-1)
		c: u8(2)
		d: u16(3)
		e: u32(4)
		f: u64(5)
		g: time.now()
		h: ['a', 'b']
		i: []int{len: 3, init: it}
		j: []u8{len: 3, init: u8(it)}
		k: []u16{len: 3, init: u16(it)}
		l: []u32{len: 3, init: u32(it)}
		m: {'1': 'a', '2': 'b'}
		n: {'1': 'a'.bytes(), '2': 'b'.bytes()}
		child: BStruct{ n: 10 }
	}

	data := encoder.encode(input)!
	println(data)

	output := encoder.decode[AStruct](data) or {
		eprintln('Failed to decode, error: ${err}')
		return
	}

	assert input == output
}