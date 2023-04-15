export write_trace,num2ibm

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
            write(s, bswap(getfield(block.traceheaders[t], field)))
        end
        # for field in fieldnames(typeof(block.traceheaders[t]))
        #     write(s, getfield(block.traceheaders[t], field))
        # end
    end


    ##240
    pos_trace_240=position(s)

    # Write trace
    if block.fileheader.bfh.DataSampleFormat == 5
        write(s, bswap.(Float32.(block.data[:, t])))#交互字节顺序并转化成了10进制  默认的IEEE格式
    elseif block.fileheader.bfh.DataSampleFormat == 1  #IBMFloat32
        tem=num2ibm(Float32.(block.data[:, t]))
        tem=UInt32.(tem)
        write(s, bswap.(tem))
    end
    pos_trace_end=position(s)
    
end


function num2ibm(x)
    # num2ibm : convert IEEE 754 doubles to IBM 32 bit floating point format
    #    b = num2ibm(x)
    # x is a matrix of doubles
    # b is a corresponding matrix of uint32
    # 学的maltab  #903.1试

    b = zeros(UInt32, size(x)) 
    err = zeros(size(x))

    # x[x .> 7.236998675585915e+75] .= Inf
    # x[x .< -7.236998675585915e+75] .= -Inf

    H= frexp.(abs.(x))#（E=0.881835940f0 F=10） #计算函数的幂和尾数
    E= zeros(size(x))
    F= zeros(size(x))
    for i in 1:length(x)
        F[i]=H[i][1]
        E[i]=H[i][2]
    end
    e = E/4             #2.5  取尾数并取整
    ec = ceil.(e)     #3.0
    p = ec .+ 64       # 67
    f= zeros(size(x))  
    for i in 1:length(x)
    f[i] = F[i]*(2^(-4*(ec[i] .- e[i])))  #
    end
    f = round.(f .* 2^24)

    # p[f .== 2^24] .= p[f .== 2^24] .+ 1  #矫正2^24的数字 超出范围
    # f[f .== 2^24] .= 2^20
    psif=""
    phif=""
    psi= zeros(size(x))
    phi=zeros(size(x))
    b0=zeros(size(x))
    # b1=zeros(size(x))
    for i in 1:length(x)
        # psif =string(UInt32.(p[i] * 2^24))                  # "1124073472"  0x43000000
        # phif =string(UInt32.(f[i]))                         # "3698688"     0x00387000     convert(Int, (f[1])) 可以直接3698688   会节省非常多 最少80%
        # psi[i]= parse(Int, psif)   #2.214073472e9           "00000000000000000000000000000000 01000011000000000000000000000000"  #这里显示64个数 空格之后是32位字节
        # phi[i]= parse(Int, phif)   #3.698688e6              "00000000000000000000000000000000 00000000001110000111000000000000"
        # b0[i] = Int(psi[i]) | Int(phi[i])  #建立浮点数       "00000000000000000000000000000000 01000011001110000111000000000000"  注意这里只有b0是整数时对应 1.12777216e9 和1127772160 对应不同
        b0[i]=convert(Int, (f[i]))|convert(Int, (p[i]*2^24))
    end
    #设计负号 32 位补位

    for i in 1:length(x)
    if x[i]<0
        # bin_str=string(UInt32.(b0[i]),base =2,pad=32)
        # b2 = parse(Int, bin_str, base=2) 
        b2=convert(Int, UInt32.(b0[i]))
        b0[i]=b2 ⊻ 2^(32-1)                     # "00000000000000000000000000000000 10000000000000000000000000000000"   2^(32-1) 就这个
        # b1[i]=b3 ⊻ 2^(32-1)            
    end
    end
    b=b0

    #修改其他异常值

    index0=findall(x .==0)
    if length(index0)>0
        for i in 1:length(index0)
        b[index0[i]]=UInt32(0)
        end
    end
    indexnan=findall(isnan.(x)==1)
    if length(indexnan)>0
        for i in 1:length(index0)
            b[indexnan[i]]=UInt32(2147483647)    #  '7fffffff';         %  7.237005145973116e+75 in IBM format
        end
    end

    indexinf0=findall(isinf.(x)==1) 
    if length(indexinf0)>0
        for i in 1:length(index0)
            b[indexnan[i]]=UInt32(2147483647)      #   7.237005145973116e+75 in IBM format  '7ffffff0'
        end
    end
    #正无穷的异常值
    # if length(indexinf1)>0
    #     b[indexinf1]=UInt32(4294967280)   # 'fffffff0'    -7.236998675585915e+75  
    # end


    return b
end

