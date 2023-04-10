export segy_change

function segy_change(file::String, block::SeisBlock,indexs::AbstractVector )

    # Open buffer for writing
    s = open(file, "r+")

    # Write FileHeader  #主要检查3200-3600的二进制文件头是否一样，只有文件头一样才可以合并和改变
    check_fileheader(s, block.fileheader)
    pos = position(s) #查看位置
    println("开始改写地震数据....",pos)

    # println("开始写地震数据....",pos)
    # Write Data
    ns,ntraces = size(block.data)
    # 寻找相应的道头index，通过index来寻找就行
    # 

    ll=floor(ntraces/20)

    for t in 1:ntraces
        if ntraces<=10
            println("改写中....",t/ntraces*100," %")
        else
            if rem(t, ll)==0
                println("改写中....",t,"/",ntraces,"      ",t/ntraces*100," %")
            end
        end
        offset=(indexs[t]-1)*(ns*4+240) +3600 #寻找相应的字节数
    # 寻找相应的道头index，通过index来寻找就行
        
        write_trace(seek(s,offset), block, t)
    # write_trace(seekend(s), block, t)
    end
    close(s)
end
