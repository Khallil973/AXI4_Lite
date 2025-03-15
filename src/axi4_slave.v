module axi4lite_slave (
    input wire clk,
    input wire arst_n,

    // Write Address Channel
    input wire [31:0] AWADDR_M,
    input wire AWREADY_S_in,
    input wire AWVALID_M,
    output reg AWREADY_S,

    // Write Data Channel
    input wire [31:0] WDATA_M,
    input wire WREADY_S_in,
    input wire WVALID_M,
    output reg WREADY_S,

    // Write Response Channel
    output reg [1:0] BRESP_S,
    output reg BVALID_S,
    input wire BREADY_M,

    // Read Address Channel
    input wire [31:0] ARADDR_M,
    input wire ARVALID_M,
    output reg ARREADY_S,

    // Read Data Channel
    output reg [31:0] RDATA_S,
    output reg RVALID_S,
    input wire RREADY_M
);

    // Memory registers
    reg [31:0] mem_1;
    reg [31:0] mem_2;

    // Latching addresses and data
    reg [31:0] awaddr_reg;
    reg [31:0] araddr_reg;
    reg [31:0] wdata_reg1,wdata_reg2;
    reg awaddr_valid, wdata_valid, araddr_valid;

    localparam MEM_1_ADDR = 32'h04;
    localparam MEM_2_ADDR = 32'h08;

    always @(posedge clk or negedge arst_n) begin
        if (!arst_n) begin
            // Reset all
            AWREADY_S <= 0; WREADY_S <= 0; BVALID_S <= 0; BRESP_S <= 2'b00;
            ARREADY_S <= 0; RVALID_S <= 0; RDATA_S <= 0;
            mem_1 <= 0; mem_2 <= 0;
            awaddr_reg <= 0; wdata_reg1 <= 0; wdata_reg2 <= 0; araddr_reg <= 0;
            awaddr_valid <= 0; wdata_valid <= 0; araddr_valid <= 0;

        end else begin
            if (AWVALID_M && AWREADY_S_in) begin
                awaddr_reg <= AWADDR_M;
                AWREADY_S <= 0;
            end 
            else begin
                awaddr_reg <= awaddr_reg;
                AWREADY_S <= AWREADY_S;
            end    

  /*          // =========== WRITE ADDRESS HANDSHAKE ===========
            if (AWVALID_M && !AWREADY_S && !awaddr_valid) begin
                AWREADY_S <= 1;
                awaddr_reg <= AWADDR_M;
                awaddr_valid <= 1;
            end else begin
                AWREADY_S <= 0;
            end
*/
            // =========== WRITE DATA HANDSHAKE ===========

            if (WVALID_M && WREADY_S_in )
                if(MEM_1_ADDR == awaddr_reg) begin
                    wdata_reg1 <= WDATA_M;
                    WREADY_S <= 0;
                    BVALID_S <= 1; // Response valid
                    BRESP_S <= 2'b00; // OKAY
                end else if (MEM_2_ADDR == awaddr_reg ) begin
                    wdata_reg2 <= WDATA_M;
                    WREADY_S <= 0;
                    BVALID_S <= 1; // Response valid
                    BRESP_S <= 2'b00; // OKAY                   
                end 
            else begin
                wdata_reg1 <= wdata_reg1;
                wdata_reg2 <= wdata_reg2;
                WREADY_S <= WREADY_S; 
                BVALID_S <= 0; // Response valid
                BRESP_S <= 2'b10; // SLVERROR
            end   


/*
            if (WVALID_M && !WREADY_S && !wdata_valid) begin
                WREADY_S <= 1;
                wdata_reg <= WDATA_M;
                wdata_valid <= 1;
            end else begin
                WREADY_S <= 0;
            end
*/
            // =========== WRITE TRANSACTION ===========




 /*           
            if (awaddr_valid && wdata_valid && !BVALID_S) begin
                case (awaddr_reg)
                    MEM_1_ADDR: mem_1 <= wdata_reg;
                    MEM_2_ADDR: mem_2 <= wdata_reg;
                    default: ; // Invalid
                endcase
                BVALID_S <= 1; // Response valid
                BRESP_S <= 2'b00; // OKAY
                awaddr_valid <= 0; wdata_valid <= 0;
            end
*/

/*
            // =========== WRITE RESPONSE ===========
            if (BVALID_S && BREADY_M) begin
                BVALID_S <= 0;
            end

            // =========== READ ADDRESS HANDSHAKE ===========
            if (ARVALID_M && !ARREADY_S && !araddr_valid) begin
                ARREADY_S <= 1;
                araddr_reg <= ARADDR_M;
                araddr_valid <= 1;
            end else begin
                ARREADY_S <= 0;
            end
*/
            // =========== READ TRANSACTION ===========
            if (araddr_valid && !RVALID_S) begin
                case (araddr_reg)
                    MEM_1_ADDR: RDATA_S <= mem_1;
                    MEM_2_ADDR: RDATA_S <= mem_2;
                    default: RDATA_S <= 32'h00000000;
                endcase
                RVALID_S <= 1;
                araddr_valid <= 0;
            end

            // =========== READ DATA HANDSHAKE ===========
            if (RVALID_S && RREADY_M) begin
                RVALID_S <= 0;
            end
        end
    end
endmodule
