module twinclient

struct KubernetesTestData {
mut:
	payload        K8S
	update_payload K8S
	new_worker     AddKubernetesNode
}

pub fn setup_kubernetes_test() (Client, KubernetesTestData) {
	redis_server := 'localhost:6379'
	twin_id := 73
	mut client := init(redis_server, twin_id) or {
		panic('Fail in setup_kubernetes_test with error: $err')
	}

	mut data := KubernetesTestData{
		payload: K8S{
			name: 'essamkube'
			secret: 'essam1234'
			network: Network{
				ip_range: '10.201.0.0/16'
				name: 'essamkubenet'
			}
			masters: [
				KubernetesNode{
					name: 'master1'
					node_id: 3
					cpu: 1
					memory: 1024
					rootfs_size: 10
					disk_size: 15
					public_ip: false
					planetary: true
				},
			]
			description: 'This is trial from V client to deploy kubernetes'
			ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8a/m3Bm94bVc10EB5lhn0c+AZYVDYv5a/hLvufI+00mdvXIJ+F32FnBlgtJ5aVNIeAlwQ7BZG6OfVwobead43zf0GYkoF3Q4OZmu7J9uDetIT5+wZH6e8W7HAAaqIKbwyF/KJItFH50sXOtYms2QnQExnJw/lx57d1x1noQkv8Xqu1hF5F0Nt3TDPAyB20qOVgiUrQ2pz1CuvUPDhHVCT8JBP0v0MKme+aqwcKruxNm8UuqQevP828guLS4UL1HMrTzO5cCoH9pSaEU95ZIME5EHOop9zmEUaxGP4UcFAHHYpJTMkkjWVf5rK4p/KAsCG4vD1xMLqhbHVYi7opd5yErrL3qNECyt9ZzGMmh8Zj8ib4WeGbcCjN1JKVix8kPo2ZDFvlcGNHcFxSv/Q8WaQLmk3URnLT0DUwTz0dk89QVnbRy0Q4D++j0j4nV9cbP/Ow/uC4hAENxf8GwSO7jtExHzXYTGYvbDN7izEy0Z+kT/X+cNwj9Q1rRV3Hj1dTtyEB18kqcGfsPGXcmM7C6I0LcMBTu7TBOgwrGQr6f+kjegxAiEAGlJQnYBpbgpyA4Yor6j2mzFnSHyKJDtIvaxTkhWIhZREvEXHtp0qZ3wx0L29L3+Z6JuCGs7+r/k2O3cAPynkxGVjLjR+b7mBUJ+rQuW+XnTRe6frsQCHp7ZO1w== mohammedelborolossy@gmail.com'
		}
	}
	data.update_payload = K8S{
		...data.payload
		metadata: 'kubernetes'
	}
	data.new_worker = AddKubernetesNode{
		deployment_name: data.payload.name
		name: 'worker1'
		node_id: 2
		cpu: 1
		memory: 1024
		rootfs_size: 10
		disk_size: 15
		public_ip: false
		planetary: true
	}

	return client, data
}

pub fn test_deploy_kubernetes() {
	mut client, data := setup_kubernetes_test()

	println('--------- Deploy K8S ---------')
	new_kube := client.deploy_kubernetes(data.payload) or { panic(err) }
	println(new_kube)
}

pub fn test_list_kubernetes() {
	mut client, data := setup_kubernetes_test()

	println('--------- List Deployed K8S ---------')
	all_my_kubes := client.list_kubernetes() or { panic(err) }
	assert data.payload.name in all_my_kubes
	println(all_my_kubes)
}

pub fn test_get_kubernetes() {
	mut client, data := setup_kubernetes_test()

	println('--------- Get K8S ---------')
	get_kube := client.get_kubernetes(data.payload.name) or { panic(err) }
	println(get_kube)
}

pub fn test_update_kubernetes() {
	mut client, data := setup_kubernetes_test()

	println('--------- Update K8S ---------')
	new_kube := client.update_kubernetes(data.update_payload) or { panic(err) }
	println(new_kube)
}

pub fn test_add_worker() {
	mut client, data := setup_kubernetes_test()

	println('--------- Add Worker ---------')
	add_worker_result := client.add_worker(data.new_worker) or { panic(err) }
	println(add_worker_result)
}

pub fn test_delete_worker() {
	mut client, data := setup_kubernetes_test()

	delete_worker_result := client.delete_worker(
		name: data.new_worker.name
		deployment_name: data.payload.name
	) or { panic(err) }
	println('--------- Delete Worker ---------')
	println(delete_worker_result)
}

pub fn test_delete_kubernetes() {
	mut client, data := setup_kubernetes_test()

	println('--------- Delete K8S ---------')
	delete_kube := client.delete_kubernetes(data.payload.name) or { panic(err) }
	println(delete_kube)
}
