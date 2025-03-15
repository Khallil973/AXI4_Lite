`timescale 1ns/1ps

module axi4_tb;

    reg clk;
    reg arst_n;

    // Write Address Channel
    reg [31:0] AWADDR_M;
    reg AWVALID_M;
    wire AWREADY_S;
    reg AWREADY_S_in,WREADY_S_in;

    // Write Data Channel
    reg [31:0] WDATA_M;
    reg WVALID_M;
    wire WREADY_S;

    // Write Response Channel
    wire [1:0] BRESP_S;
    wire BVALID_S;
    reg BREADY_M;

    // Read Address Channel
    reg [31:0] ARADDR_M;
    reg ARVALID_M;
    wire ARREADY_S;

    // Read Data Channel
    wire [31:0] RDATA_S;
    wire RVALID_S;
    reg RREADY_M;

    // Instantiate the DUT (Device Under Test)
    axi4lite_slave dut (
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

    // Clock Generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        arst_n = 0;
        AWADDR_M = 0;
        AWVALID_M = 0;
        WDATA_M = 0;
        WVALID_M = 0;
        BREADY_M = 0;
        ARADDR_M = 0;
        ARVALID_M = 0;
        RREADY_M = 0;
        WREADY_S_in <= 0;
        AWREADY_S_in <= 0;

        // Reset sequence
        #20;
        arst_n = 1;

        // Perform write transaction
        write_transaction(32'h04, 32'hDEADBEEF);

        // Perform read transaction
        read_transaction(32'h04);

        // Finish simulation
        #100;
        $finish;
    end

    // ======== TASK: WRITE TRANSACTION ========
    task write_transaction(input [31:0] addr, input [31:0] data);
    begin
        $display("Starting Write Transaction to address: %h with data: %h", addr, data);

        // Address phase
        @(posedge clk);
        AWADDR_M <= addr;
        #5;
//        AWVALID_M <= 1;
        AWREADY_S_in <= 1'b1;
     //   while (!AWREADY_S) @(posedge clk);
        $display("Address Phase Completed");
   //     AWVALID_M <= 0;

        // Data phase
        @(posedge clk);
        WDATA_M <= data;
        WVALID_M <= 1;
        #5;
        WREADY_S_in <= 1;

 //       while (!WREADY_S) @(posedge clk);
        $display("Data Phase Completed");
        WVALID_M <= 0;

        // Response phase
        @(posedge clk);
        BREADY_M <= 1;
        while (!BVALID_S) @(posedge clk);
        $display("Write Response Received: BRESP_S = %b", BRESP_S);
        $display("Write Transaction Completed at address: %h with data: %h", addr, data);
        BREADY_M <= 0;
    end
    endtask

    // ======== TASK: READ TRANSACTION ========
    task read_transaction(input [31:0] addr);
    begin
        $display("Starting Read Transaction from address: %h", addr);

        // Address phase
        @(posedge clk);
        ARADDR_M <= addr;
        ARVALID_M <= 1;
        while (!ARREADY_S) @(posedge clk);
        $display("Address Phase Completed");
        ARVALID_M <= 0;

        // Data phase
        @(posedge clk);
        RREADY_M <= 1;
        while (!RVALID_S) @(posedge clk);
        $display("Read Data Received: %h", RDATA_S);
        $display("Read Transaction Completed from address: %h with data: %h", addr, RDATA_S);
        RREADY_M <= 0;
    end
    endtask


/*
    // Optional: Monitor handshakes (for debugging)
    initial begin
        $monitor("Time=%0t | AWVALID=%b AWADDR_M=%b AWREADY=%b | WVALID=%b WDATA=%08h WREADY=%b | BVALID=%b BRESP=%b BREADY=%b | ARVALID=%b ARADDR=%b ARREADY=%b | RVALID=%b RREADY=%b | RDATA=%h")
            $time, AWVALID_M, AWADDR_M, AWREADY_S, WVALID_M, WDATA_M, WREADY_S, BVALID_S, BRESP_S, BREADY_M, ARVALID_M, ARREADY_S ARREADY_S, RVALID_S, RREADY_M, RDATA_S);
    end

*/
endmodule
