module docker

import freeflowuniverse.crystallib.osal { exec }
import time
import ipaddress { IPAddress }

pub enum DockerContainerStatus {
	up
	down
	restarting
	paused
	dead
	created
}

// need to fill in what is relevant
[heap]
pub struct DockerContainer {
pub mut:
	id              string
	name            string
	created         time.Time
	ssh_enabled     bool // if yes make sure ssh is enabled to the container
	ipaddr          IPAddress
	forwarded_ports []string
	mounts          []DockerContainerVolume
	ssh_port        int // ssh port on node that is used to get ssh
	ports           []string
	networks        []string
	labels          map[string]string       [str: skip]
	image           &DockerImage            [str: skip]
	engine          &DockerEngine           [str: skip]
	status          DockerContainerStatus
	memsize         int // in MB
	command         string
}

pub struct DockerContainerVolume {
	src  string // TODO: is this in container? suggest to change src -> containerpath na dest->hostpath
	dest string
}

[params]
pub struct DockerContainerCreateArgs {
	name            string
	hostname        string
	forwarded_ports []string // ["80:9000/tcp", "1000, 10000/udp"]
	mounted_volumes []string // ["/root:/root", ]
	privileged 		bool
pub mut:
	image_repo string
	image_tag  string
	command    string = '/bin/bash'
}

// create/start container (first need to get a dockercontainer before we can start)
pub fn (mut container DockerContainer) start() ! {
	exec(cmd: 'docker start ${container.id}')!
	container.status = DockerContainerStatus.up
}

// delete docker container
pub fn (mut container DockerContainer) halt() ! {
	osal.execute_stdout('docker stop ${container.id}') or { '' }
	container.status = DockerContainerStatus.down
}

// delete docker container
pub fn (mut container DockerContainer) delete() ! {
	println(' - CONTAINER DELETE: ${container.name}')

	exec(cmd: 'docker rm ${container.id} -f', stdout: false)!
	mut x := 0
	for container2 in container.engine.containers {
		if container2.name == container.name {
			container.engine.containers.delete(x)
		}
		x += 1
	}
}

// save the docker container to image
pub fn (mut container DockerContainer) save2image(image_repo string, image_tag string) !string {
	id := osal.execute_stdout('docker commit ${container.id} ${image_repo}:${image_tag}')!
	container.image.id = id.trim(' ')
	return id
}

// export docker to tgz
pub fn (mut container DockerContainer) export(path string) ! {
	exec(cmd: 'docker export ${container.id} > ${path}')!
}

// // open ssh shell to the cobtainer
// pub fn (mut container DockerContainer) ssh_shell(cmd string) ! {
// 	container.engine.node.shell(cmd)!
// }

[params]
pub struct DockerShellArgs {
pub mut:
	cmd string
}

// open shell to the container using docker, is interactive, cannot use in script
pub fn (mut container DockerContainer) shell(args DockerShellArgs) ! {
	mut cmd := ''
	if args.cmd.len == 0 {
		cmd = 'docker exec -ti ${container.id} /bin/bash'
	} else {
		cmd = "docker exec -ti ${container.id} /bin/bash -c '${cmd}'"
	}
	exec(cmd: cmd, shell: true, debug: true)!
}

pub fn (mut container DockerContainer) execute(cmd_ string, silent bool) ! {
	cmd := 'docker exec ${container.id} ${cmd_}'
	exec(cmd: cmd, stdout: !silent)!
}

// pub fn (mut container DockerContainer) ssh_enable() ! {
// 	// mut docker_pubkey := pubkey
// 	// cmd = "docker exec $container.id sh -c 'echo \"$docker_pubkey\" >> ~/.ssh/authorized_keys'"

// 	// if container.engine.node.executor is builder.ExecutorSSH {
// 	// 	mut sshkey := container.engine.node.executor.info()['sshkey'] + '.pub'
// 	// 	sshkey = os.read_file(sshkey) or { panic(err) }
// 	// 	// add pub sshkey on authorized keys of node and container
// 	// 	cmd = "echo \"$sshkey\" >> ~/.ssh/authorized_keys && docker exec $container.id sh -c 'echo \"$docker_pubkey\" >> ~/.ssh/authorized_keys && echo \"$sshkey\" >> ~/.ssh/authorized_keys'"
// 	// }

// 	// wait  making sure container started correctly
// 	// time.sleep_ms(200)
// 	// container.engine.node.executor.exec(cmd) !	
// }
