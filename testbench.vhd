library IEEE;
use IEEE.std_logic_1164.all;


package testbench_pkg is
    function gen_msg(texto: string; e : std_logic_vector; o :std_logic_vector) return string;
    function to_string(x:std_logic) return string;
end package testbench_pkg;

package body testbench_pkg is
    function gen_msg(texto: string; e : std_logic_vector; o :std_logic_vector) return string is
    begin
        return   texto
               & lf & "    Esperado: " & to_string(e)
               & lf & "    Obtenido: " & to_string(o);
    end function gen_msg;
    
    function to_string(x:std_logic) return string is
    begin
        return std_logic'image(x);
    end function to_string;
end package body testbench_pkg;


entity receptor_control_remoto_tb is
end receptor_control_remoto_tb;



architecture tb of receptor_control_remoto_tb is
    component receptor_control_remoto is 
        port (
        rst         :    in std_logic;
        infrarrojo  :    in std_logic;
        hab         :    in std_logic;
        clk         :    in std_logic;
        valido      :    out std_logic;
        dir         :    out std_logic_vector (7 downto 0);
        cmd         :    out std_logic_vector (7 downto 0));
    end component;
    --Constantes
    constant clk_H      :    time := 187.5 us;
    constant clk_L      :    time := 187.5 us;
    constant byte_dir     :    std_logic_vector (7 downto 0) := "00000000";
    constant byte_cmd     :    std_logic_vector (7 downto 0) := "11111111";

    --Señales
    signal rst_in, infrarrojo_in, hab_in, clk_in, valido_out : std_logic;
    signal dir_out, cmd_out : std_logic_vector (7 downto 0);

begin 

    DUT : receptor_control_remoto port map (
        rst         =>    rst_in, 
        infrarrojo  =>    infrarrojo_in, 
        hab         =>    hab_in, 
        clk         =>    clk_in,

        valido      =>    valido_out, 
        dir         =>    dir_out, 
        cmd         =>    cmd_out);
    
clk_signal: process
begin
clk_loop  :  for a in 0 to 500 loop
    clk_in <= '0';
    wait for clk_L;
    clk_in <= '1';
    wait for clk_H;
    end loop clk_loop;
wait;
end process;

data_signal : process

variable pass : boolean := true;
variable esperado : std_logic_vector (7 downto 0);
constant regla1: string := "Reset debe ser asincronico";
constant regla2: string := "Cadena de datos recibida diferente";


begin
    rst_in<='1';
    wait for clk_L;
    esperado := (others => '0');
    if not(dir_out = esperado and cmd_our = esperado) then
       report  gen_msg (regla1,esperado,Q)
       severity error;
    pass:= false;
    end if;
    infrarrojo_in <= '0';
    wait for 48*clk_L;
    infrarrojo_in <= '1';
    wait for 24*clk_L;
    byte_dir_loop : for k in 0 to 7 loop
        infrarrojo_in <= '0';
        wait for 6*clk_L;
        infrarrojo_in <= '1';
        wait for 6*clk_L;
        if byte_dir(k) then 
            wait for 12*clk_L;
            end if;
        end loop;       
    byte_not_dir_loop : for k in 0 to 7 loop
        infrarrojo_in <= '0';
        wait for 6*clk_L;
        infrarrojo_in <= '1';
        wait for 6*clk_L;
        if not(byte_dir(k)) then 
            wait for 12*clk_L;
            end if;  
    end loop;    
    byte_cmd_loop : for k in 0 to 7 loop
        infrarrojo_in <= '0';
        wait for 6*clk_L;
        infrarrojo_in <= '1';
        wait for 6*clk_L;
        if byte_cmd(k) then 
            wait for 12*clk_L;
            end if;
        end loop;       
    byte_not_cmd_loop : for k in 0 to 7 loop
        infrarrojo_in <= '0';
        wait for 6*clk_L;
        infrarrojo_in <= '1';
        wait for 6*clk_L;
        if not(byte_cmd(k)) then 
            wait for 12*clk_L;
            end if;  
    end loop;       
    repeticion_loop : for k in 0 to 10 loop
        infrarrojo_in <= '0';
        wait for 48*clk_l;
        infrarrojo_in <='1';
        wait for 8*clk_l;
        infrarrojo_in <='0';
        wait for 3*clk_l;
        infrarrojo_in <= '1';
        wait for 15*clk_l;
    end loop;
--    esperado := byte_1;
--    if not(valido_out = esperado) then
--        report gen_msg(regla2,esperado,valido_out)
--        severity error;
--        pass:=false;
--    end if;
    
    wait;
end process;
end tb;