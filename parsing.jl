

# this approach is not general purpose, may work only in the robionhood case
function parsing(wrd::String,tr::String,forward::Bool=true)

    if forward
        ID = findfirst(wrd,tr) # after this word
        startind = ID[end] + 2 # skip a white space
        endind = startind
        while !isspace(tr[endind])  # go to the next white space
            endind += 1
        end
        endind -=1 # the end of a new word
        word = tr[startind:endind] # slice
    else # backward
        ID = findfirst(wrd,tr)
        namend = ID[1]-2
        namestart = namend
        # backward tracking
        while !isspace(tr[namestart])
            namestart -= 1
        end
        namestart += 1
        word = tr[namestart:namend]
    end
    return word
end

# for '$' case with Char since "$" does not work
function parsing(wrd::Char,tr::String,forward::Bool=true)

    if forward
        ID = findfirst(wrd,tr)
        startind = ID[end] + 1 # no white space
        endind = startind
        while !isspace(tr[endind])
            endind += 1
        end
        endind -=1
        word = tr[startind:endind]
    else # may be not the case
        ID = findfirst(wrd,tr)
        namend = ID[1]-1
        namestart = namend
        # backward tracking
        while !isspace(tr[namestart])
            namestart -= 1
        end
        namestart += 1
        word = tr[namestart:namend]
    end
    return word
end

function name_share(tr::String)
    name = parsing("was",tr,false)
end

function value_share(tr::String)
    value_s = parsing('$',tr)
    value = parse(Float64,value_s)
end

function num_shares(tran::Bool,tr::String)
    # now count how many shares buy
    cat =["buy","sell"]
    if tran == true
        flag = 1
    else
        flag = 2
    end
    num_s = parsing(cat[flag],tr)
    num = parse(Int64,num_s)
end

function month_parse(tr::String)
    # month
    calanders = Dict([("January",1),("Febuary",2),("March",3),("April",4),("May",5),
        ("June",6),("July",7),("August",8),("September",9),("October",10),
        ("November",11),("December",12)])

    month_s = parsing("on",tr)
    month = calanders[month_s]

end

function day_parse(tr::String)
    day_st = parsing(',',tr,false)
    ID = 1
    while isdigit(day_st[ID])
        ID += 1
    end
    ID -= 1
    day = parse(Int64,day_st[1:ID])
end


function clock_parse(tr::String)
    ID = findlast("at",tr)
    startind = ID[end] + 2 # skip a white space
    endind = startind
    while !isspace(tr[endind])  # go to the next white space
        endind += 1
    end
    endind -=1 # the end of a new word
    word = tr[startind:endind] # slice
    word = string(" ",word," ")
    min = parsing(':',word,false)
    sec = parsing(':',word)
    return parse(Int64,min), parse(Int64,sec)
end

function sun_parse(tr::String)
    ID = findlast('.',tr)
    namend = ID[1]-1
    namestart = namend
    # backward tracking
    while !isspace(tr[namestart])
        namestart -= 1
    end
    namestart += 1
    word = tr[namestart:namend]
end

function year_parse(tr::String)
    year_s = parsing(",",tr)
    year = parse(Int64,year_s)
end

function date_share(tr::String)
    # month
    month = month_parse(tr)
    # day
    day = day_parse(tr)
    # year
    year = year_parse(tr)
    # clock
    min,sec = clock_parse(tr)
    # am / pm
    sun = sun_parse(tr)
    # println("$(month) $(day) $(year) $(min):$(sec) $(sun)")
    times = Time(year,month,day,sun,min,sec)
end


function new_transaction(tr::String)

    BuyorSell = !isnothing(findfirst("buy",tr))
    name = name_share(tr) # extract the name of the current transaction
    value = value_share(tr)
    num = num_shares(BuyorSell,tr)
    dates = date_share(tr)

    return BuyorSell, name, value, num, dates

end
