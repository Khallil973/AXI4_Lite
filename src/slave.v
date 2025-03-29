module axi_slave (
    input wire clk,
    input wire arst_n,

    // AXI4-Lite Write Address Channel
    input wire [31:0] S_AXI_AWADDR,
    input wire S_AXI_AWVALID,
    output reg S_AXI_AWREADY,

    // AXI4-Lite Write Data Channel
    input wire [31:0] S_AXI_WDATA,
    input wire [3:0] S_AXI_WSTRB,
    input wire S_AXI_WVALID,
    output reg S_AXI_WREADY,

    // AXI4-Lite Write Response Channel
    output reg [1:0] S_AXI_BRESP,
    output reg S_AXI_BVALID,
    input wire S_AXI_BREADY,

    // AXI4-Lite Read Address Channel
    input wire [31:0] S_AXI_ARADDR,
    input wire S_AXI_ARVALID,
    output reg S_AXI_ARREADY,

    // AXI4-Lite Read Data Channel
    output reg [31:0] S_AXI_RDATA,
    output reg [1:0] S_AXI_RRESP,
    output reg S_AXI_RVALID,
    input wire S_AXI_RREADY
);

    // Memory for storing data (256 x 32-bit locations)
    reg [31:0] memory [0:255];

    // Internal Registers
    reg [31:0] write_address_S;
    reg [31:0] read_address_S;
    reg write_in_progress_S;
    reg [31:0] debug_mem_value;

    // Memory Initialization to Avoid xxxx
    integer i;
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] <= 32'h00000000; // Default value = 0x00000000
            end
        end
    end

    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            // Reset All Signals
            S_AXI_AWREADY <= 0;
            S_AXI_WREADY <= 0;
            S_AXI_BVALID <= 0;
            S_AXI_BRESP <= 2'b00;
            S_AXI_ARREADY <= 0;
            S_AXI_RVALID <= 0;
            S_AXI_RRESP <= 2'b00;
            write_in_progress_S <= 0;
            debug_mem_value <= 32'h00000000;
        end else begin
            //Write Operation
            // Capture Write Address
            if (S_AXI_AWVALID && !S_AXI_AWREADY) begin
                write_address_S <= S_AXI_AWADDR; 
                S_AXI_AWREADY <= 1;
            end
            if (S_AXI_AWREADY && S_AXI_AWVALID) begin
                S_AXI_AWREADY <= 0; // Deassert
                write_in_progress_S <= 1; // Mark Write in Progress
            end

            // Capture Write Data
            if (write_in_progress_S && S_AXI_WVALID && !S_AXI_WREADY) begin
                S_AXI_WREADY <= 1;
                memory[write_address_S] <= S_AXI_WDATA; // Write Data
            end

            if (S_AXI_WREADY && S_AXI_WVALID) begin
                S_AXI_WREADY <= 0;
                write_in_progress_S <= 0;
                S_AXI_BRESP <= 2'b00; // OKAY Response
                S_AXI_BVALID <= 1;
                
                // Update Debug Register Only When Write Happens
                debug_mem_value <= S_AXI_WDATA;
            end

            // Clear Write Response when acknowledged
            if (S_AXI_BVALID && S_AXI_BREADY) begin
                S_AXI_BVALID <= 0;
            end
            //Read Operation
            // Capture Read Address
            if (S_AXI_ARVALID && !S_AXI_ARREADY) begin
                read_address_S <= S_AXI_ARADDR; 
                S_AXI_ARREADY <= 1;
            end

            if (S_AXI_ARREADY && S_AXI_ARVALID) begin
                S_AXI_ARREADY <= 0; // Deassert after receiving address
                S_AXI_RDATA <= memory[read_address_S]; // Read from Memory
                S_AXI_RRESP <= 2'b00; // OKAY Response
                S_AXI_RVALID <= 1;
            end

            // Clear Read Response when acknowledged
            if (S_AXI_RVALID && S_AXI_RREADY) begin
                S_AXI_RVALID <= 0;
            end
        end
    end

endmodule
