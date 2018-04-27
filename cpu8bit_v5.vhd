library iEEE;
use iEEE.STD_LOGiC_1164.all;
use iEEE.STD_LOGiC_ARiTH.all;
use iEEE.STD_LOGiC_UNSIGNED.all;

 entity cpu8bit is
        port (	 rst:	in	std_logic;
                clk:	in	std_logic;
           segments : out std_logic_vector(7 downto 0);
                an : out std_logic_vector(3 downto 0);
           pb: in std_logic;
			  pb_dsp: std_logic
);                
 end;

 architecture CPU_ARCH of cpu8bit is 
  type IM is array ( 255 downto 0) of std_logic_vector(15 downto 0);  
  signal I_mem: IM ;
  type RF is array ( 15 downto 0) of std_logic_vector(7 downto 0);    
  signal reg_file: RF;
  attribute keep : string;
  signal W : std_logic_vector(7 downto 0);
  signal IR : std_logic_vector(15 downto 0); 
  ---s_reset(0000),s_fetch(0001), s_decode(0010), s_execute(0100), s_store(1000)---------------------------------------------------------------
  signal n_s,p_s : std_logic_vector(3 downto 0) ;
  signal opcode : std_logic_vector (3 downto 0);
  signal RA : std_logic_vector (3 downto 0);                                              
  signal RB : std_logic_vector (3 downto 0);                           
  signal RD : std_logic_vector (3 downto 0);     
  ---------------------------------------------------------------------------------------------------------------
  signal PC: std_logic_vector(7 downto 0) ;
  signal reg_file_seg: std_logic_vector(7 downto 0);
    attribute keep of p_s: signal is "true"; 
  
--  ----------------------------------------------------------------------------------------------------------------
   signal count1kHz,count1Hz: integer range 50000000 downto 0 := 0;
    signal seg_dig,cnt_dsp_mux: integer range 3 downto 0;
	  signal clk_1kHz,clk_1Hz : std_logic;
	  signal cnt: std_logic_vector(1 downto 0);
	  signal cnt_dsp: std_logic_vector(2 downto 0);
	  signal pulse,pulse_dsp: std_logic;
    signal dec_data1,dec_data2,dec_data3,dec_data4: std_logic_vector(3 downto 0);
    signal data1,data2,data3,data4: std_logic_vector(7 downto 0);
	 signal disp_ar: std_logic_vector(15 downto 0);
	 signal pc_inc_cnt: integer range 3 downto 0;
	 signal rst_inc_cnt: integer range 1 downto 0;
  
  
  Begin
  
