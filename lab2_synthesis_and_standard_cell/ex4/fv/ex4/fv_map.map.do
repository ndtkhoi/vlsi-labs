
//input ports
add mapped point clk clk -type PI PI
add mapped point rst rst -type PI PI

//output ports
add mapped point Q[1] Q[1] -type PO PO
add mapped point Q[0] Q[0] -type PO PO

//inout ports




//Sequential Pins
add mapped point Q[1]/q Q_reg[1]/Q -type DFF DFF
add mapped point Q[0]/q Q_reg[0]/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
