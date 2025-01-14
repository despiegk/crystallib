import freeflowuniverse.crystallib.threefold.gridproxy
import freeflowuniverse.crystallib.threefold.gridproxy.model

fn get_gateway_nodes_example() ! {
	mut gp_client := gridproxy.get(.dev, true)!
	gw_nodes := gp_client.get_gateways(status: 'up')!
	println(gw_nodes)
}

fn get_gateway_by_id_example(id u64) ! {
	mut gp_client := gridproxy.get(.dev, true)!
	// get_gateway_by_id fetchs specific gateway information by node id.
	node_gateway := gp_client.get_gateway_by_id(id)!
	println(node_gateway)
}

fn get_gateway_iterator_example() ! {
	mut gp_client := gridproxy.get(.dev, true)!

	// gateway_iterator
	max_page_iteration := u64(5) // set maximum pages to iterate on

	mut gw_iterator := gp_client.get_gateways_iterator(status: 'up')

	mut iterator_available_gw := []model.Node{}
	for {
		if gw_iterator.filter.page is u64 && gw_iterator.filter.page >= max_page_iteration {
			break
		}

		iterator_nodes := gw_iterator.next()
		if iterator_nodes != none {
			iterator_available_gw << iterator_nodes
		} else {
			break // if the page is empty the next function will return none
		}
	}

	println(iterator_available_gw)
}

fn main() {
	get_gateway_nodes_example()!
	get_gateway_by_id_example(u64(11))!
	get_gateway_iterator_example()!
}
