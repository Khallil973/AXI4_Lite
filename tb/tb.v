`timescale 1ns / 1ps

module axi_lite_tb;

    reg clk;
    reg arst_n;
    reg [31:0] write_data;
    reg [31:0] write_address_M;
    reg [31:0] read_address;
    wire [31:0] read_data;
    wire write_done;
    wire read_done;

    reg write_trigger;  // Control signal to trigger write
    reg read_trigger;   // Control signal to trigger read
    reg start_write;
    reg start_read;

    // Instantiate the AXI4-Lite top module
    axi_lite_top uut (
        .clk(clk),
        .arst_n(arst_n),
        .start_write(start_write),
        .start_read(start_read),
        .write_data(write_data),
        .write_address_M(write_address_M),
        .read_address(read_address),
        .read_data(read_data),
        .write_done(write_done),
        .read_done(read_done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Generate `start_write` with respect to clk
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n)
            start_write <= 0;
        else if (write_trigger)
            start_write <= 1;   // Enable for 1 clock cycle
        else
            start_write <= 0;   // Auto-disable after 1 clock
    end

    // Generate `start_read` with respect to clk
    always @(posedge clk or negedge arst_n) begin
        if (!arst_n)
            start_read <= 0;
        else if (read_trigger)
            start_read <= 1;   // Enable for 1 clock cycle
        else
            start_read <= 0;   // Auto-disable after 1 clock
    end

    // Main Test Cases
    initial begin
        // Initialize signals
        clk = 0;
        arst_n = 0;
        write_trigger = 0;
        read_trigger = 0;
        write_data = 32'h00000000;
        write_address_M = 32'h00000000;
        read_address = 32'h00000000;

        // Reset
        #10 arst_n = 1;
        $display(" System Reset Done.");

        // CASE 1: Simple Write & Read Transaction
        #10;
        $display(" [Test Case 1] Valid Write Operation");
        write_address_M = 32'h00000010;
        write_data = 32'hA5A5A5A5;
        write_trigger = 1;  // Trigger Write
        #10 write_trigger = 0;

        while (!write_done) #5;
        $display(" Write Operation Completed.");

        #10;
        $display(" [Test Case 1] Valid Read Operation");
        read_address = 32'h00000010;
        read_trigger = 1;  // Trigger Read
        #10 read_trigger = 0;

        while (!read_done) #5;
        $display(" Read Operation Completed. Read Data: %h", read_data);

        // CASE 2: Write & Read from Different Addresses
        #20;
        $display(" [Test Case 2] Writing to Different Address");
        write_address_M = 32'h00000020;
        write_data = 32'h12345678;
        write_trigger = 1;
        #10 write_trigger = 0;

        while (!write_done) #5;
        $display(" Write to Different Address Completed.");

        #10;
        $display(" [Test Case 2] Reading from New Address");
        read_address = 32'h00000020;
        read_trigger = 1;
        #10 read_trigger = 0;

        while (!read_done) #5;
        $display(" Read Operation Completed. Read Data: %h", read_data);

        // CASE 3: Unaligned Write (Invalid Address)
        #20;
        $display("[Test Case 3] Attempting Unaligned Write");
        write_address_M = 32'h00000013; // Unaligned address
        write_data = 32'hCAFEBABE;
        write_trigger = 1;
        #10 write_trigger = 0;

        while (!write_done) #5;
        $display(" Write to Unaligned Address Completed");

        // CASE 4: Read from Unmapped Address (Invalid Read)
        #20;
        $display(" [Test Case 4] Reading from Unmapped Address");
        read_address = 32'h0000FFFF; // Invalid address
        read_trigger = 1;
        #10 read_trigger = 0;

        while (!read_done) #5;
        $display(" Read from Unmapped Address Completed");

        // CASE 5: Back-to-Back Writes & Reads
        #20;
        $display(" [Test Case 5] Back-to-Back Writes");
        write_address_M = 32'h00000030;
        write_data = 32'h11223344;
        write_trigger = 1;
        #10 write_trigger = 0;

        write_address_M = 32'h00000040;
        write_data = 32'h55667788;
        write_trigger = 1;
        #10 write_trigger = 0;

        while (!write_done) #5;
        $display(" Back-to-Back Writes Completed.");

        #10;
        $display(" [Test Case 5] Back-to-Back Reads");
        read_address = 32'h00000030;
        read_trigger = 1;
        #10 read_trigger = 0;

        read_address = 32'h00000040;
        read_trigger = 1;
        #10 read_trigger = 0;

        while (!read_done) #5;
        $display(" Back-to-Back Reads Completed. Last Read Data: %h", read_data);

        // End Simulation
        #50;
        $display("All Test Cases Executed Successfully!");
        $finish;
    end

    // Waveform Generation
    initial begin
        $dumpfile("axi_lite.vcd");
        $dumpvars(0, uut);
    end

endmodule
