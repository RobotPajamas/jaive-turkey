#import "uv";
#import "Basic";
#import "File";

logfile: File;
stdin_pipe: uv_pipe_t;
stdout_pipe: uv_pipe_t;

read_stdin :: (stream: *uv_stream_t, nread: s64, buf: *uv_buf_t) #c_call {
    push_context {
        // TODO: Log not flushing without this?
        logfile, _ = file_open("./jaive-turkey.log", for_writing=true, keep_existing_content=true);
        defer file_close(*logfile);
        file_write(*logfile, buf.base, nread);
    }
        
}

alloc_buffer :: (handle: *uv_handle_t, suggested_size: u64, buf: *uv_buf_t) #c_call {
    push_context {
        // TODO: If talloc fails, libuv handles that with an error, should we do something here?
        buf.base = talloc(xx suggested_size);
        buf.len = suggested_size;
    }
}

main :: () {
    logfile, _ = file_open("./jaive-turkey.log", for_writing=true, keep_existing_content=false);
    if !file_write(*logfile, "main | Starting server \n") {
        print("main | Failed to write file\n");
    }
    // file_close(*logfile);

    uv_pipe_init(uv_default_loop(), *stdin_pipe, 0);
    uv_pipe_open(*stdin_pipe, 0);
    
    uv_pipe_init(uv_default_loop(), *stdout_pipe, 0);
    uv_pipe_open(*stdout_pipe, 1);

    uv_read_start(xx *stdin_pipe, alloc_buffer, read_stdin);
    defer uv_loop_close(uv_default_loop());
    defer print("Deferring print about server closing");

    uv_run(uv_default_loop(), .UV_RUN_DEFAULT);
    print("Closing server...");
}
