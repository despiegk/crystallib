module redisclient

// original code see https://github.com/patrickpissurno/vredis/blob/master/vredis_test.v
// credits see there as well (-:
import net
// import strconv
import time
import freeflowuniverse.crystallib.resp2

const default_read_timeout = net.infinite_timeout

pub struct Redis {
pub mut:
	connected bool
	socket    net.TcpConn
	addr      string
}

pub struct SetOpts {
	ex       int = -4
	px       int = -4
	nx       bool
	xx       bool
	keep_ttl bool
}

pub enum KeyType {
	t_none
	t_string
	t_list
	t_set
	t_zset
	t_hash
	t_stream
	t_unknown
}

[heap]
struct RedisFactory {
mut:
	instances map[string]Redis
}

// needed to get singleton
fn init2() RedisFactory {
	mut f := RedisFactory{}
	return f
}

// singleton creation
const factory = init2()

//make sure we reset the factory
// needed e.g. in threads
pub fn reset(){
	mut f := redisclient.factory
	f.instances =  map[string]Redis{}
	println(f.instances)
}

// https://redis.io/topics/protocol
// examples:
//   localhost:6379
//   /tmp/redis-default.sock
pub fn get(addr string) ?&Redis {
	mut f := redisclient.factory
	if  false && addr in f.instances {
		println("cache")
		mut r2 := f.instances[addr]
		return &r2
	}
	mut r := Redis{
		addr: addr
	}
	r.socket_connect()?
	f.instances[addr] = r
	return &r
}

fn (mut r Redis) socket_connect() ? {
	// println(" CONNECT TCP: ${r.addr}")
	r.socket = net.dial_tcp(r.addr)?
	r.socket.set_blocking(true)?
	r.socket.set_read_timeout(10 * time.second)
	r.socket.peer_addr()?
	r.connected = true
}

// THIS IS A WORKAROUND, not sure why we need this, shouldn't be here
fn (mut r Redis) socket_check() ? {
	r.socket.peer_addr() or {
		eprintln(' - re-connect socket for redis')
		r.socket_connect() ?
	}
}

pub fn (mut r Redis) read_line() ?string {
	return r.socket.read_line().trim_right('\r\n')
}

const cr_lf_bytes = [u8(`\r`), `\n`]

fn (mut r Redis) write_line(data []u8) ? {
	r.socket_check()?
	r.write(data)?
	r.write(redisclient.cr_lf_bytes)?
}

// write *all the data* into the socket
// This function loops, till *everything is written*
// (some of the socket write ops could be partial)
fn (mut r Redis) write(data []u8) ? {
	mut remaining := data.len
	for remaining > 0 {
		written_bytes := r.socket.write(data[data.len - remaining..])?
		remaining -= written_bytes
	}
}

// write resp2 value to the redis channel
pub fn (mut r Redis) write_rval(val resp2.RValue) ? {
	r.socket_check()?
	r.write(val.encode())?
}

// write list of strings to redis challen
fn (mut r Redis) write_cmds(items []string) ? {
	a := resp2.r_list_bstring(items)
	r.write_rval(a)?
}

fn (mut r Redis) read(size int) ?[]u8 {
	mut buf := []u8{len: size}
	mut remaining := size
	for remaining > 0 {
		read_bytes := r.socket.read(mut buf[buf.len - remaining..])?
		remaining -= read_bytes
	}
	return buf
}

pub fn (mut r Redis) disconnect() {
	r.socket.close() or {}
}
