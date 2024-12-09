module fifo_mode_rw
  #(
    parameter DEPTH_WIDTH = 1024, // words
    parameter DATA_WIDTH = 8,      // bits
    parameter afull_thresh = 10,   //almost_full threshold
    parameter aempty_thresh = 10  // almost_empty threshold
    )
   (
    input 		    						wr_clk,
    input         							rd_clk,
    input 		    						sclr,
    input         							aclr,

    input		[DATA_WIDTH-1:0]			data,
    input 		    						wrreq,

    output 		[DATA_WIDTH-1:0] 			rd_data,
    input 		    						rdreq,

    output 		    						full,
    output 		    						empty,

    output        							almost_full,
    output        							almost_empty,

    output wire [$clog2(DEPTH_WIDTH):0] 	usedw 
    );

   localparam ADDR = $clog2(DEPTH_WIDTH);


// registers
  reg [ADDR-1:0] write_pointer;
  reg [ADDR-1:0] read_pointer;
  // count registers have 1 more bit than address registers to count until depth_width
  reg [ADDR:0] write_count;
  reg [ADDR:0] read_count;
  reg [ADDR:0] count;
  
  reg wr_clr;
  reg rd_clr;
  reg reset;

  assign count = write_count - read_count;
  assign usedw = count;
  assign reset = wr_clr | rd_clr;

// wires
  // FULL and EMPTY conditions
  wire full = (count == DEPTH_WIDTH);
  wire empty = (count == 0);

  // almost_FULL and almost_EMPTY conditions
  wire almost_full = (count >= (DEPTH_WIDTH - afull_thresh)) && !full;
  wire almost_empty = (count <= (0 + aempty_thresh)) && !empty;
  
// Operations
  // write 
  always @(posedge wr_clk or posedge aclr) begin
    // asynchronous clear
    if (aclr) begin
      write_pointer <= 0;
      //current_write_pointer <= 0;
    end 
    else begin
      // synchronous clear
      if (sclr) begin
        write_pointer <= 0;
        //current_write_pointer <= 0;
      end 
      else if (wrreq && !full && !aclr) begin
        //current_write_pointer <= write_pointer;
        write_pointer <= write_pointer + 1'd1;
      end
    end
  end

  // read
  always @(posedge rd_clk or posedge aclr) begin
    // asynchronous clear
    if (aclr) begin
      read_pointer  <= 0;
      //current_read_pointer <= 0;
    end
    else begin 
      // synchronous clear
      if (sclr) begin
        read_pointer  <= 0;
        //current_read_pointer <= 0;
      end
      else if (rdreq && !empty && !aclr) begin
        //current_read_pointer <= read_pointer;
        read_pointer <= read_pointer + 1'd1;
      end
    end
  end

  // counter for full / empty condition
  always @(posedge wr_clk or posedge aclr) begin
    if (aclr) begin
      write_count <= 1'b0;
    end
    else begin
      if (sclr) begin
        write_count <= 1'b0;
      end
      else if (wrreq && !full) begin
        write_count <= write_count + 1'b1;
      end
      else begin
        write_count <= write_count;
      end
    end
  end

  // counter for full / empty condition
  always @(posedge rd_clk or posedge aclr) begin
    if (aclr) begin
      read_count <= 1'b0;
    end
    else begin
      if (sclr) begin
        read_count <= 1'b0;
      end
      else if (rdreq && !empty) begin
        read_count <= read_count + 1'b1;
      end
      else begin
        read_count <= read_count;
      end
    end
  end

  // reset signal
  always @(posedge wr_clk or posedge aclr) begin
    if (aclr) begin
      wr_clr <= 1'b1;
    end
    else if (sclr) begin
      wr_clr <= 1'b1;
    end
    else begin
      wr_clr <= 1'b0;
    end
  end

  // reset signal
  always @(posedge rd_clk or posedge aclr) begin
    if (aclr) begin
      rd_clr <= 1'b1;
    end
    else if (sclr) begin
      rd_clr <= 1'b1;
    end
    else begin
      rd_clr <= 1'b0;
    end
  end

endmodule
