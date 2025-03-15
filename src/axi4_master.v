module axi4lite_master (
    input wire clk,         
    input wire arst_n,       

    // Write Address Channel
    output reg [31:0] AWADDR_M, 
    output reg AWVALID_M, 
    input wire AWREADY_S, 

    // Write Data Channel
    output reg [31:0] WDATA_M, 
    output reg WVALID_M, 
    input wire WREADY_S, 

    // Write Response Channel
    input wire [1:0] BRESP_S, 
    input wire BVALID_S, 
    output reg BREADY_M, 

    // Read Address Channel
    output reg [31:0] ARADDR_M, 
    output reg ARVALID_M, 
    input wire ARREADY_S, 

    // Read Data Channel
    input wire [31:0] RDATA_S, 
    input wire RVALID_S, 
    output reg RREADY_M
);

// State Encoding
localparam IDLE        = 3'b000;
localparam WRITE_ADDR  = 3'b001;
localparam WRITE_DATA  = 3'b010;
localparam WRITE_RESP  = 3'b011;
localparam READ_ADDR   = 3'b100;
localparam READ_DATA   = 3'b101;
localparam DONE        = 3'b110; // New state for completion

reg [2:0] state; // State register
reg [31:0] read_data; // Storage for read data
reg [31:0] write_data;
reg [31:0] write_address;
reg [31:0] read_address;

always @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
        // Reset signals
        AWADDR_M  <= 32'h0000_1000;
        AWVALID_M <= 0;
        WDATA_M   <= 32'h0;
        WVALID_M  <= 0;
        BREADY_M  <= 0;
        ARADDR_M  <= 32'h0000_1000;
        ARVALID_M <= 0;
        RREADY_M  <= 0;
        state     <= IDLE;
        read_data <= 32'h0;
        write_data <= 32'h0;
        write_address <= 32'h0;
        read_address <= 32'h0;

    end else begin
        case (state)
            WRITE_ADDR: begin
                if(AWADDR_M) begin
                  AWVALID_M <= 1;
                    if (AWREADY_S) begin
                         AWVALID_M <= 0;
                         end
                else 
                    AWVALID_M <= 0;

                    state  <= WRITE_DATA;
                end
            end
//Add condition for WDATA_M 

            WRITE_DATA: begin
                WVALID_M <= 1;
                if (WREADY_S) begin
                    WVALID_M <= 0;
                    state    <= WRITE_RESP;
                end
            end

            WRITE_RESP: begin
                BREADY_M <= 1;
                if (BVALID_S) begin
                    BREADY_M <= 0;
                    state    <= READ_ADDR;
                end
            end

            READ_ADDR: begin
                ARVALID_M <= 1;
                if (ARREADY_S) begin
                    ARVALID_M <= 0;
                    state     <= READ_DATA;
                end
            end

            READ_DATA: begin
                RREADY_M <= 1;
                if (RVALID_S) begin
                    read_data <= RDATA_S;
                    RREADY_M  <= 0;
                    state     <= DONE;
                end
            end

            DONE: begin
                // Hold DONE state or restart a new transaction
                // Uncomment below line to restart transactions
                // state <= WRITE_ADDR;
            end

            default: state <= IDLE;
        endcase
    end
end
endmodule
