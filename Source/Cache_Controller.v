module Cache_Controller (input clk, rst, MEM_R_EN, MEM_W_EN, input [31:0]Address, wdata, input [63:0]sram_rdata,
  input sram_ready, output [31:0]rdata, output ready, output [31:0]sram_address, sram_wdata, output reg write, read,
  output [8:0]tag_address, output [5:0]index_address, output [2:0]offset, output [73:0]way1, way0, output hit0, hit1, LRU);

  reg [148:0]cache[63:0];

  assign offset = Address[2:0];
  assign tag_address = Address[17:9];
  assign index_address = Address[8:3];

  assign LRU = cache[index_address][148];
  assign way1 = cache[index_address][73:0];
  assign way0 = cache[index_address][147:74];

  assign hit0 =(way0[73:65] == tag_address & way0[0]) ? 1 : 0;
  assign hit1 =(way1[73:65] == tag_address & way1[0]) ? 1 : 0;

  assign ready = ((hit0 | hit1 | !MEM_R_EN) & !MEM_W_EN);

  integer i;
  always @ (posedge clk) begin
    if(rst) for(i = 0 ; i < 64 ; i = i + 1) cache[i] = 149'b0;
    else begin
      if(MEM_W_EN) begin
        if(hit0) cache[index_address][74] = 0;
        else if(hit1) cache[index_address][0] = 0;
      end
      if(MEM_R_EN & ready) cache[index_address][148] = hit0 ? 1 : 0;
      read = (!ready & MEM_R_EN);
      write = (!sram_ready & MEM_W_EN);
      if(!ready & MEM_R_EN & sram_ready)begin
        if(LRU == 0)begin
          cache[index_address][64+74:1+74] = sram_rdata;
          cache[index_address][0+74] = 1;
          cache[index_address][73+74:65+74] = tag_address;
          cache[index_address][148] = 1;
        end
        else if(LRU == 1)begin
          cache[index_address][64:1] = sram_rdata;
          cache[index_address][0] = 1;
          cache[index_address][73:65] = tag_address;
          cache[index_address][148] = 0;
        end
      end
    end
  end

  assign sram_address = Address;
  assign sram_wdata = wdata;
  assign rdata = hit0 ? (offset[2] ? way0[64:33] : way0[32:1]) :
               ( hit1 ? (offset[2] ? way1[64:33] : way1[32:1]) :
               (offset[2] ? sram_rdata[63:32] : sram_rdata[31:0]));

endmodule
