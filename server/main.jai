#import "uv";
#import "Basic";
#import "File";
String :: #import "String";
Jaison :: #import "jaison";

LOG_TO_FILE :: true;

logfile: File;
stdin_pipe: uv_pipe_t;
stdout_pipe: uv_pipe_t;

read_stdin :: (stream: *uv_stream_t, nread: s64, buf: *uv_buf_t) #c_call {
    data: string = ---;
    data.data = buf.base;
    data.count = xx nread;

    push_context {
        // TODO: Ignoring Content-Type, as it's usually default
        found, header, content := String.split_from_left(data, "\r\n\r\n");
        if !found {
            return;
        }

        results := String.split(header, ": ");
        if results[0] != "Content-Length" {
            return;
        }

        // TODO: Should we be using the content_length or the content.count? Ideally the same-ish if well formed?
        content_length := string_to_int(results[1]);
        assert(content_length == content.count);
        
        success, request := Jaison.json_parse_string(content, RequestMessage, ignore_unknown=true);
        if !success {
            return;
        }

        #if LOG_TO_FILE {
            // TODO: Log not flushing without this?
            logfile, _ = file_open("./jaive-turkey.log", for_writing=true, keep_existing_content=true);
            defer file_close(*logfile);
            file_write(*logfile, tprint("%, %, %\n", nread, data.count, content.count));
            file_write(*logfile, tprint("%, \n", request));
            file_write(*logfile, header);
            file_write(*logfile, content.data, content_length);
            file_write(*logfile, content.data, content_length);
        }

        if request.method == {
            case "initialize";
                response := InitializeResponseMessage.{
                    id = request.id
                };
                response_content := Jaison.json_write_string(response,, temp);
                // TODO: Use the correct libuv writers/buffers
                print("Content-Length: %\r\n\r\n%", response_content.count, response_content);
                #if LOG_TO_FILE {
                    logfile, _ = file_open("./jaive-turkey.log", for_writing=true, keep_existing_content=true);
                    // defer file_close(*logfile);
                    file_write(*logfile, tprint("Content-Length: %\r\n\r\n%", response_content.count, response_content));
                }
        }

        
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


Message :: struct {
    jsonrpc: string = "2.0";    
}

RequestMessage :: struct {
    using base: Message;
    id: u32;
    method: string;
}

ResponseMessage :: struct {
    using base: Message;
    id: u32;
}

Notification :: struct {
    using base: Message;
    method: string;
}

InitializeRequestMessage :: struct {
    using request: RequestMessage;
    params: struct {
        clientInfo: struct {
            name: string;
            version: string;
        };
    }
}

InitializeResponseMessage :: struct {
    using response: ResponseMessage;
    result: struct {
        capabilities: struct {

        };
        serverInfo: struct {
            name: string = "jaive-turkey";
            version: string = "0.0.0";
        };
    }
}
