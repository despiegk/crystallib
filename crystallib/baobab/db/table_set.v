module db

import freeflowuniverse.crystallib.data.ourtime

// gid smartid.GID
// objtype string //unique type name for obj class
// index_int map[string]int
// index_string map[string]string
// data []u8
fn table_set(mut db DB, mut args DBSetArgs) ! {
	_, setstatements := table_set_statements(mut db, mut args)!
	db.sqlitedb.exec(setstatements)!

	// for now we just replace the data, but eventually will keep history and do content addressed
	datastr := args.data.str()
	mut datasql := 'INSERT OR REPLACE INTO data (cid,oid,data) VALUES (${args.gid.cid.u32()},${args.gid.oid()},\'${datastr}\');'
	db.sqlitedb.exec(datasql)!
}

fn table_set_statements(mut db DB, mut args DBSetArgs) !(string, string) {
	if args.objtype.len == 0 {
		return error('objtype needs to be specified')
	}
	now := ourtime.now()
	tablename := table_name(db, args.objtype)
	mut tosetitems := ['cid', 'oid', 'mtime']
	mut tosetvals := [args.gid.cid.u32().str(), args.gid.oid().str(),
		now.unix_time().str()]
	for key, val in args.index_int {
		tosetitems << '${key}'
		tosetvals << val.str()
	}
	for key, val in args.index_string {
		tosetitems << '${key}'
		tosetvals << "'${val}'"
	}
	tosetitemsstr := tosetitems.join(',').trim_right(',')
	tosetvalsstr := tosetvals.join(',').trim_right(',')

	mut setstatements := 'INSERT OR REPLACE INTO ${tablename} (${tosetitemsstr}) VALUES (${tosetvalsstr});'

	return tablename, setstatements
}
