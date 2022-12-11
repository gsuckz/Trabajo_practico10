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

type tipos_estado is (reset_state, load_dir, load_cmd, check_cmd, check_dir);
type codigo is (bit_0, bit_1, inicio, rep, none);

signal cuenta,cuenta_D                  : std_logic_vector (2 downto 0); -- contador de bits recibidos
signal dir_d, cmd_d, dir_out, cmd_out   : std_logic_vector (7 downto 0);   
signal hab_out, hab_L_cmd, hab_L_dir    : std_logic;
signal bit_dir_selected                 : std_logic;
signal bit_cmd_selected                 : std_logic;

signal estado,estado_sig                : tipos_estado;
signal code                             : codigo;
signal valid,valid_D                    : std_logic_vector ( 0 downto 0);

begin 
    process (clk, rst)
    begin
        if rst = '1' then
            estado <= reset_state;
        elsif rising_edge(clk) then
            estado <= estado_sig;
        end if;
    end process;
contador : ffd 
    generic map (N => 3)
    port map( 
    rst => rst,
    hab => hab,
    clk => clk,
    Q => cuenta,
    D => cuenta_D);
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
        hab => hab_out,
        clk => clk,
        Q   => cmd,
        D   => cmd_out
    )   ;  
cmd_R_memory : ffd
    generic map (N=>8)
    port map(
        rst => rst,
        hab => hab_L_cmd,
        clk => clk,
        Q   => cmd_out,
        D   => cmd_d
    )   ;  
dir_out_memory : ffd
    generic map (N=>8)
    port map(
        rst => rst,
        hab => hab_out,
        clk => clk,
        Q   => dir,
        D   => dir_out
    )   ;
dir_memory : ffd
    generic map (N=>8)
    port map(
        rst => rst,
        hab => hab_L_dir,
        clk => clk,
        Q   => dir_out,
        D   => dir_d
    )  ;  
dir_d(6 downto 0) <= dir_out(7 downto 1);   
cmd_d(6 downto 0) <= cmd_out(7 downto 1);   
process (all)
    begin  
    dir_d(7) <= '0';
    cmd_d(7) <= '0';          
        if code = bit_1  then
            dir_d(7) <= '1';
            cmd_d(7) <= '1';
        end if;
    end process;
mux_cmd : with cuenta select 
bit_cmd_selected <= cmd(0) when "000",
                  cmd(1) when "001",
                  cmd(2) when "010",
                  cmd(3) when "011",
                  cmd(4) when "100",
                  cmd(5) when "101",
                  cmd(6) when "110",
                  cmd(7) when others;                     
mux_dir : with cuenta select 
bit_dir_selected <= dir(0) when "000",
                 dir(1) when "001",
                 dir(2) when "010",
                 dir(3) when "011",
                 dir(4) when "100",
                 dir(5) when "101",
                 dir(6) when "110",
                 dir(7) when others;                   
process (all)
    begin
        case (estado) is
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
                    when rep =>         estado_sig <=reset_state;
                        cuenta_D <= (others => '0');
                        valid_D <= valid;
                        hab_out <= '0';
                        hab_L_dir <= '0';
                        hab_L_cmd <= '0';
                    when others =>      estado_sig <=reset_state;
                end case;
            when load_dir =>
                case (code) is 
                    when (bit_0)  =>       estado_sig <=load_dir;
                        cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                        valid_D <= valid;
                        hab_out     <= '0';
                        hab_L_dir   <= '1';
                        hab_L_cmd   <= '0'; --podria poner un if y no hacer el otro case? 
                        if unsigned (cuenta) = 8 then 
                            estado_sig <= check_dir;
                            hab_L_dir <= '0';
                        end if;
                        when (bit_1)  =>       estado_sig <=load_dir;
                        cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                        valid_D <= valid;
                        hab_out     <= '0';
                        hab_L_dir   <= '1';
                        hab_L_cmd   <= '0'; --podria poner un if y no hacer el otro case? 
                        if unsigned (cuenta) = 8 then 
                            estado_sig <= check_dir;
                            hab_L_dir <= '0';
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
                if unsigned (cuenta) = 8 then 
                    estado_sig <= check_dir;
                    hab_L_dir <= '0';
                end if;
            when check_dir => 
                case (code) is 
                    when bit_0 =>       estado_sig <=check_dir;
                    cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                    valid_D <= valid;
                    hab_out     <= '0';
                    hab_L_dir   <= '0';
                    hab_L_cmd   <= '0'; 
                    if bit_dir_selected  = '0' then
                        estado_sig <= reset_state;
                    end if;
                    when bit_1 =>       estado_sig <=check_dir;
                    cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                    valid_D <= valid;
                    hab_out     <= '0';
                    hab_L_dir   <= '0';
                    hab_L_cmd   <= '0'; 
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
                if unsigned (cuenta)= 8 then 
                    estado_sig <= load_cmd;
                    hab_L_cmd <= '1';
                end if;
            when load_cmd => 
            case (code) is 
            when (bit_0) =>      estado_sig <=load_dir;
            cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
            valid_D <= valid;
            hab_out     <= '0';
            hab_L_dir   <= '0';
            hab_L_cmd   <= '1'; --podria poner un if y no hacer el otro case? 
            if unsigned (cuenta) = 8 then 
                estado_sig <= check_cmd;
                hab_L_cmd <= '0';
            end if;
            when (bit_1)   =>       estado_sig <=load_dir;
            cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
            valid_D <= valid;
            hab_out     <= '0';
            hab_L_dir   <= '1';
            hab_L_cmd   <= '1'; --podria poner un if y no hacer el otro case? 
            if unsigned (cuenta) = 8 then 
                estado_sig <= check_cmd;
                hab_L_cmd <= '0';
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
                if unsigned (cuenta) = 8 then 
                    estado_sig <= check_cmd;
                    hab_L_cmd <= '0';
                end if;
            when check_cmd => 
                case (code) is 
                    when bit_0 =>       estado_sig <=check_cmd;
                    cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                    valid_D <= valid;
                    hab_out     <= '0';
                    hab_L_dir   <= '0';
                    hab_L_cmd   <= '0'; 
                    if bit_cmd_selected  = '1' then
                        estado_sig <= reset_state;
                    end if;
                    when bit_1 =>       estado_sig <=check_cmd;
                    cuenta_D <= std_logic_vector ( unsigned (cuenta) + 1);
                    valid_D <= valid;
                    hab_out     <= '0';
                    hab_L_dir   <= '0';
                    hab_L_cmd   <= '0'; 
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
                if unsigned (cuenta) = 8 then 
                    estado_sig <= reset_state;
                    valid_D <= (others => '1');           
                    hab_out<='1';
                end if;
            when others => estado_sig <= reset_state;
            cuenta_D <= cuenta;
            valid_D <=valid;
            hab_out <= '0';
            hab_L_dir <= '0';
            hab_L_cmd <= '0';
        end case;
    end process;
end solucion;




