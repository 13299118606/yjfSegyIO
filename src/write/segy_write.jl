export segy_write

function segy_write(file::String, block::SeisBlock)
    # Open buffer for writing
    s = open(file, "w")
    segy_write(s, block)
    close(s)
end

function segy_write(s::IO, block::SeisBlock)
    # Write FileHeader
    write_fileheader(s, block.fileheader)

    # Write Data
    ns, ntraces = size(block.data)
    ll=Int(floor(ntraces/20))
    for t in 1:ntraces
        if ntraces<=10
            println("写入中....",t/ntraces*100," %")
        else
            if ll!=0&&rem(t, ll)==0
                println("写入中....",t,"/",ntraces,"      ",t/ntraces*100," %")
            end
        end
        write_trace(s, block, t)
    end
end
