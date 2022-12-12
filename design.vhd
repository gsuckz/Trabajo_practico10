library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ffd_pkg.all;

entity receptor_control_remoto is 
    port (
        rst         :       in std_logic;
        infrarrojo  :       in std_logic;
        hab         :       in std_logic;
        clk         :       in std_logic;
        valido      :       out std_logic;
        dir         :       out std_logic_vector (7 downto 0);
        cmd         :       out std_logic_vector (7 downto 0));

end receptor_control_remoto;

architecture solucion of receptor_control_remoto is 

component ffd is
    generic(
        constant N : natural := 1);
    port(
        rst : in std_logic;
        D   : in std_logic_vector (N-1 downto 0);
        hab : in std_logic;
        clk : in std_logic;
        Q   : out std_logic_vector (N-1 downto 0));
end component;

type tipos_estado is (reset_state, load_dir, load_cmd, check_cmd, check_dir, rep_state);
type codigo is (bit_0, bit_1, inicio, rep, none);

signal cuenta,cuenta_D                          : std_logic_vector (2 downto 0); -- contador de bits recibidos
signal dir_d, cmd_d, dir_out, cmd_out           : std_logic_vector (7 downto 0);   
signal hab_out, hab_L_cmd, hab_L_dir            : std_logic;
signal hab_out_1, hab_L_cmd_1, hab_L_dir_1      : std_logic;
signal bit_dir_selected                         : std_logic;
signal bit_cmd_selected                         : std_logic;
signal rst_clk                                  : std_logic;
signal clk_c, clk_c_d                           : std_logic_vector (7 downto 0);
signal tipo, tipo_d, prev                       : std_logic_vector (1 downto 0);
signal flag,flag2,flag3                         : std_logic;
signal prev_D                                   : std_logic_vector (1 downto 0);
signal valid_count, valid_count_D               : std_logic_vector (7 downto 0);

signal estado,estado_sig                        : tipos_estado;
signal code                                     : codigo;
signal valid,valid_D                            : std_logic_vector ( 0 downto 0);


begin 

--Registros de estado

contador : ffd 
    generic map (N => 3)
    port map( 
        rst => rst,
        hab => hab,
        clk => clk,
        Q => cuenta,
        D => cuenta_D
    );

valid_flag : ffd
    generic map (N=>1)
    port map(
        rst => rst,
        hab => hab,
        clk => clk,
        Q   => valid,
        D   => valid_D
    );

cmd_out_memory : ffd
    generic map (N=>8)
    port map(
        rst => rst,
        hab => hab_out_1,
        clk => clk,
        Q   => cmd,
        D   => cmd_out
    );
hab_out_1   <= hab_out and hab;
hab_L_cmd_1 <= hab_L_cmd and hab;
hab_L_dir_1 <= hab_L_dir and hab;
cmd_R_memory : ffd
    generic map (N=>8)
    port map(
        rst => rst,
        hab => hab_L_cmd_1 ,
        clk => clk,
        Q   => cmd_out,
        D   => cmd_d
    );

cmd_d(6 downto 0) <= cmd_out(7 downto 1);      

dir_out_memory : ffd
    generic map (N=>8)
    port map(
        rst => rst,
        hab => hab_out_1 ,
        clk => clk,
        Q   => dir,
        D   => dir_out
    );

dir_memory : ffd
    generic map (N=>8)
    port map(
        rst => rst,
        hab => hab_L_dir_1 ,
        clk => clk,
        Q   => dir_out,
        D   => dir_d
    );

dir_d(6 downto 0) <= dir_out(7 downto 1);      
    
tipo_clk : ffd
    generic map (N => 2)
    port map( 
        rst => rst,
        hab => hab,
        clk => clk,
        Q => tipo,
        D => tipo_d
    );
    
prev_ff : ffd
    generic map (N => 2)
    port map( 
        rst => rst,
        hab => hab,
        clk => clk,
        Q => prev,
        D => prev_d
    );

