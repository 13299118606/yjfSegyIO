export set_header!, set_traceheader!, set_fileheader! 

# Set traceheader for vector
function set_traceheader!(traceheaders::Array{BinaryTraceHeader,1},
                          name::Symbol, x::ET) where {ET<:Array{<:Integer,1}}
    ftype = fieldtype(BinaryTraceHeader, name)
    try
        x_typed = convert.(ftype, x)

        for t in 1:length(traceheaders)
            setfield!(traceheaders[t], name, x_typed[t])
        end
    catch e
        @warn "Unable to convert $x to $(ftype)"
        throw(e)
    end
end

# Set fileheader
function set_fileheader!(fileheader::BinaryFileHeader,
                         name::Symbol, x::ET) where {ET<:Integer}
    ftype = fieldtype(BinaryFileHeader, name)
    try
        x_typed = convert.(ftype, x)
        setfield!(fileheader, name, x_typed)
    catch e
        @warn "Unable to convert $x to $(ftype)"
        throw(e)
    end
end

"""
set_header!(block, header, value)

Set the 'header' field in 'block' to 'value', where 'header' is either a string or symbol of a valid field in BinaryTraceHeader.

If 'value' is an Int, it will be applied to each header.
If 'value' is a vector, the i-th 'value' will be set in the i-th traceheader.

# Example

set_header!(block, "SourceX", 100)
set_header!(block, :SourceY, Array(1:100))
"""
function set_header!(block::SeisBlock, name_in::Union{Symbol, String}, x::ET) where {ET<:Integer}
    name = Symbol(name_in)  
    ntraces = size(block)[2]
    x_vec = x.*ones(Int32, ntraces)

    # Try setting trace headers
    try
        set_traceheader!(block.traceheaders, name, x_vec)
    catch
    end

    # Try setting file header
    try
        set_fileheader!(block.fileheader.bfh, name, x)
    catch
    end
end

function set_header!(block::SeisBlock, name_in::Union{Symbol, String},
                     x::Array{ET,1}) where {ET<:Integer}
    name = Symbol(name_in)  
    ntraces = size(block)[2]

    # Try setting trace headers
    try
        set_traceheader!(block.traceheaders, name, x)
    catch
    end

    # Try setting file header
    try
        set_fileheader!(block.fileheader.bfh, name, x)
    catch
    end
end

function copy(bfh::BinaryFileHeader)
    newbfh=BinaryFileHeader()
set_fileheader!(newbfh, :Job,bfh. Job)
set_fileheader!(newbfh, :Line,bfh. Line)
set_fileheader!(newbfh, :Reel,bfh. Reel)
set_fileheader!(newbfh, :DataTracePerEnsemble,bfh. DataTracePerEnsemble)
set_fileheader!(newbfh, :AuxiliaryTracePerEnsemble,bfh. AuxiliaryTracePerEnsemble)
set_fileheader!(newbfh, :dt,bfh. dt)
set_fileheader!(newbfh, :dtOrig,bfh. dtOrig)
set_fileheader!(newbfh, :ns,bfh. ns)
set_fileheader!(newbfh, :nsOrig,bfh. nsOrig)
set_fileheader!(newbfh, :DataSampleFormat,bfh. DataSampleFormat)
set_fileheader!(newbfh, :EnsembleFold,bfh. EnsembleFold)
set_fileheader!(newbfh, :TraceSorting,bfh. TraceSorting)
set_fileheader!(newbfh, :VerticalSumCode,bfh. VerticalSumCode)
set_fileheader!(newbfh, :SweepFrequencyStart,bfh. SweepFrequencyStart)
set_fileheader!(newbfh, :SweepFrequencyEnd,bfh. SweepFrequencyEnd)
set_fileheader!(newbfh, :SweepLength,bfh. SweepLength)
set_fileheader!(newbfh, :SweepType,bfh. SweepType)
set_fileheader!(newbfh, :SweepChannel,bfh. SweepChannel)
set_fileheader!(newbfh, :SweepTaperlengthStart,bfh. SweepTaperlengthStart)
set_fileheader!(newbfh, :SweepTaperLengthEnd,bfh. SweepTaperLengthEnd)
set_fileheader!(newbfh, :TaperType,bfh. TaperType)
set_fileheader!(newbfh, :CorrelatedDataTraces,bfh. CorrelatedDataTraces)
set_fileheader!(newbfh, :BinaryGain,bfh. BinaryGain)
set_fileheader!(newbfh, :AmplitudeRecoveryMethod,bfh. AmplitudeRecoveryMethod)
set_fileheader!(newbfh, :MeasurementSystem,bfh. MeasurementSystem)
set_fileheader!(newbfh, :ImpulseSignalPolarity,bfh. ImpulseSignalPolarity)
set_fileheader!(newbfh, :VibratoryPolarityCode,bfh. VibratoryPolarityCode)
set_fileheader!(newbfh, :SegyFormatRevisionNumber,bfh. SegyFormatRevisionNumber)
set_fileheader!(newbfh, :FixedLengthTraceFlag,bfh. FixedLengthTraceFlag)
set_fileheader!(newbfh, :NumberOfExtTextualHeaders,bfh. NumberOfExtTextualHeaders)
    return newbfh
end

function copy(fhd::FileHeader)
    newfhd=FileHeader()
    a=fhd.th
    newfhd.th="$a"
    newfhd.bfh=copy(fhd.bfh)
    return newfhd
end