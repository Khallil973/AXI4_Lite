`include "master.v"
`include "slave.v"

module axi_lite_top (
    input wire clk,
    input wire arst_n,
    input wire start_write,
    input wire start_read,
    input wire [31:0] write_data,
    input wire [31:0] write_address_M,
    input wire [31:0] read_address,
    output wire [31:0] read_data,
    output wire write_done,
    output wire read_done
);

    // Internal signals to connect master and slave
    wire [31:0] axi_awaddr;
    wire axi_awvalid;
    wire axi_awready;

    wire [31:0] axi_wdata;
    wire [3:0] axi_wstrb;
    wire axi_wvalid;
    wire axi_wready;

    wire [1:0] axi_bresp;
    wire axi_bvalid;
    wire axi_bready;

    wire [31:0] axi_araddr;
    wire axi_arvalid;
    wire axi_arready;

    wire [31:0] axi_rdata;
    wire [1:0] axi_rresp;
    wire axi_rvalid;
    wire axi_rready;

    // Instantiate the AXI4-Lite Master
    axi_master master (
        .clk(clk),
        .arst_n(arst_n),
        .start_write(start_write),
        .start_read(start_read),
        .write_data(write_data),
        .write_address_M(write_address_M),
        .read_address(read_address),
        .read_data(read_data),
        .write_done(write_done),
        .read_done(read_done),

        // AXI4-Lite Write Address Channel
        .M_AXI_AWADDR(axi_awaddr),
        .M_AXI_AWVALID(axi_awvalid),
        .M_AXI_AWREADY(axi_awready),

        // AXI4-Lite Write Data Channel
        .M_AXI_WDATA(axi_wdata),
        .M_AXI_WSTRB(axi_wstrb),
        .M_AXI_WVALID(axi_wvalid),
        .M_AXI_WREADY(axi_wready),

        // AXI4-Lite Write Response Channel
        .M_AXI_BRESP(axi_bresp),
        .M_AXI_BVALID(axi_bvalid),
        .M_AXI_BREADY(axi_bready),

        // AXI4-Lite Read Address Channel
        .M_AXI_ARADDR(axi_araddr),
        .M_AXI_ARVALID(axi_arvalid),
        .M_AXI_ARREADY(axi_arready),

        // AXI4-Lite Read Data Channel
        .M_AXI_RDATA(axi_rdata),
        .M_AXI_RRESP(axi_rresp),
        .M_AXI_RVALID(axi_rvalid),
        .M_AXI_RREADY(axi_rready)
    );

    // Instantiate the AXI4-Lite Slave
    axi_slave slave (
        .clk(clk),
        .arst_n(arst_n),

        // AXI4-Lite Write Address Channel
        .S_AXI_AWADDR(axi_awaddr),
        .S_AXI_AWVALID(axi_awvalid),
        .S_AXI_AWREADY(axi_awready),

        // AXI4-Lite Write Data Channel
        .S_AXI_WDATA(axi_wdata),
        .S_AXI_WSTRB(axi_wstrb),
        .S_AXI_WVALID(axi_wvalid),
        .S_AXI_WREADY(axi_wready),

        // AXI4-Lite Write Response Channel
        .S_AXI_BRESP(axi_bresp),
        .S_AXI_BVALID(axi_bvalid),
        .S_AXI_BREADY(axi_bready),

        // AXI4-Lite Read Address Channel
        .S_AXI_ARADDR(axi_araddr),
        .S_AXI_ARVALID(axi_arvalid),
        .S_AXI_ARREADY(axi_arready),

        // AXI4-Lite Read Data Channel
        .S_AXI_RDATA(axi_rdata),
        .S_AXI_RRESP(axi_rresp),
        .S_AXI_RVALID(axi_rvalid),
        .S_AXI_RREADY(axi_rready)
    );

endmodule
