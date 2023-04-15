# yjfSegyIO.jl

julia有着高效的速度，在很多自定义情况下比pyhton和matlab快非常多，地球物理sgy包并不多，且功能不全，我分享出我的sgyio包，为大家接触julia地球物理添砖加瓦！

这个包是根据https://github.com/slimgroup/SegyIO.jl 包修改而来，没有向原作者提交，如果有人有时间将包里注释改成英文，再提交给原作者

里面有很多没删除的注释，没时间整理

主要增添的很必要的功能：

    1.写IBMFloat 格式的sgy

    2.读取地震道数按index，而且加速读取，非逐道
        indexes=[1,4,8,12]
        block = segy_read(orig,indexs,n1)   

    3.增添Float32(seisblock)类型转化

    4.按道改写
        segy_change(outsgyname, block, index3) # 改写相应道的数据

可以根据此改进实现的功能：不用整体读入，可以按道进行读取和改写sgy，也可一次读取自己设定大小sgy，并进行改写。

## INSTALLATION

SegyIO is a registered package and can be installed directly from the julia package manager (`]` in the julia REPL) :

```
 add https://github.com/13299118606/yjfSegyIO.git
```

## Extension
