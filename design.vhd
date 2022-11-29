library IEEE;
use IEEE.std_logic_1164.all;

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

begin
    

end solucion;



