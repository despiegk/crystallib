

module main

import appsbox.redisapp


fn do()?{
	mut app := redisapp.get(port:7777)
	app.build()?
}

fn main() {
	do() or {panic(err)}

}
