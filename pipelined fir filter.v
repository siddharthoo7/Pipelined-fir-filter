module filter_16tap(clk,din ,dout ,reset);
	input clk,reset;
	input signed [15:0]din;
	output signed [31:0]dout;
	
	parameter depth=16;
	
	
	wire signed [31:0]am[15:0];	        //multiplier output wire
	wire signed [31:0]add_out[15:0];	//adder output wire
	wire signed [31:0]q[15:0];			// latch or ff output wire
	wire signed [31:0]bm[15:0];			// pipelined register
	
	assign q[0]=31'd0;
	
	// filter coefficients 
	
	wire signed [15:0]c[15:0];	
	
	assign  c[0]=16'b1_111110110001001;			//-0.019268
	assign  c[1]=16'b0_000010010110011;			//0.0367335
	assign  c[2]=16'b0_000011000100000;			//0.0478669
	assign  c[3]=16'b1_111110011101111;			//-0.0239608
	assign  c[4]=16'b1_111010001101010;			//-0.0905421
	assign  c[5]=16'b1_111110101110100;			//-0.0199179
	assign  c[6]=16'b0_001100011101101;			//0.1947536
	assign  c[7]=16'b0_011000111110001;			//0.3901887
	assign  c[8]=16'b0_011000111110001;			//0.3901887
	assign  c[9]=16'b0_001100011101101;			//0.1947536
	assign  c[10]=16'b1_111110101110100;		//-0.0199179
	assign  c[11]=16'b1_111010001101010;		//-0.0905421
	assign  c[12]=16'b1_111110011101111;		//-0.0239608
	assign  c[13]=16'b0_000011000100000;		//0.0478669
	assign  c[14]=16'b0_000010010110011;		//0.0367335
	assign  c[15]=16'b1_111110110001001;		//-0.019268


	
	// multipliers 
	
	genvar i;
	generate 
		for(i=0;i<depth;i=i+1)	begin
		multi mt(am[i],din,c[i]);
		
		end
	endgenerate
	
	// adder
	
	genvar j;
	generate
			for(j=0;j<depth;j=j+1)	begin
			assign add_out[j]=bm[j]+q[j];
			
				end
	endgenerate
	
	// latches
	
	genvar k;
	generate 
			for(k=0;k<depth-1;k=k+1)	begin
			DFF dff(clk,reset,add_out[k],q[k+1]);
			end
	endgenerate
	
    genvar e;
	generate 
			for(e=0;e<depth;e=e+1)	begin
			DFF dff(clk,reset,am[e],bm[e]);
			end
	endgenerate
	
	// output assignment	
	assign dout=add_out[15];
	
endmodule


// latch 
module DFF (clk,reset,d,q);
	input clk,reset;
	input signed  [31:0]d;
	output reg signed  [31:0]q;
	
	always @(posedge clk) begin
		if(reset)
		q<=31'd0;
		else 
		q<=d;
	end
endmodule


// multiplication
module multi (m,a,b);
	input signed  [15:0] a,b;
	output signed [31:0] m;
	assign m=a*b;
endmodule




module testbench();
	parameter SF1=2.0**-8.0;
	parameter SF2=2.0**-23.0;
	
	reg clk,reset;
	reg signed [15:0]data_in;
	wire signed [31:0]data_out;
	
	
	filter_16tap dut(.clk(clk),.reset(reset),.din(data_in),.dout(data_out));
	
	//  clock Generation
    initial begin
				clk=1'b0;
				reset=1'b1;
				#7 reset=1'b0;
				#350 $finish;
			end
			
    always #5 clk =~clk;

		initial begin
	#2 data_in=16'b0000_0000_0000_0000;//0
	
	#7 data_in=16'b0000_0000_0000_0000;//0
	#13 data_in=16'b0000_0000_0000_0000;//0
	#7 data_in=16'b00000001_00000000;//1
	#13 data_in=16'b00000010_00000000;//2
	#7 data_in=16'b00000011_00000000;//3
	#13 data_in=16'b00000100_00000000;//4
	#7 data_in=16'b00000101_00000000;//5
	#13 data_in=16'b00000110_00000000;//6
	#7 data_in=16'b00000111_00000000;//7
	#13 data_in=16'b11111111_00000000;//-1
	#7 data_in=16'b11111110_00000000;//-2
	#13 data_in=16'b11111101_00000000;//-3
	#7 data_in=16'b11111100_00000000;//-4
	#13 data_in=16'b11111011_00000000;//-5
	#7 data_in=16'b11111010_00000000;//-6
	#13 data_in=16'b11111001_00000000;//-7
	#7 data_in=16'b11111000_00000000;//-8
	#13 data_in=16'b00000000_00000000;//0
	#7 data_in=16'b00000000_00000000;//0
	
	end
	
	always @(posedge clk) 
	$display($time," data_in= %f , data_out= %f",(data_in*SF1),(data_out*SF2));

endmodule