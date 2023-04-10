export write_trace

function write_trace(s::IO, block::SeisBlock, t::Int)
    
    ##000
    # Write Header
    pos_trace_start = position(s)
    if block.fileheader.bfh.DataSampleFormat == 5
        for field in fieldnames(typeof(block.traceheaders[t]))
            write(s, bswap(getfield(block.traceheaders[t], field)))
        end
    
    elseif block.fileheader.bfh.DataSampleFormat == 1
        for field in fieldnames(typeof(block.traceheaders[t]))
            write(s, getfield(block.traceheaders[t], field))
        end
    end


    ##240
    pos_trace_240=position(s)

    # Write trace
    if block.fileheader.bfh.DataSampleFormat == 5
        write(s, bswap.(Float32.(block.data[:, t])))
    elseif block.fileheader.bfh.DataSampleFormat == 1  #IBMFloat32
        write(s, Float32.(block.data[:, t]))
    end
    pos_trace_end=position(s)
    
end
