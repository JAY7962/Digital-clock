module Digital_Clock(
    input clk,
    input reset,
    input set_time,
    input set_time_unchnged,
    input [5:0] set_min,
    input [5:0] set_sec,
    input up,
    input down,
    input set_alarm,
    input left,
    input right,
    input stop_watch,
    input timer,
    input start,
    input stop,
    output led,
    output reg [3:0] Anode_Activation,
    output reg [6:0] Cathode_Activation,
    output reg [4:0] hrs     
);
    reg [6:0] secs;
    reg [6:0] mins;
    reg [6:0] hrs2=0;
    reg [6:0] secs2=0;
    reg [6:0] mins2=0;
    reg [6:0] hrs3=0;
    reg [6:0] secs3=0;
    reg [6:0] mins3=0;
    reg [5:0] hrs9;
    reg [6:0] secs4=0;
    reg [5:0] mins4=0;
    reg led=0;
    reg [3:0]count=11;
    wire clk_1Hz;
    wire clk_100Hz;
    buttons up2(clk,up,up1);
    buttons down2(clk,down,down1);
    // New register for storing set time hours
    clock_divider cd(clk, clk_1Hz);
    clk_divider cd1(clk,clk_100Hz);

    always @(posedge clk_1Hz) begin
        if (reset) begin // Reset or set time enable
            secs2 <= 0;
            mins2 <= 0;
            hrs2 <= 0;
            led<=0;
        end
        else begin              
                secs2 <= secs2 + 1;
                if (secs2 == 59) begin
                    secs2 <= 0;
                    mins2 <= mins2 + 1;
                    if (mins2 == 59) begin
                        mins2 <= 0;
                        hrs2 <= hrs2 + 1;
                        if (hrs2 == 23) begin
                            hrs2<=0;
                        end
                    end
                end
            end
     if(!stop_watch)begin
           if(!set_time && !timer && !set_time_unchnged)begin
             hrs<=hrs2;
             mins<=mins2;
             secs<=secs2;
           end
           else if(set_time) begin
                secs2<=secs;
                if(!right && up1) begin
                    if(mins2==59 && hrs2==23) begin
                        mins2 <= 0;
                        hrs2<=0;
                        mins <= 0;
                        hrs<=0;
                    end
                    else if(mins2==59) begin
                        mins2 <= 0;
                        hrs2<=hrs2+1;
                        mins <= 0;
                        hrs<=hrs+1;
                    end
                    else begin
                        mins2 <= mins2 + 1;
                        mins <= mins + 1;
                    end
                end
                if(right && up1) begin
                    if(hrs2==23) begin
                        hrs2<=0; 
                        hrs<=0;                  
                    end
                    else begin
                        hrs2 <= hrs2 + 1;
                        hrs <= hrs + 1;
                    end
                end
                
                if(!right && down1) begin
                    if(mins2==0 && hrs2==0) begin
                        mins2 <= 59;
                        hrs2<=23;
                        mins <= 59;
                        hrs<=23;
                    end
                    else if(mins2==0) begin
                        mins2 <= 59;
                        hrs2<=hrs2-1;
                        mins <= 59;
                        hrs<=hrs-1;
                    end
                    else begin
                        mins2 <= mins2 - 1;
                        mins <= mins - 1;
                    end
                end
                if(right && down1) begin
                    if(hrs2==0) begin
                        hrs2<=23; 
                        hrs<=23;                  
                    end
                    else begin
                        hrs2 <= hrs2 - 1;
                        hrs <= hrs - 1;
                    end
                end
            end
            
            else if(set_time_unchnged) begin
            if(timer)begin
            if(!(mins==0 && secs==0))begin
              if(secs==0)begin
                secs<=59;
                mins<=mins-1;      
              end
              else secs<=secs-1;
             end 
             end 
             else if(set_alarm) begin
                mins3 <= mins;
                secs3 <= secs;
                hrs3 <= hrs;
             end
              else if(!right && up1) begin
                    if(mins==59) begin
                        mins <= 0;
                        hrs<=hrs+1;
                    end
                    else begin
                        mins <= mins + 1;
                    end
                end
                if(right && up1) begin
                    if(hrs==23) begin
                        hrs <= 0;
                    end
                    else begin
                        hrs <= hrs + 1;
                    end
                end
            end
        if(set_alarm ==1 && hrs2 == hrs3 && mins2 == mins3 && secs2 == secs3) begin
            led <= 1;
            count<=0;
        end
        if(count<=10) begin
            if(count %2==0) begin
                led <= 0;
            end
            if(count %2==1) begin
                led <= 1;
            end
            count <= count +1;
        end
        end
        end
      always@(posedge clk_100Hz) begin
            if(stop_watch && !start && !stop)begin
              secs4<=0;
              mins4<=0;
              hrs9<=0;
            end
            else if(stop_watch && start && !stop) begin
                secs4<= secs4+1;
                if(secs4==99) begin
                    secs4<=0;
                    mins4<=mins4+1;
                    if(mins4==59) begin
                        mins4<=0;
                        hrs9<=hrs9+1'b1;
                        /*if(hrs4==59) begin
                            hrs4<=0;
                        end*/
                    end
                end
             end
           /*if(stop_watch && start && !stop)begin
              secs4<=secs4+1;
              if(secs4==99)begin
                 secs4<=0;
                 mins4<=mins4+1;
                 if(mins4==59)begin
                   mins4<=0;
                   hrs4<=hrs4+1;
                 end
              end
           end */   
        end

    reg [3:0] LED_BCD;
    reg [19:0] refresh_counter;
    wire [1:0] LED_activation_counter;

    always @(posedge clk or posedge reset) begin
        if (reset == 1) begin
            refresh_counter <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end
    assign LED_activation_counter = refresh_counter[19:18];

    always @(*) begin
        case(LED_activation_counter)
            2'b00: begin
                Anode_Activation = 4'b0111; 
                // activate LED1 and Deactivate LED2, LED3, LED4
                if(!stop_watch)begin
                LED_BCD = mins/10;
                end
                if(stop_watch)begin
                LED_BCD = mins4/10;
                end
                // the first digit of the 16-bit number
            end
            2'b01: begin
                Anode_Activation = 4'b1011; 
                // activate LED2 and Deactivate LED1, LED3, LED4
                if(!stop_watch)begin
                LED_BCD = mins %10;
                end
                if(stop_watch)begin
                LED_BCD = mins4 % 10;
                end
                // the second digit of the 16-bit number
            end
            2'b10: begin
                Anode_Activation = 4'b1101; 
                // activate LED3 and Deactivate LED2, LED1, LED4
                if(!stop_watch)begin
                LED_BCD = secs/10;
                end
                if(stop_watch)begin
                LED_BCD = secs4/10;
                end
                // the third digit of the 16-bit number
            end
            2'b11: begin
                Anode_Activation = 4'b1110; 
                // activate LED4 and Deactivate LED2, LED3, LED1
               if(!stop_watch)begin
                LED_BCD = secs %10;
                end
                if(stop_watch)begin
                LED_BCD = secs4%10;
                end
                // the fourth digit of the 16-bit number    
            end
        endcase
    end
    
    always @(*) begin
        case(LED_BCD)
            4'b0000: Cathode_Activation = 7'b0000001; // "0"     
            4'b0001: Cathode_Activation = 7'b1001111; // "1" 
            4'b0010: Cathode_Activation = 7'b0010010; // "2" 
            4'b0011: Cathode_Activation = 7'b0000110; // "3" 
            4'b0100: Cathode_Activation = 7'b1001100; // "4" 
            4'b0101: Cathode_Activation = 7'b0100100; // "5" 
            4'b0110: Cathode_Activation = 7'b0100000; // "6" 
            4'b0111: Cathode_Activation = 7'b0001111; // "7" 
            4'b1000: Cathode_Activation = 7'b0000000; // "8"     
            4'b1001: Cathode_Activation = 7'b0000100; // "9" 
            default: Cathode_Activation = 7'b0000001; // "0"
        endcase
    end
endmodule