import os
fn main(){
	args := os.args

	if args.len < 2 {
		println('commands: bur [install|update|remove]')
		return
	}
	cmd := os.args[1]
	match cmd {
		'install' { install_function()}
	}
	
}
fn install_function(name string) {
	url := 'insert when its built'

	resp := http.get(url) or {
		println('error couldnt connect to server sorry!!;')
		return
	}

	if resp.status_code != 200 {
		println('error package $name not found! 404')
		return
	}

	os.write_file('/tmp/$name.c', resp.body) or {
		println('error failed writing to tmp ')
		return
	}

	println('boringly compiling $name')

	compile_cmd := 'tcc /tmp/$name.c -o /bin/$name.elf'
	res := os.execute(compile_cmd)

	if res.exit_code == 0 {
		println('boringly compiled $name.elf run $name in your terminal to run')

		os.rm('/tmp/$name.c') or { }
	} else {
		println('oh crud $name failed to compile!')
		println(res.output)
	}
}