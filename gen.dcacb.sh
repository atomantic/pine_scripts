#!/usr/bin/env bash

color=0xBB8CFF
alter=0x111111
futures=(30 60 90)

echo -n "//@version=3
study(\"Dollar Cost Average Cost Basis\", overlay=true)
// Shows the cost-basis for dollar cost averaging
// note: this code was generated using Bash because pinescript does not have arrays/collections
// and you can't run plot within a for loop :(
// code here: https://github.com/atomantic/pine_scripts
// Lightning Network Satoshi Tips Accepted https://tippin.me/@antic

price=input(close, title=\"Source\")
// plot the price for use in color fills
plot_price = plot(price)
color_fill_sell = #a20000
color_fill_buy = #017d13
color_fill_transp = input(85, title=\"Fill Transparency\")
rolling_window = input(defval=false, type=bool, title=\"Rolling Window?\")

time_delta = (timenow - time)
milli_interval = 1000 * 60 * 60 * 24 * interval
dollars = 1000" > dcacb.pine

linewidth=8
for period in 2190 1825 1460 1095 730 365 180 120 90 60 30
do
    color_string=$(echo "$color" | sed 's/0x/#/')
    echo -n "

milli_${period} = milli_interval * ${period} 
within_${period} = time_delta < milli_${period}
total_${period} = 0.0
spent_${period} = 0
quant_${period} = dollars/price // how many fractions/units bought this period
if rolling_window
    spent_${period} := within_${period} ? nz(spent_${period}[1])+dollars : 0
    quant_${period} = within_${period} ? dollars/price : 0.0
    total_${period} := nz(total_${period}[1])+quant_${period}
else
    for i = 1 to ${period}
        if quant_${period}[i]
            spent_${period} := spent_${period}+dollars
        total_${period} := total_${period}+nz(quant_${period}[i], 0)
basis_${period} = spent_${period}/total_${period}
plot_${period} = plot(basis_${period}, linewidth=${linewidth}, color=${color_string}, title=\"${period} days of DCA\")
fill(plot1=plot_${period}, plot2=plot_price, color=price > basis_${period} ? color_fill_sell : color_fill_buy, transp=color_fill_transp)
" >> dcacb.pine

    if [[ " ${futures[@]} " =~ " ${period} " ]]; then
        # note: this isn't quite perfect. ideally, we would want to pop the oldest value from total_${period}
        # and add a new value that is the quantity purchased at the realtime price
        # this would create a sliding window that gets closer to the current closing price
        # however, I haven't found a way to do this, so we are simply subtracting the average quantity
        # then adding a new quantity based on the latest (it's not quite right but it's close if the price is somewhat stable)
        echo -n "
total_${period}_future_0 = total_${period}[0]-(total_${period}/$period)+nz(quant_${period}[0],0)
basis_${period}_future_0 = spent_${period}/total_${period}_future_0
plot(basis_${period}_future_0, show_last=1, style=stepline, trackprice=false, offset=1, linewidth=2, color=${color_string}) 
        " >> dcacb.pine

        for i in {3..36}
        do
            if [[ $((i % 3)) == 0 ]]; then
            prev="$(($i-3))"
            echo -n "
total_${period}_future_${i} = total_${period}_future_${prev}-(total_${period}_future_${prev}[0]/${period})+nz(quant_${period}[0],0)
basis_${period}_future_${i} = spent_${period}/total_${period}_future_${i}
plot(basis_${period}_future_${i}, show_last=1, style=line, trackprice=false, offset=${i}, linewidth=2, color=gray) 
        " >> dcacb.pine
            fi
        done
    fi

    if (( linewidth > 1 )); then
        ((linewidth--))
    fi
    new_color_dec=$(( $color - $alter ))
    color=`printf "0x%X\n" $new_color_dec`

done