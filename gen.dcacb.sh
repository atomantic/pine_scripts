#!/usr/bin/env bash

color=0xBB8CFF
alter=0x111111

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
milli_1day = 1000 * 60 * 60 * 24
dollars = 1000" > dcacb.pine

linewidth=8
for period in 2190 1825 1460 1095 730 365 180 120 90 60 30
do
color_string=$(echo "$color" | sed 's/0x/#/')
   echo -n "
milli_${period}days = milli_1day * ${period} 
within_${period}days = time_delta < milli_${period}days

total_${period} = 0.0
spent_${period} = ${period}*dollars

if rolling_window
    spent_${period} := within_${period}days ? nz(spent_${period}[1])+dollars : 0
    quant_${period} = within_${period}days ? dollars/price : 0.0
    total_${period} := nz(total_${period}[1])+quant_${period}
else
    quant_${period} = dollars/price // how many fractions/units bought this period
    for i = 1 to ${period}
        total_${period} := total_${period}+quant_${period}[i]

basis_${period} = spent_${period}/total_${period}

plot_${period} = plot(basis_${period}, linewidth=${linewidth}, color=${color_string}, title=\"${period} days of DCA\")

fill(plot1=plot_${period}, plot2=plot_price, color=price > basis_${period} ? color_fill_sell : color_fill_buy, transp=color_fill_transp)
" >> dcacb.pine

if (( linewidth > 1 )); then
    ((linewidth--))
fi
new_color_dec=$(( $color - $alter ))
color=`printf "0x%X\n" $new_color_dec`

done