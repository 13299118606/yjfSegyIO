export segy_read,segy_trange

"""
block = segy_read(file::String)
"""
function segy_read(file::AbstractString; buffer::Bool = true, warn_user::Bool = true)
    println("read")
    if buffer
        s = IOBuffer(read(open(file)))
    else
        s = open(file)
    end

    seisblock=read_file(s, warn_user)
    seisblock=Float32(seisblock)
end


"""
block = segy_read(file::String, keys::Array{String,1})
"""
function segy_read(file::AbstractString, keys::Array{String,1}; buffer::Bool = true, warn_user::Bool = true)
    
    if buffer
        s = IOBuffer(read(open(file)))
    else
        s = open(file)
    end

    seisblock=read_file(s, keys, warn_user)
    seisblock=Float32(seisblock)
end

"""
block = segy_read(file::String, indexs::Array{Int,1})
"""
function segy_read(file::AbstractString, indexs::Array{Int,1},ns::Integer;buffer::Bool = false, warn_user::Bool = true)

    if buffer
        s = IOBuffer(read(open(file)))   #读数据道缓冲区，可以read 
    else
        s = open(file)
    end

    ntraces = size(indexs,1)

    # 寻找相应的道头index，通过index来寻找就行
    # 
   
    seisblock= SeisBlock(Float32.(zeros(ns,ntraces)))



    # ############按每道读取，太慢 修改分级别读取
    # ll=Int(floor(ntraces/20))
    # for t in 1:ntraces
    #     offset=(indexs[t]-1)*(ns*4+240) +3600 #寻找相应的字节数
    # # 寻找相应的道头index，通过index来寻找就行
    #     trace_start=offset
    #     trace_end=offset+(ns*4+240) 
    #     if ll!=0 && rem(t,ll)==0
    #         # println("trace_start:",trace_start," "," trace_start:",trace_end,"  每次读取的道数(若不为1可能出现错误) ",(trace_end - trace_start)/(ns*4+240))
    #         # println("  每次读取的道数(若不为1可能出现错误) ",(trace_end - trace_start)/(ns*4+240))
    #         println("读取道数:",t,"/",ntraces,"  ", t*100/ntraces,"%")
    #     end
    #     temseisblock=read_file(s, warn_user,start_byte=trace_start,end_byte=trace_end)
    #     seisblock.traceheaders[t,:]=temseisblock.traceheaders
    #     # println(size(temseisblock.data))
    #     seisblock.data[:,t]=temseisblock.data
    #     seisblock.fileheader=temseisblock.fileheader
    # write_trace(seekend(s), block, t)
    # end
    #############按片段读取
    result = split_continuous(indexs)
    nresult=length(result)
    lk=Int(floor(nresult/10))
    println("按片块读取数据...")
    for tt in 1: nresult
        trace_start=result[tt][1]
        trace_end=result[tt][end]
        offset=(trace_start-1)*(ns*4+240) +3600 
        trace_start_bit=offset
        trace_end_bit=offset+(trace_end-trace_start+1)*(ns*4+240) 
        temseisblock=read_file(s, warn_user,start_byte=trace_start_bit,end_byte=trace_end_bit)
        trace_start_index=findfirst(isequal(trace_start),indexs)
        trace_last_index=findlast(isequal(trace_end),indexs)
        # println("trace_start_index: ",trace_start_index,"trace_last_index: ",trace_last_index)
        seisblock.traceheaders[trace_start_index:trace_last_index]=temseisblock.traceheaders #要下标而不是值
        seisblock.data[:,trace_start_index:trace_last_index]=temseisblock.data
        seisblock.fileheader=temseisblock.fileheader
        temseisblock=nothing
        if lk!=0 && rem(tt,lk)==0
            println("读取道数:",trace_start_index,"/",ntraces,"  ", trace_start_index*100/ntraces,"%")
        end
    end
    seisblock=Float32(seisblock)
    # println(indexs[5])
    # println(seisblock.data[200:210,5]) #显示第10道 前1000数值
    # println(indexs[5000])
    # println(seisblock.data[200:210,5000]) #显示5000道
    return seisblock
end


function segy_read(file::AbstractString,indexs::AbstractRange,ns::Integer;buffer::Bool = false, warn_user::Bool = true)
    segy_read(file, Array(indexs),ns,buffer=buffer, warn_user=warn_user)
end

function segy_read(file::AbstractString,indexs::Integer,ns::Integer;buffer::Bool = false, warn_user::Bool = true)
    segy_read(file,[indexs],ns,buffer=buffer, warn_user=warn_user)
end



function segy_trange( block::SeisBlock,trange::AbstractRange) #单位为ms
    tranges=collect(trange)
    tranges=Int.(tranges)
    trangesorig=collect(block.traceheaders[1].DelayRecordingTime:block.traceheaders[1].DelayRecordingTime+block.fileheader.bfh.ns) #以后遇见问题再扩展，比如单位 目前单位为ms
    
    index_zs=findfirst(x -> x ==tranges[1], trangesorig):findlast(x -> x == tranges[end], trangesorig)
    # index_zs= findall(x -> x in tranges, trangesorig) #作用相等，这个少遍历,省时间
    newblock=SeisBlock(block.data[index_zs,:]) 
    newblock.fileheader = deepcopy(block.fileheader)
    newblock.traceheaders = copy(block.traceheaders)
    set_header!(newblock, "ns", length(index_zs))
    set_header!(newblock, :DelayRecordingTime,tranges[1])
    return newblock
end
