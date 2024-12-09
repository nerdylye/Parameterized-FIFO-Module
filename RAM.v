module ram
#(parameter NUM = 1,
  parameter SIZE = NUM*1024,
  parameter WIDTH = 8,
  parameter ADDR = 13)
(
  input 				 wr_clk,
  input 				 rd_clk,
  input 	 [ADDR-1:0]  wr_addr,      // write address
  output reg [WIDTH-1:0] rd_dataout, //simple dual port
  input 	 [WIDTH-1:0] wr_datain,     // data in
  input 				 wr_en,            // write enable
  input 	 [ADDR-1:0]  rd_addr,      // read address
  input 				 rd_en,              // read enable
  input					 reset			  // reset (sync/async)
);

//simple dual port
  reg [WIDTH-1:0] mem_register;
  reg [WIDTH-1:0] memsdp [SIZE-1:0];
   

//simple dual port ram
  always @(posedge wr_clk) begin
    if(reset) begin
      for (integer j = 0; j < SIZE; j = j + 1) begin
	      memsdp [j] <= {WIDTH{1'b0}};
      end    
    end 
    else begin
      if(wr_en && !reset) begin
        memsdp[wr_addr] <= wr_datain;
      end
    end
  end

  always @(posedge rd_clk or posedge reset) begin
    if(reset) begin
      mem_register <= {WIDTH{1'b0}};
      rd_dataout <= {WIDTH{1'b0}};     
    end 
    else begin
      if(rd_en) begin
        mem_register <= memsdp[rd_addr];   
      end
      rd_dataout <= mem_register;
    end
  end

endmodule
