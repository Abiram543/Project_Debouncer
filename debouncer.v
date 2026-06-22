`default_nettype none
module debouncer #(
  parameter THRESHOLD = 1000000  // 10ms delay deffault
)(
  input   wire  clk,
  input   wire  rst,
  input   wire  button_in,
  output  reg   debounced
);
// state encoding (one-hot)
localparam  S0 = 0, S1 = 1, S2 = 2, S3 = 3;
reg [3:0]   state, next;

// timer for debounce delay
reg [$clog2(THRESHOLD)-1:0] timer;
reg timer_en;
reg R1;
reg	button_sync;

//2FF synchronizer
always @ (posedge clk or posedge rst) begin
	if(rst) begin
		R1 <= 0;
		button_sync <= 0;
	end
	else begin
		R1 <= button_in;
		button_sync <= R1;
	end
end

// timer logic
always @ (posedge clk or posedge rst) begin
  if (rst) begin
    timer <= 'b0;
  end else if (timer_en) begin
    timer <= timer + 1;
  end else begin
    timer <= 'b0;
  end
end

// FSM: reset logic
always @ (posedge clk or posedge rst) begin
  if (rst) begin 
    state <= S0;
  end else begin
    state <= next;
  end
end

// FSM: output & enable
always @ * begin
  case (state)
    S0: {debounced, timer_en} = 2'b00;
    S1: {debounced, timer_en} = 2'b01;
    S2: {debounced, timer_en} = 2'b10;
    S3: {debounced, timer_en} = 2'b11;
    default: {debounced, timer_en} = 'b0;
  endcase
end

// FSM: state transition
always @ * begin
  case (state)
    S0: next = button_sync  ? S1 : S0;
    S1: next = button_sync  ? (timer >= THRESHOLD) ? S2 : S1 : S0;
    S2: next = ~button_sync ? S3 : S2;
    S3: next = ~button_sync ? (timer >= THRESHOLD) ? S0 : S3 : S2;
    default: next = S0;
  endcase
end 

endmodule 
