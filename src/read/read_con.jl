export read_con

"""
Use:   read_con(con::SeisCon; 
                blocks::Array{Int,1} = Array(1:length(con)),
                prealloc_traces::Int = 50000)

Read 'blocks' out of 'con' into a preallocated array of size (ns x prealloc_traces).

If preallocated memory fills, it will be expanded again by 'prealloc_traces'.
"""
function read_con(con::SeisCon, blocks::Array{Int,1}; 
                                prealloc_traces::Int = 60000)
    nblocks = length(blocks)
    if maximum(blocks)>length(con) @error "Call for block $(maximum(blocks)) in a container with $(length(con)) blocks." end

    # Check dsf
    datatype = Float32
    if con.dsf == 1
        datatype = IBMFloat32
    elseif con.dsf != 5
        @error "Data type not supported ($(fh.bfh.DataSampleFormat))"
    end

    # Pre-allocate 改了也没用 还是50000道
    data = Array{datatype,2}(undef, con.ns, prealloc_traces) 
    # println(size(data))
    headers = zeros(BinaryTraceHeader, prealloc_traces)
    fh = FileHeader()
    set_fileheader!(fh.bfh, :ns, con.ns)
    set_fileheader!(fh.bfh, :DataSampleFormat, con.dsf)

    trace_count = 0
    # Read all blocks
    for block in blocks
        # Check size of next block and pass view to pre-alloc
        brange = con.blocks[block].endbyte - con.blocks[block].startbyte  #4244,也就是每个块每个道的最大的数其实就是ns*4+240
        ntraces = Int((brange)/(240 + con.ns*4))
        # println("开始字节数:",con.blocks[block].startbyte," 结尾字节数:",con.blocks[block].endbyte," 读取范围大小:",brange," 每次读取道数量:",ntraces)
        # Check if there is room in pre-alloc'd mem
        isroom = (trace_count + ntraces) <= length(headers)
        if ~isroom
            println("Expanding preallocated memory")
            prealloc_traces *= 2
            data = hcat(data, Array{datatype,2}(undef, con.ns, ntraces+prealloc_traces))
            append!(headers, zeros(BinaryTraceHeader, ntraces+prealloc_traces))
        end
        #大型数据用view，也就是共享内存而不是复制，是返回临时数据
        tmp_data = view(data, :,(trace_count+1):(trace_count+ntraces))

        tmp_headers = view(headers, (trace_count+1):(trace_count+ntraces)) 

        # Read the next block #如何确保不是一个文件,如果都相同就会打开文件太多错误
        read_block!(con.blocks[block], con.ns, con.dsf, tmp_data, tmp_headers)
        trace_count += ntraces
    end

    return SeisBlock{datatype}(fh, headers[1:trace_count], data[:,1:trace_count])
    
end

function read_con(con::SeisCon, keys::Array{String,1}, blocks::Array{Int,1};
                                prealloc_traces::Int = 50000)
    nblocks = length(blocks)

    # Check dsf
    datatype = Float32
    if con.dsf == 1
        datatype = IBMFloat32
    elseif con.dsf != 5
        @error "Data type not supported ($(fh.bfh.DataSampleFormat))"
    end

    # Check for RecSrcScalar
    in("RecSourceScalar", keys) ? nothing : push!(keys, "RecSourceScalar")

    # Pre-allocate
    data = Array{datatype,2}(undef, con.ns, prealloc_traces) 
    headers = zeros(BinaryTraceHeader, prealloc_traces)
    fh = FileHeader(); set_fileheader!(fh.bfh, :ns, con.ns)
    set_fileheader!(fh.bfh, :DataSampleFormat, con.dsf)

    trace_count = 0
    # Read all blocks
    for block in blocks
        
        # Check size of next block and pass view to pre-alloc
        brange = con.blocks[block].endbyte - con.blocks[block].startbyte
        ntraces = Int((brange)/(240 + con.ns*4))

        # Check if there is room in pre-alloc'd mem
        isroom = (trace_count + ntraces) <= length(headers)
        if ~isroom
            println("Expanding preallocated memory")
            data = hcat(data, Array{datatype,2}(undef, con.ns, ntraces+prealloc_traces))
            append!(headers, zeros(BinaryTraceHeader, ntraces+prealloc_traces))
            prealloc_traces *= 2
        end
        tmp_data = view(data, :,(trace_count+1):(trace_count+ntraces))
        tmp_headers = view(headers, (trace_count+1):(trace_count+ntraces)) 

        # Read the next block
        read_block!(con.blocks[block], keys, con.ns, con.dsf, tmp_data, tmp_headers)
        trace_count += ntraces
    end

    return SeisBlock{datatype}(fh, headers[1:trace_count], data[:,1:trace_count])
    
end

# RANGES & INT
function read_con(con::SeisCon, blocks::TR;
                  prealloc_traces::Int = 50000) where {TR<:AbstractRange}
    read_con(con, Array(blocks), prealloc_traces = prealloc_traces)
end
function read_con(con::SeisCon, blocks::Integer;
                  prealloc_traces::Int = 50000)
    read_con(con, [blocks], prealloc_traces = prealloc_traces)
end
function read_con(con::SeisCon, keys::Array{String,1}, blocks::TR;
                  prealloc_traces::Int = 50000) where {TR<:AbstractRange}
    read_con(con, keys, Array(blocks), prealloc_traces = prealloc_traces)
end
function read_con(con::SeisCon, keys::Array{String,1}, blocks::Integer;
                  prealloc_traces::Int = 50000)
    read_con(con, keys, [blocks], prealloc_traces = prealloc_traces)
end

