/*
 *    ░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
 *    ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
 *    ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
 *    ░▒▓███████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░  
 *    ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
 *    ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
 *    ░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░ 
 *    ascii art from: https://patorjk.com/software/taag/ :)                     
 */

import os
import net.http

fn main() {
    args := os.args

    if args.len < 2 {
        println('commands: bur [install|update|upgrade|remove]')
        return
    }

    cmd := args[1]

    match cmd {
        'install' {
            if args.len < 3 {
                println('error: please provide a package name')
                return
            }
            install_function(args[2])
        }
        'update' {
            update_function()
        }
        'upgrade' {
            if args.len < 3 {
                println('error: please provide a package name')
                return
            }
            upgrade_function(args[2])
        }
        else {
            println('commands: bur [install|update|upgrade|remove]')
        }
    }
}

fn install_function(name string) {
    url := 'needtoadd' + name + '.c'

    resp := http.get(url) or {
        println('error couldnt connect to server sorry!!')
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

fn update_function() {
    println('checking mirror for upds')

    manifest_url := 'https://inserthis/manifest.txt'
    resp := http.get(manifest_url) or {
        println('sorry could not reach the server')
        return
    }
    
    if resp.status_code != 200 {
        println('error failed to fetch the package list')
        return
    }

    os.mkdir_all('/var/db/bur/') or { }
    os.write_file('/var/db/bur/manifest.txt', resp.body) or {
        println('failed to save manifest :(')
        return
    }
    println('done! packge list refreshed run bur upgrade [name] to see if it needs a upd')
}

fn upgrade_function(name string) {
    hash_url := 'https://inserthis/' + name + '.hash'
    resp := http.get(hash_url) or { 
        println('error: could not check remote hash')
        return 
    }
    remote_hash := resp.body.trim_space()

    hash_path := '/var/db/bur/' + name + '.hash'
    if os.exists(hash_path) {
        local_hash := os.read_file(hash_path) or { '' }.trim_space()

        if local_hash == remote_hash {
            println('$name is latest version not upgrading')
            return
        }
    }

    println('new version of $name found upgrading now')
    install_function(name)
    
    os.mkdir_all('/var/db/bur/') or { }
    os.write_file(hash_path, remote_hash) or { }
}

fn remove_function(name string) {
    if name == '' {
        println('hey say a package to remove!')
        return
    }

    println('removing $name play the bugle ;_;')

    executable_path:= '/bin/$name.elf'
    if os.exists(executable_path) {
        os.rm(executable_path) or {
            println('oh crud could not remove the binary')
        }
    } else {
        println('HEY $name.elf was not found in /bin/!')
    }

    hash_path := '/var/db/bur' + name + '.hash'
    if os.exists(hash_path) {
        os.rm(hash_path) or { }
    }

    println('rip $name it has been removed')    
}

//yello this is the bottom of the file