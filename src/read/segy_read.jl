export segy_read

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

    seisblock=[]
    for t in 1:ntraces
        offset=(indexs[t]-1)*(ns*4+240) +3600 #寻找相应的字节数
    # 寻找相应的道头index，通过index来寻找就行
        trace_start=offset
        trace_end=offset+(ns*4+240) 
        temseisblock=read_file(s, warn_user,start_byte=trace_start,end_byte=trace_end)
        if t==1
            seisblock=temseisblock
        else
            seisblock=merge([seisblock;temseisblock])
        end
    # write_trace(seekend(s), block, t)
    end
    close(s)
    seisblock=Float32(seisblock)
    return seisblock
end


function segy_read(file::AbstractString,indexs::AbstractRange,ns::Integer;buffer::Bool = false, warn_user::Bool = true)
    segy_read(file, Array(indexs),ns,buffer, warn_user)
end

function segy_read(file::AbstractString,indexs::Integer,ns::Integer;buffer::Bool = false, warn_user::Bool = true)
    segy_read(file,[indexs],ns,buffer, warn_user)
end