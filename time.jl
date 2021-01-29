using Printf

mutable struct Time
    year::Int64
    month::Int64
    day::Int64

    AM_PM::String
    hour::Int64
    minute::Int64
    second::Int64
    function Time(year::Int64,month::Int64,day::Int64,AM_PM::String,hour::Int64,minute::Int64,second::Int64=0)
        @assert(year>0,"Only cares about AD")
        @assert(1<= month <=12,"Month is between 1 and 12")
        @assert(1<= day <=31,"Day is between 1 and 31")

        @assert(1<= hour <=12,"Hour is between 1 and 12")
        @assert(0 ≤ minute < 60, "Minute is between 0 and 60.")
        @assert(0 ≤ second < 60, "Second is between 0 and 60.")
        t = new()
        t.year = year
        t.month = month
        t.day = day
        t.AM_PM = AM_PM
        t.hour = hour
        t.minute = minute
        t.second = second
        t
    end
end

function Base.show(io::IO, time::Time)
    @printf(io,"(%02d/%02d/%02d) %s:%02d:%02d:%02d",time.year,time.month,time.day,time.AM_PM,time.hour,time.minute,time.second)
end
