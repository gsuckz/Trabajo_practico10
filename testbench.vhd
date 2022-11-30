library IEEE;
use IEEE.std_logic_1164.all;


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
    clk_in <= '0';
    wait for clk_L;
    clk_in <= '1';
    wait for clk_H;
end process;


end tb;