module R_File (
    input                   clk,rst,
    input           [4:0]   rs1,rs2,write_reg,
    input                   write_en,

    output logic    [31:0]  read_data1,read_data2,
    input           [31:0]  write_data
);

logic [31:0] r_file_data [31:0];
integer i;

always_ff @( posedge clk ) begin
    if(rst) begin
        for(i = 0; i < 32; i++)begin
            r_file_data[i] <= 0;
        end
    end
    else begin
        if(write_en) begin
            if(write_reg != 5'd0) r_file_data[write_reg] <= write_data;
            else r_file_data[write_reg] <= 0;
        end
        else r_file_data[write_reg] <= r_file_data[write_reg];
    end
end

always_comb begin
    read_data1 = r_file_data[rs1];
    read_data2 = r_file_data[rs2];
end


    
endmodule
