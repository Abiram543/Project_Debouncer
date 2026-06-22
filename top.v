`default_nettype none
module top(
    input wire sys_clk,
    input wire sys_rst,
    input wire button,
    output wire led
    );
  
    wire button_sync;
  
    debouncer #(
      .THRESHOLD(10000000)  // 100ms delay deffault
) inst3 (
  .clk(sys_clk),
  .rst(sys_rst),
  .button_in(button),
  .debounced(button_sync)
);

assign led = button_sync;

endmodule