valid_counter_ff : ffd 
    generic map (N => valid_count'length)
    port map( 
        rst => rst,
        hab => hab,
        clk => clk,
        Q => valid_count,
        D => valid_count_d
    );    

--Logica Secuencial
process (all)
    begin   
        valid_count_d <= std_logic_vector( unsigned (valid_count) + 1);
        if unsigned (valid_count) + 1 = 0 then 
            valid_count_d <= valid_count;
        end if;
        if valid = "0" then 
            valid_count_d <= (others => '0');
        end if;
    end process;

process (clk, rst)
    begin
        if rst = '1' then
            estado <= reset_state;
        elsif rising_edge(clk) and hab = '1' then            
            estado <= estado_sig;
        end if;
    end process;

process (all)
    begin  
    dir_d(7) <= '0';
    cmd_d(7) <= '0';          
        if code = bit_1  then               
            dir_d(7) <= '1';
            cmd_d(7) <= '1';
        end if;
    end process;

valido <= '1' when valid(0)='1' and not (unsigned (valid_count) <= (70 + 3*20) and code = rep) else '0';


                  
process (all) 
    begin
        case (estado) is
            when rep_state => estado_sig <= reset_state;
                cuenta_D <= (others => '0');
                valid_D <= "1";
                hab_out <= '0';
                hab_L_dir <= '0';
                hab_L_cmd <= '0';


            when reset_state =>
                case (code) is



                    when bit_0 =>       estado_sig <=reset_state;
                                        cuenta_D <= (others => '0');
                                        valid_D <=  valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                    when bit_1 =>       estado_sig <=reset_state;
                                        cuenta_D <= (others => '0');
                                        valid_D <= valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                    when inicio =>      estado_sig <=load_dir;
                                        cuenta_D <= (others => '0');
                                        valid_D <=  (others => '0');
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';



                    when others =>      estado_sig <=reset_state;
                                        cuenta_D <= (others => '0');
                                        valid_D <= valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                end case;

            when load_dir =>
                case (code) is 
                        when (bit_0)  =>        estado_sig <=load_dir;
                                                cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                                                valid_D <= valid;
                                                hab_out     <= '0';
                                                hab_L_dir   <= '1';
                                                hab_L_cmd   <= '0';  
                                                if unsigned (cuenta) = 7 then       
                                                    estado_sig <= check_dir;
                                                    cuenta_d <= (others => '0');
                                                end if;

                        when (bit_1)  =>        estado_sig <=load_dir;
                                                cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                                                valid_D <= valid;
                                                hab_out     <= '0';
                                                hab_L_dir   <= '1';
                                                hab_L_cmd   <= '0';     
                                                if unsigned (cuenta) = 7 then       
                                                    estado_sig <= check_dir;
                                                    cuenta_d <= (others => '0');   
                                                end if;               
  
                        when inicio =>      estado_sig <=load_dir;
                                            cuenta_D <= (others => '0');
                                            valid_D <=valid;
                                            hab_out <= '0';
                                            hab_L_dir <= '0';
                                            hab_L_cmd <= '0';

                        when rep =>         estado_sig <=reset_state;
                                            cuenta_D <= (others => '0');
                                            valid_D <=valid;
                                            hab_out <= '0';
                                            hab_L_dir <= '0';
                                            hab_L_cmd <= '0';

                        when others =>      estado_sig <=load_dir;
                                            cuenta_D <= cuenta;
                                            valid_D <=valid;
                                            hab_out <= '0';
                                            hab_L_dir <= '0';
                                            hab_L_cmd <= '0';  

                end case;


            when check_dir => 
                case (code) is 
                    when bit_0 =>       estado_sig <=check_dir;
                                        cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                                        valid_D <= valid;
                                        hab_out     <= '0';
                                        hab_L_dir   <= '0';
                                        hab_L_cmd   <= '0'; 
                                        if unsigned (cuenta)= 7 then    
                                            estado_sig <= load_cmd;
                                            cuenta_D <= (others => '0');
                                        end if;
                                        if bit_dir_selected  = '0' then     
                                            estado_sig <= reset_state;
                                        end if;

                    when bit_1 =>       estado_sig <=check_dir;
                                        cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                                        valid_D <= valid;
                                        hab_out     <= '0';
                                        hab_L_dir   <= '0';
                                        hab_L_cmd   <= '0'; 
                                        if unsigned (cuenta)= 7 then        
                                            estado_sig <= load_cmd;
                                            cuenta_D <= (others => '0');
                                        end if;
                                        if bit_dir_selected = '1' then      
                                            estado_sig <= reset_state;
                                        end if;

                    when inicio =>      estado_sig <=load_dir;
                                        cuenta_D <= (others => '0');
                                        valid_D <=  (others => '0');
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                    when rep =>         estado_sig <=reset_state;
                                        cuenta_D <= (others => '0');
                                        valid_D <=  (others => '0');
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                    when others =>      estado_sig <=check_dir;
                                        cuenta_D <= cuenta;
                                        valid_D <=  valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';  

                end case;

            when load_cmd => 
                case (code) is 
                    when (bit_0) =>     estado_sig <=load_cmd;
                                        cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                                        valid_D <= valid;
                                        hab_out     <= '0';
                                        hab_L_dir   <= '0';
                                        hab_L_cmd   <= '1';  
                                        if unsigned (cuenta) = 7 then       
                                            estado_sig <= check_cmd;
                                            cuenta_D <= (others => '0');
                                        end if;

                    when (bit_1)   =>   estado_sig <=load_cmd;
                                        cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                                        valid_D <= valid;
                                        hab_out     <= '0';
                                        hab_L_dir   <= '0';
                                        hab_L_cmd   <= '1';  
                                        if unsigned (cuenta) = 7 then       
                                            estado_sig <= check_cmd;
                                            cuenta_D <= (others => '0');
                                        end if;

                    when inicio =>      estado_sig <=load_dir;
                                        cuenta_D <= (others => '0');
                                        valid_D <=valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                    when rep =>         estado_sig <=reset_state;
                                        cuenta_D <= (others => '0');
                                        valid_D <=valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                    when others =>      estado_sig <=load_cmd;
                                        cuenta_D <= cuenta;
                                        valid_D <=valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                end case;

            when check_cmd => 
                case (code) is 
                    when bit_0 =>       estado_sig <=check_cmd;
                                        cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                                        valid_D <= valid;
                                        hab_out     <= '0';
                                        hab_L_dir   <= '0';
                                        hab_L_cmd   <= '0'; 
                                        if unsigned (cuenta) = 7  then      
                                            estado_sig <= reset_state;
                                            valid_D <= (others => '1');           
                                            hab_out<='1';
                                            cuenta_D <= (others => '0');                   
                                        end if;
                                        if bit_cmd_selected  = '0' then     
                                            estado_sig <= reset_state;
                                        end if;

                    when bit_1 =>       estado_sig <=check_cmd;
                                        cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                                        valid_D <= valid;
                                        hab_out     <= '0';
                                        hab_L_dir   <= '0';
                                        hab_L_cmd   <= '0'; 
                                        if unsigned (cuenta) = 7  then      
                                            estado_sig <= reset_state;
                                            valid_D <= (others => '1');           
                                            hab_out<='1';
                                            cuenta_D <= (others => '0');                    
                                        end if;
                                        if bit_cmd_selected = '1' then      
                                            estado_sig <= reset_state;
                                        end if;

                    when inicio =>      estado_sig <=load_dir;
                                        cuenta_D <= cuenta;
                                        valid_D <=valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                    when rep =>         estado_sig <=reset_state;
                                        cuenta_D <= cuenta;
                                        valid_D <=valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                    when others =>      estado_sig <=check_cmd;
                                        cuenta_D <= cuenta;
                                        valid_D <=valid;
                                        hab_out <= '0';
                                        hab_L_dir <= '0';
                                        hab_L_cmd <= '0';

                end case;

            when others =>      estado_sig <= reset_state;
                                cuenta_D <= cuenta;
                                valid_D <=valid;
                                hab_out <= '0';
                                hab_L_dir <= '0';
                                hab_L_cmd <= '0';

        end case;
    end process;

contadorclk : ffd
generic map (N => 8)
port map (  rst => rst,
            clk => clk,
            hab => hab,
            Q => clk_c,
            D => clk_c_d );

process (all)
begin
    if rst_clk = '1' then
        clk_c_d <= (others => '0');
    elsif unsigned (clk_c) = 80 then
        clk_c_d <= clk_c;
    else clk_c_d <= std_logic_vector ( unsigned (clk_c ) +1 );
    end if;
end process;

codigo_logica : process (all)
    begin
        code <= none;                           --asigno valores por defecto
        rst_clk <= '0';
        prev_d <= prev;
        if tipo (0) /= tipo (1) then            
            prev_d <= "00";
            rst_clk <= '1';
            flag <= '0';
            if tipo (1) = '1' then              
                case (to_integer(unsigned (clk_c))) is
                    when  1 to 5        =>  prev_d <= "10"; flag3 <= '1';
                    when  30 to 50      =>  prev_d <= "01"; flag2<= '1';
                    when others         =>  code <= none;
                                            flag <= '1';
                end case;
            end if;            
            if prev = "10" and tipo (1)= '0' then               
                prev_d <= "00";
                case (to_integer(unsigned (clk_c))) is
                    when  1 to 5    =>  code <= bit_0;
                    when  6 to 20   =>  code <= bit_1;
                    when others     =>  code <= none;
                end case;
            end if;
            if prev = "01" and tipo (1) = '0' then              
                case (to_integer(unsigned (clk_c)))is 
                    when 15 to 25   =>  prev_d      <=  "00";
                                        code        <=  inicio;
                    when 4 to 14    =>  code        <= rep;
                                        prev_d      <= "00";                    
                    when others     =>  code        <=  none;
                end case;
            end if;
        end if;        
    end process; 


mux_cmd : with cuenta select                            
    bit_cmd_selected <= cmd_out(0) when "000",
                        cmd_out(1) when "001",
                        cmd_out(2) when "010",
                        cmd_out(3) when "011",
                        cmd_out(4) when "100",
                        cmd_out(5) when "101",
                        cmd_out(6) when "110",
                        cmd_out(7) when others;   
    
mux_dir : with cuenta select                           
    bit_dir_selected <= dir_out(0) when "000",
                        dir_out(1) when "001",
                        dir_out(2) when "010",
                        dir_out(3) when "011",
                        dir_out(4) when "100",
                        dir_out(5) when "101",
                        dir_out(6) when "110",
                        dir_out(7) when others; 

--Logica de salida
    
                         

tipo_d(1) <= infrarrojo;
tipo_d(0) <= tipo(1);


end solucion;




