module yjfSegyIO
    export test
    # export test1
    test(str::String) = str * " 是否存在测试函数，输出表示可修改，且成功."
    # test1() = " 是否存在测试函数，输出表示可修改，且成功."
    myRoot = dirname(dirname(pathof(yjfSegyIO)))
    CHUNKSIZE = 2048
    TRACE_CHUNKSIZE = 512
    MB2B = 1024^2

    # what's being used
    using Distributed
    using Printf
    using GR
    
    # 自己添加
    include("methods/split_continuous.jl")
    #Types
    
    include("types/IBMFloat32.jl")
    include("types/BinaryFileHeader.jl")
    include("types/BinaryTraceHeader.jl")
    include("types/FileHeader.jl")
    include("types/SeisBlock.jl")
    include("types/BlockScan.jl")
    include("types/SeisCon.jl")
    include("types/Float32.jl")

    #Reader
    include("read/read_fileheader.jl")
    include("read/read_traceheader.jl")
    include("read/read_trace.jl")
    include("read/read_file.jl")
    include("read/segy_read.jl")
    include("read/read_block.jl")
    include("read/read_block_headers.jl")
    include("read/read_con.jl")
    include("read/read_con_headers.jl")
    include("read/extract_con_headers.jl")

    # Writer
    include("write/write_fileheader.jl")
    include("write/segy_write.jl")
    include("write/segy_change.jl")
    include("write/segy_write_append.jl")
    include("write/check_fileheader.jl")
    include("write/write_trace.jl")

    # Scanner
    include("scan/scan_file.jl")
    include("scan/segy_scan.jl")
    include("scan/scan_chunk.jl")
    include("scan/scan_block.jl")
    include("scan/scan_shots.jl")
    include("scan/delim_vector.jl")
    include("scan/find_next_delim.jl")

    # Workspace
    th_b2s = yjfSegyIO.th_byte2sample()
    blank_th = BinaryTraceHeader()

    # Methods
    include("methods/ordered_pmap.jl")
    include("methods/merge.jl")
    include("methods/split.jl")
    include("methods/set_header.jl")
    include("methods/get_header.jl")
    include("methods/get_sources.jl")
    include("methods/get_box_indexs.jl")

end # module