--  ---DISPLAY process---------------------------------
  Segment_proc: process(clk_1kHz,data1,data2)
  Begin
      if (clk_1kHz'event and clk_1kHz = '1') then
       if seg_dig=0 then
       an <= "0111";
       segments <= data4;
       seg_dig <= 1;
       elsif seg_dig=1 then
       an <= "1011";
       segments <= data3;
       seg_dig <= 2;
		 elsif seg_dig=2 then
		 an <= "1101";
       segments <= data2;
       seg_dig <= 3;
		 elsif seg_dig=3 then
		 an <= "1110";
       segments <= data1;
       seg_dig <= 0;		 
       end if;
      end if;
  end process;
  
  disp_mux: process(PC,reg_file_seg,IR,opcode,pulse_dsp)  ----cnt_dsp_mux=1(PC),cnt_dsp_mux=2(reg_file_Seg),cnt_dsp_mux=3(IR),cnt_dsp_mux=4(opcode)
  begin
	  if (pulse_dsp'event and pulse_dsp = '1') then
		 if cnt_dsp_mux = 0 then
			  disp_ar <= "00000000" & PC;
			  cnt_dsp_mux <= cnt_dsp_mux +1;
		 elsif cnt_dsp_mux =1 then
			  disp_ar <= "00000000" & reg_file_seg;
			  cnt_dsp_mux <= cnt_dsp_mux +1;
		 elsif cnt_dsp_mux =2 then
			  disp_ar <= IR;
			  cnt_dsp_mux <= cnt_dsp_mux +1;
		 elsif cnt_dsp_mux =3 then
			  disp_ar <= "000000000000" & opcode;
			  cnt_dsp_mux <= 0 ;
		 end if;
	  else
		 disp_ar <= disp_ar;
	  end if;
  end process disp_mux;		 
  
  
  output_decoder: process(disp_ar) is
  begin
      dec_data1 <= disp_ar(3 downto 0);
      if  dec_data1 = "0000" then
          data1 <= "00000011";
         elsif dec_data1 = "0001" then
          data1 <= "10011111";
         elsif dec_data1 = "0010" then
          data1 <= "00100101";
         elsif dec_data1 = "0011" then
          data1 <= "00001101";
         elsif dec_data1 = "0100" then
          data1 <= "10011001";
         elsif dec_data1 = "0101" then
          data1 <= "01001001";
         elsif dec_data1 = "0110" then
          data1 <= "01000001";
         elsif dec_data1 = "0111" then
          data1 <= "00011111";
         elsif dec_data1 = "1000" then
          data1 <= "00000001";
         elsif dec_data1 = "1001" then
          data1 <= "00001001";
			elsif dec_data1 = "1010" then
          data1 <= "00010001";
			elsif dec_data1 = "1011" then
			 data1 <= "11000001";
			elsif dec_data1 = "1100" then
			 data1 <= "01100011";
			elsif dec_data1 = "1101" then
			 data1 <= "10000101";
			elsif dec_data1 = "1110" then
			 data1 <= "01100001";
			elsif dec_data1 = "1111" then
			 data1 <= "01110001";			 
      end if;
		dec_data2 <= disp_ar(7 downto 4);
      if  dec_data2 = "0000" then
          data2 <= "00000011";
         elsif dec_data2 = "0001" then
          data2 <= "10011111";
         elsif dec_data2 = "0010" then
          data2 <= "00100101";
         elsif dec_data2 = "0011" then
          data2 <= "00001101";
         elsif dec_data2 = "0100" then
          data2 <= "10011001";
         elsif dec_data2 = "0101" then
          data2 <= "01001001";
         elsif dec_data2 = "0110" then
          data2 <= "01000001";
         elsif dec_data2 = "0111" then
          data2 <= "00011111";
         elsif dec_data2 = "1000" then
          data2 <= "00000001";
         elsif dec_data2 = "1001" then
          data2 <= "00001001";
			elsif dec_data2 = "1010" then
          data2 <= "00010001";
			elsif dec_data2 = "1011" then
			 data2 <= "11000001";
			elsif dec_data2 = "1100" then
			 data2 <= "01100011";
			elsif dec_data2 = "1101" then
			 data2 <= "10000101";
			elsif dec_data2 = "1110" then
			 data2 <= "01100001";
			elsif dec_data2 = "1111" then
			 data2 <= "01110001";			 
      end if;
		dec_data3 <= disp_ar(11 downto 8);
      if  dec_data3 = "0000" then
          data3 <= "00000011";
         elsif dec_data3 = "0001" then
          data3 <= "10011111";
         elsif dec_data3 = "0010" then
          data3 <= "00100101";
         elsif dec_data3 = "0011" then
          data3 <= "00001101";
         elsif dec_data3 = "0100" then
          data3 <= "10011001";
         elsif dec_data3 = "0101" then
          data3 <= "01001001";
         elsif dec_data3 = "0110" then
          data3 <= "01000001";
         elsif dec_data3 = "0111" then
          data3 <= "00011111";
         elsif dec_data3 = "1000" then
          data3 <= "00000001";
         elsif dec_data3 = "1001" then
          data3 <= "00001001";
			elsif dec_data3 = "1010" then
          data3 <= "00010001";
			elsif dec_data3 = "1011" then
			 data3 <= "11000001";
			elsif dec_data3 = "1100" then
			 data3 <= "01100011";
			elsif dec_data3 = "1101" then
			 data3 <= "10000101";
			elsif dec_data3 = "1110" then
			 data3 <= "01100001";
			elsif dec_data3 = "1111" then
			 data3 <= "01110001";			 
      end if;
		dec_data4 <= disp_ar(15 downto 12);
      if  dec_data4 = "0000" then
          data4 <= "00000011";
         elsif dec_data4 = "0001" then
          data4 <= "10011111";
         elsif dec_data4 = "0010" then
          data4 <= "00100101";
         elsif dec_data4 = "0011" then
          data4 <= "00001101";
         elsif dec_data4 = "0100" then
          data4 <= "10011001";
         elsif dec_data4 = "0101" then
          data4 <= "01001001";
         elsif dec_data4 = "0110" then
          data4 <= "01000001";
         elsif dec_data4 = "0111" then
          data4 <= "00011111";
         elsif dec_data4 = "1000" then
          data4 <= "00000001";
         elsif dec_data4 = "1001" then
          data4 <= "00001001";
			elsif dec_data4 = "1010" then
          data4 <= "00010001";
			elsif dec_data4 = "1011" then
			 data4 <= "11000001";
			elsif dec_data4 = "1100" then
			 data4 <= "01100011";
			elsif dec_data4 = "1101" then
			 data4 <= "10000101";
			elsif dec_data4 = "1110" then
			 data4 <= "01100001";
			elsif dec_data4 = "1111" then
			 data4 <= "01110001";			 
      end if;
  end process output_decoder;
 
 debouncer_st:PROCESS (clk_1Hz,pb,cnt) is
  BEGIN
       IF pb = '1' THEN
        cnt <= "00";
       ELSIF (clk_1Hz'EVENT AND clk_1Hz = '1') THEN
        IF (cnt /= "11") THEN cnt <= cnt + 1; END IF;
       END IF;
       IF ((cnt = "10") AND (pb = '0'))  THEN pulse <= '1'; ELSE pulse <= '0'; END IF;
   END PROCESS debouncer_st;
 
  debouncer_st_dsp:PROCESS (clk_1Hz,pb_dsp,cnt_dsp) is
  BEGIN
       IF pb_dsp = '1' THEN
        cnt_dsp <= "000";
       ELSIF (clk_1Hz'EVENT AND clk_1Hz = '1') THEN
        IF (cnt_dsp /= "111") THEN cnt_dsp <= cnt_dsp + 1; END IF;
       END IF;
       IF ((cnt_dsp = "110") AND (pb_dsp = '0'))  THEN pulse_dsp <= '1'; ELSE pulse_dsp <= '0'; END IF;
   END PROCESS debouncer_st_dsp;
  
  div_1kHz: process(clk) is
   begin
     if (clk'EVENT AND clk = '1') then
       if count1kHz = 50000 then
        count1kHz <= 0;
        clk_1kHz <='1';
       else
        count1kHz <= count1kHz + 1;
        clk_1kHz <='0';
       end if;
      end if;
   end process div_1kHz;
  
   div_1Hz: process(clk) is
   begin
     if (clk'EVENT AND clk = '1') then
       if count1Hz = 2 then
        count1Hz <= 0;
        clk_1Hz <='1';
       else
        count1Hz <= count1Hz + 1;
        clk_1Hz <='0';
       end if;
      end if;
   end process div_1Hz;


  --------------------------------------------------------------------------
    
   cpu_cycle_seq: process(clk_1Hz,rst)
        begin                    
          if (rst = '1') then 
                p_s <= "0000";                                                  
          elsif(clk_1Hz'event and clk_1Hz = '1') then
                p_s <= n_s;
          end if;			
        end process;
        
   cpu_cycle_comb:process(p_s) 
         begin   
                case p_s is
                     when "0000" =>
                           n_s <= "0001";
                     when "0001" => 
                           n_s <= "0010";										 
                     when "0010" =>
                          n_s <= "0100";									
                     when "0100" =>
                          n_s <= "1000";							  
                     when "1000" =>         
                          n_s <= "0001";	
                     when others => null;						 
                end case;	
    
        end process;
	 
	 fetch_proc: process(clk_1Hz,rst,PC)
	 begin
	 if(rst = '1') then
              I_mem(255 downto 16) <=(others => (others =>'0'));
              I_mem(0) <= "0001000000000000";         ---- Clear R0
				  I_mem(1) <= "0001000000000101";         ---- Clear R5				  
				  I_mem(2) <= "0001000000000110";         ---- Clear R6
              I_mem(3) <= "0001001001000001";         ---- Load immediate into R1 (value = 24)
              I_mem(4) <= "0001000110110010";         ---- Load immediate into R2 (value = 1B)
              I_mem(5) <= "0010000100100011";         ---- Add R1 and R2 and store in R3
              I_mem(6) <= "1000001000110100";         ---- XOR - R2 and R3 into R4
              I_mem(7) <= "0100001000010111";         ---- OR - R2 and R1 into R7
				  I_mem(8) <= "0001100101001000";         ---- Load immediate into R8 (value = 94)
              I_mem(9) <= "0001010110111001";         ---- Load immediate into R9 (value = 5B)
				  I_mem(10) <= "0001001101011010";         ---- Load immediate into R10 (value = 35)
				  I_mem(11) <= "0001011000011011";         ---- Load immediate into R11 (value = 61)
              I_mem(12) <= "0010100010010101";         ---- Add R8 and R9 and store in R5
              I_mem(13) <= "1000101010110000";         ---- XOR - R10 and R11 into R0
              I_mem(14) <= "0100100010100110";         ---- OR - R8 and R10 into R6
				  I_mem(15) <= "0000000000000000";         ---- HALT (end the program)
				  
              IR <= (others =>'0');
	 elsif(clk_1Hz'event and clk_1Hz = '1') then
              IR <= I_mem(conv_integer(PC));
    end if;
	 
	 end process;
	 
	 decode_proc: process(clk_1Hz,rst,pulse)
	 begin
	 if(rst = '1') then
            opcode <= (others => '0');
				RA <= (others => '0');
				RB <= (others => '0');
				RD <= (others => '0');
				PC <= (others => '0');
				pc_inc_cnt <= 0;
				rst_inc_cnt <=0;
	 elsif(clk_1Hz'event and clk_1Hz = '1') then
	    if (pulse = '1') then
	       if pc_inc_cnt = 3 then
				 PC <= PC + "00000001";
			    pc_inc_cnt <= 0;
		     elsif(rst_inc_cnt = 0)then
			    pc_inc_cnt <= 0;
				 rst_inc_cnt <= 1;
			  else				 
				 pc_inc_cnt <= pc_inc_cnt + 1;
		     end if;
	    else
		     PC <= PC;
			  pc_inc_cnt <= pc_inc_cnt;
       end if;				 
		    opcode <= IR(15 downto 12);
			 RA <= IR(11 downto 8);
			 RB <= IR(7 downto 4);
			 RD <= IR(3 downto 0);
	 end if;
	 end process;
	 
	 
	 ALU_proc: process(clk_1Hz,rst,opcode,RA,RB,reg_file)
	 begin
	 if(rst = '1') then
            W <= (others => '0');
	 elsif(clk_1Hz'event and clk_1Hz = '1') then
	        case(opcode) is
                         when "0001" =>
                          W <= RA & RB;
                         when "0010" =>
                          W <= reg_file(conv_integer(RA)) + reg_file(conv_integer(RB));
                         when "0100" =>
                          W <= reg_file(conv_integer(RA)) or reg_file(conv_integer(RB));
                         when "1111" =>
                          W <= reg_file(conv_integer(RA)) xor reg_file(conv_integer(RB));
                         when "0000" =>
                          W <= "00000000";
                         when others => null;
                       end case;
	 end if;
	 end process;
	 
	 store_proc: process(clk_1Hz,rst,opcode,RD,W)
	 begin
	 if(rst = '1') then
				reg_file <= (others => (others =>'0'));
	 elsif(clk_1Hz'event and clk_1Hz = '1') then
	         reg_file(conv_integer(RD)) <= W;
            reg_file_seg <= W;
	 end if;
	 end process;

	

    end CPU_ARCH; 
