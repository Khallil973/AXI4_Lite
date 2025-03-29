module axi_master (
    input wire clk,
    input wire arst_n,
    input wire start_write,
    input wire start_read,
    input wire [31:0] write_data,
    input wire [31:0] write_address_M,
    input wire [31:0] read_address,
    output reg [31:0] read_data,
    output reg write_done,
    output reg read_done,
    
    // AXI4-Lite Write Address Channel
    output reg [31:0] M_AXI_AWADDR,
    output reg M_AXI_AWVALID,
    input wire M_AXI_AWREADY,
    
    // AXI4-Lite Write Data Channel
    output reg [31:0] M_AXI_WDATA,
    output reg [3:0] M_AXI_WSTRB,
    output reg M_AXI_WVALID,
    input wire M_AXI_WREADY,
    
    // AXI4-Lite Write Response Channel
    input wire [1:0] M_AXI_BRESP,
    input wire M_AXI_BVALID,
    output reg M_AXI_BREADY,
    
    // AXI4-Lite Read Address Channel
    output reg [31:0] M_AXI_ARADDR,
    output reg M_AXI_ARVALID,
    input wire M_AXI_ARREADY,
    
    // AXI4-Lite Read Data Channel
    input wire [31:0] M_AXI_RDATA,
    input wire [1:0] M_AXI_RRESP,
    input wire M_AXI_RVALID,
    output reg M_AXI_RREADY
);

reg start_write_reg;

// State machine for controlling write and read operations
always @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        // Reset all control signals
        M_AXI_AWVALID <= 0;
        M_AXI_WVALID  <= 0;
        M_AXI_BREADY  <= 0;
        M_AXI_ARVALID <= 0;
        M_AXI_RREADY  <= 0;
        write_done    <= 0;
        read_done     <= 0;
    end 
    else begin
        // WRITE PROCESS
        if (start_write) begin
            M_AXI_AWADDR  <= write_address_M;
            M_AXI_AWVALID <= 1;
            M_AXI_WDATA   <= write_data;
            M_AXI_WVALID  <= 1;
            M_AXI_WSTRB   <= 4'b1111; // Full word write
            write_done    <= 0; // Clear write_done flag
        end

        // Write address handshake
        if (M_AXI_AWREADY && M_AXI_AWVALID) 
            M_AXI_AWVALID <= 0; // Deassert when slave is ready

        // Write data handshake
        if (M_AXI_WREADY && M_AXI_WVALID) 
            M_AXI_WVALID <= 0; // Deassert when slave is ready

        // Write response handling
        if (M_AXI_BVALID) begin
            M_AXI_BREADY <= 1; // Acknowledge response
            write_done   <= 1; // Set write done flag
        end 
        else 
            M_AXI_BREADY <= 0; // Deassert once acknowledged

        // READ PROCESS
        if (start_read) begin
            M_AXI_ARADDR  <= read_address;
            M_AXI_ARVALID <= 1;
            read_done     <= 0; // Clear read_done flag
        end

        // Read address handshake
        if (M_AXI_ARREADY && M_AXI_ARVALID) 
            M_AXI_ARVALID <= 0; // Deassert when slave is ready

        // Read data handling
        if (M_AXI_RVALID) begin
            M_AXI_RREADY <= 1; // Acknowledge data
            read_data    <= M_AXI_RDATA; // Store received data
            read_done    <= 1; // Set read done flag
        end 
        else 
            M_AXI_RREADY <= 0; // Deassert once acknowledged
    end
end

endmodule
