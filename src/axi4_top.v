`include "axi4_master.v"
`include "axi4_slave.v"

module top (
    input  wire        clk,      
    input  wire        arst_n,   

    // Write Address Channel
    input  wire [31:0] AWADDR_M,   
    input  wire        AWVALID_M,  
    output wire        AWREADY_S,  

    // Write Data Channel
    input  wire [31:0] WDATA_M,    
    input  wire        WVALID_M,   
    output wire        WREADY_S,   

    // Write Response Channel
    output wire        BVALID_S,
    output wire  [1:0] BRESP_S,    
    input  wire        BREADY_M,   

    // Read Address Channel
    input  wire [31:0] ARADDR_M,   
    input  wire        ARVALID_M,  
    output wire        ARREADY_S,  

    // Read Data Channel
    output wire [31:0] RDATA_S,    
    output wire        RVALID_S,   
    input  wire        RREADY_M    
);

    // AXI4-Lite Master instance
    axi4lite_master master (
        .clk(clk),         
        .arst_n(arst_n),       
        .AWADDR_M(AWADDR_M), 
        .AWVALID_M(AWVALID_M), 
        .AWREADY_S(AWREADY_S), 
        .WDATA_M(WDATA_M), 
        .WVALID_M(WVALID_M), 
        .WREADY_S(WREADY_S), 
        .BRESP_S(BRESP_S), 
        .BVALID_S(BVALID_S), 
        .BREADY_M(BREADY_M), 
        .ARADDR_M(ARADDR_M), 
        .ARVALID_M(ARVALID_M), 
        .ARREADY_S(ARREADY_S), 
        .RDATA_S(RDATA_S), 
        .RVALID_S(RVALID_S), 
        .RREADY_M(RREADY_M)
    );

    // AXI4-Lite Slave instance
    axi4lite_slave slave (
        .clk(clk),         
        .arst_n(arst_n),       
        .AWADDR_M(AWADDR_M), 
        .AWREADY_S_in(AWREADY_S_in),
        .WREADY_S_in(WREADY_S_in),
        .AWVALID_M(AWVALID_M), 
        .AWREADY_S(AWREADY_S), 
        .WDATA_M(WDATA_M), 
        .WVALID_M(WVALID_M), 
        .WREADY_S(WREADY_S), 
        .BRESP_S(BRESP_S), 
        .BVALID_S(BVALID_S), 
        .BREADY_M(BREADY_M), 
        .ARADDR_M(ARADDR_M), 
        .ARVALID_M(ARVALID_M), 
        .ARREADY_S(ARREADY_S), 
        .RDATA_S(RDATA_S), 
        .RVALID_S(RVALID_S), 
        .RREADY_M(RREADY_M)
    );

endmodule
