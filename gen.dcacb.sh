#!/usr/bin/env bash

color=0xBB8CFF
alter=0x111111

echo -n "//@version=3
study(\"Dollar Cost Average Cost Basis\", overlay=true, scale=scale.none)
// Shows the cost-basis for dollar cost averaging

price=input(close, title=\"Source\")
// plot the price for use in color fills
plot_price = plot(price[1], linewidth=0)
color_fill_sell = #a20000
color_fill_buy = #017d13
color_fill_transp = input(85, title=\"Fill Transparency\")

time_delta = (timenow - time)
milli_1day = 1000 * 60 * 60 * 24" > dcacb.pine

linewidth=8
for period in 2190 1825 1460 1095 730 365 180 120 90 60 30
do
color_string=$(echo "$color" | sed 's/0x/#/')
   echo -n "
milli_${period}days = milli_1day * ${period} 
within_${period}days = time_delta < milli_${period}days

spent_${period} = 0
total_${period} = 0.0
basis_${period} = 0.0
quant_${period} = 0.0
quant_${period} := within_${period}days ? (1000/price) : 0.0
spent_${period} := within_${period}days ? (nz(spent_${period}[1])+1000) : 0
total_${period} := (nz(total_${period}[1])+quant_${period})
basis_${period} := (spent_${period}/total_${period})


plot_${period} = plot(basis_${period}, linewidth=${linewidth}, color=${color_string}, title=\"${period} days of DCA\")

fill(plot1=plot_${period}, plot2=plot_price, color=price > basis_${period} ? color_fill_sell : color_fill_buy, transp=color_fill_transp)
" >> dcacb.pine

if (( linewidth > 1 )); then
    ((linewidth--))
fi
new_color_dec=$(( $color - $alter ))
color=`printf "0x%X\n" $new_color_dec`

done